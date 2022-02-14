pragma solidity ^0.8.0;
// SPDX-License-Identifier: MIT

//Mantle Finance - https://mantlefi.com/
//
//                      ooO
//                     ooOOOo
//                   oOOOOOOoooo
//                 ooOOOooo  oooo
//                /vvv V\
//               /V V   V\ 
//              /V  V    V\          
//             /           \          ALL HAIL LIQUIDITY!!!!!
//            /             \               /
//           /               \   	 o          o
//          /                 \     /-   o     /-
//  /\     /                   \   /\  -/-    /\
//                                     /\

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

interface IRoyaltyFeeManager {
    function calculateRoyaltyFeeAndGetRecipient(
        address collection,
        uint256 tokenId,
        uint256 amount
    ) external view returns (address, uint256);
}

//Mantle - P2P NFT Collateralized Contract, Part of the logic refers to the contract of https://nftfi.com/
contract MantleFinanceV1 is Ownable, ERC721, ReentrancyGuard, Pausable {
    using SafeMath for uint256;
    using ECDSA for bytes32;

    //This contract complies with the ERC-721 standard, and Lender will get a Promissory Note NFT on each Loan begin. 
    //This NFT is also destroyed during repayment and liquidation.
    //Note that transferring this PN means transferring the right to 清算與收款
    constructor() ERC721("Mantle Fianace Promissory Note", "Mantle PN") {
    }

    //Whitelist of NFT projects and ERC-20 
    mapping (address => bool) public whitelistForLendERC20;
    mapping (address => bool) public whitelistForAllowNFT;

    //The current total loan the ongoing loans in the protocol and
    uint256 public totalNumLoans = 0;
    uint256 public totalActiveLoans = 0;

    //協議中真實存放 Loan 的地方，注意我們將清算選項，因為 loanIdToLoan 將會於還款與清算時，一並刪除減少 Gas 費用
    mapping (uint256 => Loan) public loanIdToLoan;
    mapping (uint256 => bool) public loanRepaidOrLiquidated;

    //協議中的 Royalty Fee 管理者，此寫法參考 looksrare.org 的架構
    IRoyaltyFeeManager public royaltyFeeManager;

    //協議中的收取的費用，注意：費用皆於還款時向 Lender 收取。 (25 = 0.25%, 100 = 1%)
    uint256 public adminFeeInBasisPoints = 25;

    //驗證 off-chain 簽名的授權，無論是 Borrower or Lender 皆使用此 Mapping 參數。
    //使用 Nonce 的時機，
    mapping (address => mapping (uint256 => bool)) private _nonceOfSigning;

    //其餘參數
    uint256 public maximumLoanDuration = 53 weeks;
    uint256 public maximumNumberOfActiveLoans = 100;

    //loan 最基礎的架構
    struct Loan {
        uint256 loanId;
        uint256 loanPrincipalAmount;
        uint256 repaymentAmount;
        uint256 nftCollateralId;
        uint64 loanStartTime;
        uint32 loanDuration;
        uint32 loanAdminFeeInBasisPoints;
        address[2] nftCollateralContractAndloanERC20;
        address borrower;
    }

    //Events

    event LoanStarted(
        uint256 loanId,
        address borrower,
        address lender,
        uint256 loanPrincipalAmount,
        uint256 maximumRepaymentAmount,
        uint256 nftCollateralId,
        uint256 loanStartTime,
        uint256 loanDuration,
        address nftCollateralContract,
        address loanERC20Denomination
    );

    event LoanRepaid(
        uint256 loanId,
        address borrower,
        address lender,
        uint256[2] loanPrincipalAmountAndRepaymentAmount,
        uint256 nftCollateralId,
        uint256[3] amountPaidToLenderAndAdminFeeAndRoyaltyFee,
        address[2] nftCollateralContractAndloanERC20Denomination
    );

    event LoanLiquidated(
        uint256 loanId,
        address borrower,
        address lender,
        uint256 loanPrincipalAmount,
        uint256 nftCollateralId,
        uint256 loanMaturityDate,
        uint256 loanLiquidationDate,
        address nftCollateralContract
    );

    event AdminFeeUpdated(
        uint256 newAdminFee
    );

    event NonceUsed(
        address user,
        uint nonce
    );

    event NewRoyaltyFeeManager(
        address indexed royaltyFeeManager
    );

    event RoyaltyPayment(
        address indexed collection,
        uint256 indexed tokenId,
        address indexed royaltyRecipient,
        address currency,
        uint256 amount
    );

    //邏輯開始
   
    function beginLoan(
        uint256 _loanPrincipalAmount,
        uint256 _repaymentAmount,
        uint256 _nftCollateralId,
        uint256 _loanDuration,
        uint256 _adminFeeInBasisPoints,
        uint256[2] memory _borrowerAndLenderNonces,
        address[2] memory _contract,
        address _lender,
        uint256[2] memory _ExpireTime,
        bytes memory _borrowerSignature,
        bytes memory _lenderSignature
    ) public whenNotPaused nonReentrant {

        //白名單檢查
        require(whitelistForAllowNFT[_contract[0]], 'This Nft is not in whitelist'); //這個 NFT 計畫目前沒有在 Mantle 所支援的 ERC 721 白名單中
        require(whitelistForLendERC20[_contract[1]], 'This erc20 is not in whitelist'); //這個 ERC20 代幣目前沒有在 Mantle 所支援的 ERC 20 白名單中

        //安全性檢查
        require(maximumLoanDuration >= _loanDuration, '_loanDuration too high'); //貸款期間不得設置超過 Mantle 平台限制的時間
        require(_repaymentAmount >= _loanPrincipalAmount, '_repaymentAmount too low');  //Mantle 平台不接受負利率的貸款案件
        require(_loanDuration != 0, '_loanDuration can not be 0'); //需要設置
        require(_adminFeeInBasisPoints == adminFeeInBasisPoints, '_adminFeeInBasisPoints error'); //簽名授權的 admin fee 與 預設不同，請重新 Sign

        //Nonce 檢查
        require(_nonceOfSigning[msg.sender][_borrowerAndLenderNonces[0]] == false, 'borrow nonce been used'); //Borrower 的 Nonoce 已經被使用了，有可能是此訂單已經成立，或是 Borrower 取消 Offer
        require(_nonceOfSigning[_lender][_borrowerAndLenderNonces[1]] == false, 'lender nonce been used'); //Lender 的 Nonoce 已經被使用了，有可能是此訂單已經成立，或是 Lender 取消 Listing

        Loan memory loan = Loan({
            loanId: totalNumLoans, //currentLoanId,
            loanPrincipalAmount: _loanPrincipalAmount,
            repaymentAmount: _repaymentAmount,
            nftCollateralId: _nftCollateralId,
            loanStartTime: uint64(block.timestamp), //_loanStartTime
            loanDuration: uint32(_loanDuration),
            loanAdminFeeInBasisPoints: uint32(_adminFeeInBasisPoints),
            nftCollateralContractAndloanERC20: _contract,
            borrower: msg.sender //borrower
        });

        //檢查 Borrower 的簽名，再次確認他是否要借出此 NFT，並且確認簽名有無過期？
        require(isValidBorrowerSignature(
            loan.nftCollateralId,
            _borrowerAndLenderNonces[0],//_borrowerNonce,
            loan.nftCollateralContractAndloanERC20[0],
            msg.sender,      //borrower,
            _ExpireTime[0],
            _borrowerSignature
        ), 'Borrower signature is invalid');

        //檢查 Lender 的簽名，再次確認他是否有 Offer 此 NFT，並且確認簽名有無過期？
        require(isValidLenderSignature(
            loan.loanPrincipalAmount,
            loan.repaymentAmount,
            loan.nftCollateralId,
            loan.loanDuration,
            loan.loanAdminFeeInBasisPoints,
            _borrowerAndLenderNonces[1],//_lenderNonce,
            loan.nftCollateralContractAndloanERC20,
            _lender,
            _ExpireTime[1],
            _lenderSignature
        ), 'Lender signature is invalid');

        //將 Loan 寫入清單內
        loanIdToLoan[totalNumLoans] = loan;
        totalNumLoans = totalNumLoans.add(1);
        totalActiveLoans = totalActiveLoans.add(1);
        require(totalActiveLoans <= maximumNumberOfActiveLoans, 'Contract has reached the maximum number of active loans allowed by admins');

        //轉移借款資金與抵押 NFT 至協議內
        IERC721(loan.nftCollateralContractAndloanERC20[0]).transferFrom(msg.sender, address(this), loan.nftCollateralId);
        IERC20(loan.nftCollateralContractAndloanERC20[1]).transferFrom(_lender, msg.sender, loan.loanPrincipalAmount);

        //Borrower and Lender 的 Nonce 列為使用狀態
        _nonceOfSigning[msg.sender][_borrowerAndLenderNonces[0]] = true;
        _nonceOfSigning[_lender][_borrowerAndLenderNonces[1]] = true;

        //Mint Mantle Fianance 的 Promissory Note
        //Lender needs to pay attention to this, because the owner of the PS will determine the recipient of the payment when it is liquidated and repaid later.
        _mint(_lender, loan.loanId);
        
        emit LoanStarted(
            loan.loanId,
            msg.sender,      //borrower,
            _lender,
            loan.loanPrincipalAmount,
            loan.repaymentAmount,
            loan.nftCollateralId,
            block.timestamp,             //_loanStartTime
            loan.loanDuration,
            loan.nftCollateralContractAndloanERC20[0],
            loan.nftCollateralContractAndloanERC20[1]
        );
    }

    function payBackLoan(uint256 _loanId) external nonReentrant {
        //Check if the loan has been repaid, or liquidated
        require(loanRepaidOrLiquidated[_loanId] == false, 'Loan has already been repaid or liquidated');
        loanRepaidOrLiquidated[_loanId] = true;

        //Get detail in the loan
        Loan memory loan = loanIdToLoan[_loanId];
        require(msg.sender == loan.borrower, 'Only the borrower can pay back a loan and reclaim the underlying NFT');

        //Take the final Lender of this Loan and repay
        address lender = ownerOf(_loanId);
        uint256 interestDue = (loan.repaymentAmount).sub(loan.loanPrincipalAmount);

        uint256 adminFee = _computeAdminFee(interestDue, uint256(loan.loanAdminFeeInBasisPoints));
        
        (address royaltyFeeRecipient, uint256 royaltyFeeAmount) = royaltyFeeManager.calculateRoyaltyFeeAndGetRecipient(loan.nftCollateralContractAndloanERC20[0], loan.nftCollateralId, interestDue);

        if ((royaltyFeeRecipient != address(0)) && (royaltyFeeAmount != 0)) {
            IERC20(loan.nftCollateralContractAndloanERC20[1]).transferFrom(loan.borrower, royaltyFeeRecipient, royaltyFeeAmount);

            emit RoyaltyPayment(loan.nftCollateralContractAndloanERC20[0], loan.nftCollateralId, royaltyFeeRecipient, loan.nftCollateralContractAndloanERC20[1], royaltyFeeAmount);
        }
        
        uint256 payoffAmount = ((loan.loanPrincipalAmount).add(interestDue)).sub(adminFee).sub(royaltyFeeAmount);

        //Reduce the amount of ongoing loans in the protocol
        totalActiveLoans = totalActiveLoans.sub(1);

        //協議費用收取與還款
        IERC20(loan.nftCollateralContractAndloanERC20[1]).transferFrom(loan.borrower, lender, payoffAmount);
        IERC20(loan.nftCollateralContractAndloanERC20[1]).transferFrom(loan.borrower, owner(), adminFee);

        //Burn Mantle Finance Promissory Note
        _burn(_loanId);

        //Transfer the collateralized NFT to Borrower
        require(_transferNftToAddress(
            loan.nftCollateralContractAndloanERC20[0],
            loan.nftCollateralId,
            loan.borrower
        ), 'NFT was not successfully transferred');

        emit LoanRepaid(
            _loanId,
            loan.borrower,
            lender,
            [loan.loanPrincipalAmount,loan.repaymentAmount],
            loan.nftCollateralId,
            [payoffAmount,adminFee,royaltyFeeAmount],
            [loan.nftCollateralContractAndloanERC20[0],loan.nftCollateralContractAndloanERC20[1]]
        );

        delete loanIdToLoan[_loanId];
    }

    function liquidateOverdueLoan(uint256 _loanId) external nonReentrant {
        //Check if the loan has been repaid, or liquidated
        require(loanRepaidOrLiquidated[_loanId] == false, 'Loan has already been repaid or liquidated');
        loanRepaidOrLiquidated[_loanId] = true;

        //Get detail in the loan and check if it's overdue and can be liquidated
        Loan memory loan = loanIdToLoan[_loanId];
        uint256 loanMaturityDate = (uint256(loan.loanStartTime)).add(uint256(loan.loanDuration));
        require(block.timestamp > loanMaturityDate, 'Loan is not overdue yet');

        //Reduce the amount of ongoing loans in the protocol
        totalActiveLoans = totalActiveLoans.sub(1);

        //Burn Mantle Finance Promissory Note
        _burn(_loanId);

        //Take the final Lender of this Loan and liquidate nft
        address lender = ownerOf(_loanId);

        require(_transferNftToAddress(
            loan.nftCollateralContractAndloanERC20[0],
            loan.nftCollateralId,
            lender
        ), 'NFT was not successfully transferred');

        emit LoanLiquidated(
            _loanId,
            loan.borrower,
            lender,
            loan.loanPrincipalAmount,
            loan.nftCollateralId,
            loanMaturityDate,
            block.timestamp,
            loan.nftCollateralContractAndloanERC20[0]
        );

         delete loanIdToLoan[_loanId];
    }

    function setNonceUsed(uint256 _nonce) external {
        require(_nonceOfSigning[msg.sender][_nonce] == false, 'This Nonce has been used, the order has been established, or the Offer has been cancelled');
        _nonceOfSigning[msg.sender][_nonce] = true;

        emit NonceUsed(
            msg.sender,
            _nonce
        );
    }

    //Admin

    function setWhitelistERC20(address _erc20, bool _bool) external onlyOwner {
        whitelistForLendERC20[_erc20] = _bool;
    }

    function setWhitelistNFTContract(address _erc721, bool _bool) external onlyOwner {
        whitelistForAllowNFT[_erc721] = _bool;
    }

    function updateMaximumLoanDuration(uint256 _newMaximumLoanDuration) external onlyOwner {
        require(_newMaximumLoanDuration <= uint256(~uint32(0)), 'loan duration cannot exceed space alotted in struct');
        maximumLoanDuration = _newMaximumLoanDuration;
    }

    function updateMaximumNumberOfActiveLoans(uint256 _newMaximumNumberOfActiveLoans) external onlyOwner {
        maximumNumberOfActiveLoans = _newMaximumNumberOfActiveLoans;
    }


    function updateAdminFee(uint256 _newAdminFeeInBasisPoints) external onlyOwner {
        require(_newAdminFeeInBasisPoints <= 10000, 'By definition, basis points cannot exceed 10000');
        adminFeeInBasisPoints = _newAdminFeeInBasisPoints;
        emit AdminFeeUpdated(_newAdminFeeInBasisPoints);
    }

    function updateRoyaltyFeeManager(address _royaltyFeeManager) external onlyOwner {
        require(_royaltyFeeManager != address(0), "Owner: Cannot be null address");
        royaltyFeeManager = IRoyaltyFeeManager(_royaltyFeeManager);
        emit NewRoyaltyFeeManager(_royaltyFeeManager);
    }

    //View

    function isValidBorrowerSignature(
        uint256 _nftCollateralId,
        uint256 _borrowerNonce,
        address _nftCollateralContract,
        address _borrower,
        uint256 _expireTime,
        bytes memory _borrowerSignature
    ) public view returns(bool) {
        if(_borrower == address(0)){
            return false;
        } else {
            uint256 chainId;
            chainId = getChainID();
            bytes32 message = keccak256(abi.encodePacked(
                _nftCollateralId,
                _borrowerNonce,
                _nftCollateralContract,
                _borrower,
                _expireTime,
                chainId
            ));

            bytes32 messageWithEthSignPrefix = message.toEthSignedMessageHash();

            if(block.timestamp < _expireTime){
                return (messageWithEthSignPrefix.recover(_borrowerSignature) == _borrower);
            }else{
                return false;
            }
        }
    }

     function isValidLenderSignature(
        uint256 _loanPrincipalAmount,
        uint256 _repaymentAmount,
        uint256 _nftCollateralId,
        uint256 _loanDuration,
        uint256 _adminFeeInBasisPoints,
        uint256 _lenderNonce,
        address[2] memory _nftCollateralContractAndloanERC20,
        address _lender,
        uint256 _expireTime,
        bytes memory _lenderSignature
    ) public view returns(bool) {
        if(_lender == address(0)){
            return false;
        } else {
            uint256 chainId;
            chainId = getChainID();
            bytes32 message = keccak256(abi.encodePacked(
                _loanPrincipalAmount,
                _repaymentAmount,
                _nftCollateralId,
                _loanDuration,
                _adminFeeInBasisPoints,
                _lenderNonce,
                _nftCollateralContractAndloanERC20[0],
                _nftCollateralContractAndloanERC20[1],
                _lender,
                _expireTime,
                chainId
            ));

            bytes32 messageWithEthSignPrefix = message.toEthSignedMessageHash();
            if(block.timestamp < _expireTime){
                return (messageWithEthSignPrefix.recover(_lenderSignature) == _lender);
            }else{
                return false;
            }
        }
    }

    function getNonceIsUsed(address _user, uint256 _nonce) public view returns (bool) {
        return _nonceOfSigning[_user][_nonce];
    }

    function _computeAdminFee(uint256 _interestDue, uint256 _adminFeeInBasisPoints) internal pure returns (uint256) {
    	return (_interestDue.mul(_adminFeeInBasisPoints)).div(10000);
    }

    function _transferNftToAddress(address _nftContract, uint256 _nftId, address _recipient) internal returns (bool) {
        // 同意 ERC721 地址願意讓此合約進行轉移
        _nftContract.call(abi.encodeWithSelector(IERC721(_nftContract).approve.selector, address(this), _nftId));

        (bool success, ) = _nftContract.call(abi.encodeWithSelector(IERC721(_nftContract).transferFrom.selector, address(this), _recipient, _nftId));
        return success;
    }

    function getChainID() public view returns (uint256) {
        uint256 id;
        assembly {
            id := chainid()
        }
        return id;
    }

    fallback() external payable {
        revert();
    }
}