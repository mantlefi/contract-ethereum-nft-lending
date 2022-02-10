pragma solidity ^0.8.0;

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

contract MantleFinanceV1 is Ownable, ERC721, ReentrancyGuard, Pausable {
    using SafeMath for uint256;
    using ECDSA for bytes32;

    constructor() ERC721("Mantle Fianace Promissory Note", "Mantle PN") {
    }

    mapping (address => bool) public whitelistForLendERC20;
    mapping (address => bool) public whitelistForAllowNFT;

    uint256 public totalNumLoans = 0;
    uint256 public totalActiveLoans = 0;

    mapping (uint256 => Loan) public loanIdToLoan;
    mapping (uint256 => bool) public loanRepaidOrLiquidated;

    //驗證 off-chain 簽名的授權，無論是 Borrower or Lender 皆使用此 Mapping 參數。
    //使用 Nonce 的時機，
    mapping (address => mapping (uint256 => bool)) private _nonceOfSigning;

    uint256 public maximumLoanDuration = 53 weeks;
    uint256 public maximumNumberOfActiveLoans = 100;
    uint256 public adminFeeInBasisPoints = 25;

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
        uint256 loanPrincipalAmount,
        uint256 nftCollateralId,
        uint256 amountPaidToLender,
        uint256 adminFee,
        address nftCollateralContract,
        address loanERC20Denomination
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
        require(whitelistForAllowNFT[_contract[0]], ''); //這個 NFT 計畫目前沒有在 Mantle 所支援的 ERC 721 白名單中
        require(whitelistForLendERC20[_contract[1]], ''); //這個 ERC20 代幣目前沒有在 Mantle 所支援的 ERC 20 白名單中

        //安全性檢查
        require(maximumLoanDuration >= _loanDuration, ''); //貸款期間不得設置超過 Mantle 平台限制的時間
        require(_repaymentAmount >= _loanPrincipalAmount, '');  //Mantle 平台不接受負利率的貸款案件
        require(_loanDuration != 0, ''); //需要設置
        require(_adminFeeInBasisPoints == adminFeeInBasisPoints, ''); //簽名授權的 admin fee 與 預設不同，請重新 Sign

        //Nonce 檢查
        require(_nonceOfSigning[msg.sender][_borrowerAndLenderNonces[0]] == false, ''); //Borrower 的 Nonoce 已經被使用了，有可能是此訂單已經成立，或是 Borrower 取消 Offer
        require(_nonceOfSigning[_lender][_borrowerAndLenderNonces[1]] == false, ''); //Lender 的 Nonoce 已經被使用了，有可能是此訂單已經成立，或是 Lender 取消 Listing

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

        require(isValidBorrowerSignature(
            loan.nftCollateralId,
            _borrowerAndLenderNonces[0],//_borrowerNonce,
            loan.nftCollateralContractAndloanERC20[0],
            msg.sender,      //borrower,
            _ExpireTime[0],
            _borrowerSignature
        ), 'Borrower signature is invalid');

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

        loanIdToLoan[totalNumLoans] = loan;
        totalNumLoans = totalNumLoans.add(1);
        totalActiveLoans = totalActiveLoans.add(1);
        require(totalActiveLoans <= maximumNumberOfActiveLoans, 'Contract has reached the maximum number of active loans allowed by admins');

        IERC721(loan.nftCollateralContractAndloanERC20[0]).transferFrom(msg.sender, address(this), loan.nftCollateralId);
        IERC20(loan.nftCollateralContractAndloanERC20[1]).transferFrom(_lender, msg.sender, loan.loanPrincipalAmount);

        //Borrower and Lender 的 Nonce 列為使用狀態
        _nonceOfSigning[msg.sender][_borrowerAndLenderNonces[0]] = true;
        _nonceOfSigning[_lender][_borrowerAndLenderNonces[1]] = true;

        //Mint Mantle Fianance 的 Promissory Note ，Lender 需要特別留意此方法，因為待後面清算與還款時，都是按照此 PS 的所有人來決定收款對象。
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
        require(loanRepaidOrLiquidated[_loanId] == false, 'Loan has already been repaid or liquidated');
        loanRepaidOrLiquidated[_loanId] = true;

        Loan memory loan = loanIdToLoan[_loanId];
        require(msg.sender == loan.borrower, 'Only the borrower can pay back a loan and reclaim the underlying NFT');

        address lender = ownerOf(_loanId);
        uint256 interestDue = (loan.repaymentAmount).sub(loan.loanPrincipalAmount);

        uint256 adminFee = _computeAdminFee(interestDue, uint256(loan.loanAdminFeeInBasisPoints));
        uint256 payoffAmount = ((loan.loanPrincipalAmount).add(interestDue)).sub(adminFee);

        totalActiveLoans = totalActiveLoans.sub(1);

        IERC20(loan.nftCollateralContractAndloanERC20[1]).transferFrom(loan.borrower, lender, payoffAmount);
        IERC20(loan.nftCollateralContractAndloanERC20[1]).transferFrom(loan.borrower, owner(), adminFee);

        //將 Mantle Finance Promissory Note 收據燃燒
        _burn(_loanId);

        require(_transferNftToAddress(
            loan.nftCollateralContractAndloanERC20[0],
            loan.nftCollateralId,
            loan.borrower
        ), 'NFT was not successfully transferred');

        emit LoanRepaid(
            _loanId,
            loan.borrower,
            lender,
            loan.loanPrincipalAmount,
            loan.nftCollateralId,
            payoffAmount,
            adminFee,
            loan.nftCollateralContractAndloanERC20[0],
            loan.nftCollateralContractAndloanERC20[1]
        );

        delete loanIdToLoan[_loanId];
    }

    function liquidateOverdueLoan(uint256 _loanId) external nonReentrant {
        require(loanRepaidOrLiquidated[_loanId] == false, 'Loan has already been repaid or liquidated');
        loanRepaidOrLiquidated[_loanId] = true;

        Loan memory loan = loanIdToLoan[_loanId];
        uint256 loanMaturityDate = (uint256(loan.loanStartTime)).add(uint256(loan.loanDuration));
        require(block.timestamp > loanMaturityDate, 'Loan is not overdue yet');

        totalActiveLoans = totalActiveLoans.sub(1);

        address lender = ownerOf(_loanId);

        //將 Mantle Finance Promissory Note 收據燃燒
        _burn(_loanId);

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

    function cancelLoanCommitmentBeforeLoanHasBegun(uint256 _nonce) external {
        require(_nonceOfSigning[msg.sender][_nonce] == false, ''); // 此 Nonce 已經被使用，可能是訂單已經成立，或是 Offer 已經取消過
        _nonceOfSigning[msg.sender][_nonce] = true;

        emit NonceUsed(
            msg.sender,
            _nonce
        );
    }


    //Admin 管理區域

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