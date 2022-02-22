var LendingPlaceContract_abi = [
	{
		"inputs": [],
		"stateMutability": "nonpayable",
		"type": "constructor"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "newAdminFee",
				"type": "uint256"
			}
		],
		"name": "AdminFeeUpdated",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "address",
				"name": "owner",
				"type": "address"
			},
			{
				"indexed": true,
				"internalType": "address",
				"name": "approved",
				"type": "address"
			},
			{
				"indexed": true,
				"internalType": "uint256",
				"name": "tokenId",
				"type": "uint256"
			}
		],
		"name": "Approval",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "address",
				"name": "owner",
				"type": "address"
			},
			{
				"indexed": true,
				"internalType": "address",
				"name": "operator",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "bool",
				"name": "approved",
				"type": "bool"
			}
		],
		"name": "ApprovalForAll",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "loanId",
				"type": "uint256"
			},
			{
				"indexed": false,
				"internalType": "address",
				"name": "borrower",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "address",
				"name": "lender",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "loanPrincipalAmount",
				"type": "uint256"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "nftCollateralId",
				"type": "uint256"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "loanMaturityDate",
				"type": "uint256"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "loanClaimedDate",
				"type": "uint256"
			},
			{
				"indexed": false,
				"internalType": "address",
				"name": "nftCollateralContract",
				"type": "address"
			}
		],
		"name": "LoanClaimed",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "loanId",
				"type": "uint256"
			},
			{
				"indexed": false,
				"internalType": "address",
				"name": "borrower",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "address",
				"name": "lender",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "uint256[2]",
				"name": "loanPrincipalAmountAndRepaymentAmount",
				"type": "uint256[2]"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "nftCollateralId",
				"type": "uint256"
			},
			{
				"indexed": false,
				"internalType": "uint256[3]",
				"name": "amountPaidToLenderAndAdminFeeAndRoyaltyFee",
				"type": "uint256[3]"
			},
			{
				"indexed": false,
				"internalType": "address[2]",
				"name": "nftCollateralContractAndloanERC20Denomination",
				"type": "address[2]"
			}
		],
		"name": "LoanRepaid",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "loanId",
				"type": "uint256"
			},
			{
				"indexed": false,
				"internalType": "address",
				"name": "borrower",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "address",
				"name": "lender",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "loanPrincipalAmount",
				"type": "uint256"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "maximumRepaymentAmount",
				"type": "uint256"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "nftCollateralId",
				"type": "uint256"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "loanStartTime",
				"type": "uint256"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "loanDuration",
				"type": "uint256"
			},
			{
				"indexed": false,
				"internalType": "address",
				"name": "nftCollateralContract",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "address",
				"name": "loanERC20Denomination",
				"type": "address"
			}
		],
		"name": "LoanStarted",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"internalType": "address",
				"name": "user",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "nonce",
				"type": "uint256"
			}
		],
		"name": "NonceUsed",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "address",
				"name": "previousOwner",
				"type": "address"
			},
			{
				"indexed": true,
				"internalType": "address",
				"name": "newOwner",
				"type": "address"
			}
		],
		"name": "OwnershipTransferred",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"internalType": "address",
				"name": "account",
				"type": "address"
			}
		],
		"name": "Paused",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "address",
				"name": "collection",
				"type": "address"
			},
			{
				"indexed": true,
				"internalType": "uint256",
				"name": "tokenId",
				"type": "uint256"
			},
			{
				"indexed": true,
				"internalType": "address",
				"name": "royaltyRecipient",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "address",
				"name": "currency",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "amount",
				"type": "uint256"
			}
		],
		"name": "RoyaltyPayment",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "address",
				"name": "from",
				"type": "address"
			},
			{
				"indexed": true,
				"internalType": "address",
				"name": "to",
				"type": "address"
			},
			{
				"indexed": true,
				"internalType": "uint256",
				"name": "tokenId",
				"type": "uint256"
			}
		],
		"name": "Transfer",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"internalType": "address",
				"name": "account",
				"type": "address"
			}
		],
		"name": "Unpaused",
		"type": "event"
	},
	{
		"stateMutability": "payable",
		"type": "fallback"
	},
	{
		"inputs": [],
		"name": "adminFee",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "to",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "tokenId",
				"type": "uint256"
			}
		],
		"name": "approve",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "owner",
				"type": "address"
			}
		],
		"name": "balanceOf",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "_loanPrincipalAmount",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "_repaymentAmount",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "_nftCollateralId",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "_loanDuration",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "_adminFee",
				"type": "uint256"
			},
			{
				"internalType": "uint256[2]",
				"name": "_borrowerAndLenderNonces",
				"type": "uint256[2]"
			},
			{
				"internalType": "address[2]",
				"name": "_contract",
				"type": "address[2]"
			},
			{
				"internalType": "address",
				"name": "_lender",
				"type": "address"
			},
			{
				"internalType": "uint256[2]",
				"name": "_ExpireTime",
				"type": "uint256[2]"
			},
			{
				"internalType": "bytes",
				"name": "_borrowerSignature",
				"type": "bytes"
			},
			{
				"internalType": "bytes",
				"name": "_lenderSignature",
				"type": "bytes"
			}
		],
		"name": "beginLoan",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "_loanId",
				"type": "uint256"
			}
		],
		"name": "claimOverdueLoan",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "tokenId",
				"type": "uint256"
			}
		],
		"name": "getApproved",
		"outputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "getChainID",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "_user",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "_nonce",
				"type": "uint256"
			}
		],
		"name": "getNonceIsUsed",
		"outputs": [
			{
				"internalType": "bool",
				"name": "",
				"type": "bool"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "owner",
				"type": "address"
			},
			{
				"internalType": "address",
				"name": "operator",
				"type": "address"
			}
		],
		"name": "isApprovedForAll",
		"outputs": [
			{
				"internalType": "bool",
				"name": "",
				"type": "bool"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "_nftCollateralId",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "_borrowerNonce",
				"type": "uint256"
			},
			{
				"internalType": "address",
				"name": "_nftCollateralContract",
				"type": "address"
			},
			{
				"internalType": "address",
				"name": "_borrower",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "_expireTime",
				"type": "uint256"
			},
			{
				"internalType": "bytes",
				"name": "_borrowerSignature",
				"type": "bytes"
			}
		],
		"name": "isValidBorrowerSignature",
		"outputs": [
			{
				"internalType": "bool",
				"name": "",
				"type": "bool"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "_loanPrincipalAmount",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "_repaymentAmount",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "_nftCollateralId",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "_loanDuration",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "_adminFee",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "_lenderNonce",
				"type": "uint256"
			},
			{
				"internalType": "address[2]",
				"name": "_nftCollateralContractAndloanERC20",
				"type": "address[2]"
			},
			{
				"internalType": "address",
				"name": "_lender",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "_expireTime",
				"type": "uint256"
			},
			{
				"internalType": "bytes",
				"name": "_lenderSignature",
				"type": "bytes"
			}
		],
		"name": "isValidLenderSignature",
		"outputs": [
			{
				"internalType": "bool",
				"name": "",
				"type": "bool"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"name": "loanIdToLoan",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "loanId",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "loanPrincipalAmount",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "repaymentAmount",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "nftCollateralId",
				"type": "uint256"
			},
			{
				"internalType": "uint64",
				"name": "loanStartTime",
				"type": "uint64"
			},
			{
				"internalType": "uint32",
				"name": "loanDuration",
				"type": "uint32"
			},
			{
				"internalType": "uint32",
				"name": "loanAdminFee",
				"type": "uint32"
			},
			{
				"internalType": "address",
				"name": "borrower",
				"type": "address"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"name": "loanRepaidOrClaimed",
		"outputs": [
			{
				"internalType": "bool",
				"name": "",
				"type": "bool"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "maximumLoanDuration",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "maximumNumberOfActiveLoans",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "name",
		"outputs": [
			{
				"internalType": "string",
				"name": "",
				"type": "string"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "owner",
		"outputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "tokenId",
				"type": "uint256"
			}
		],
		"name": "ownerOf",
		"outputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "paused",
		"outputs": [
			{
				"internalType": "bool",
				"name": "",
				"type": "bool"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "_loanId",
				"type": "uint256"
			}
		],
		"name": "payBackLoan",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "renounceOwnership",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "royaltyFeeManager",
		"outputs": [
			{
				"internalType": "contract IRoyaltyFeeManager",
				"name": "",
				"type": "address"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "from",
				"type": "address"
			},
			{
				"internalType": "address",
				"name": "to",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "tokenId",
				"type": "uint256"
			}
		],
		"name": "safeTransferFrom",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "from",
				"type": "address"
			},
			{
				"internalType": "address",
				"name": "to",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "tokenId",
				"type": "uint256"
			},
			{
				"internalType": "bytes",
				"name": "_data",
				"type": "bytes"
			}
		],
		"name": "safeTransferFrom",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "operator",
				"type": "address"
			},
			{
				"internalType": "bool",
				"name": "approved",
				"type": "bool"
			}
		],
		"name": "setApprovalForAll",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "_nonce",
				"type": "uint256"
			}
		],
		"name": "setNonceUsed",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "_erc20",
				"type": "address"
			},
			{
				"internalType": "bool",
				"name": "_bool",
				"type": "bool"
			}
		],
		"name": "setWhitelistERC20",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "_erc721",
				"type": "address"
			},
			{
				"internalType": "bool",
				"name": "_bool",
				"type": "bool"
			}
		],
		"name": "setWhitelistNFTContract",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "bytes4",
				"name": "interfaceId",
				"type": "bytes4"
			}
		],
		"name": "supportsInterface",
		"outputs": [
			{
				"internalType": "bool",
				"name": "",
				"type": "bool"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "symbol",
		"outputs": [
			{
				"internalType": "string",
				"name": "",
				"type": "string"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "tokenId",
				"type": "uint256"
			}
		],
		"name": "tokenURI",
		"outputs": [
			{
				"internalType": "string",
				"name": "",
				"type": "string"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "totalActiveLoans",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "totalNumLoans",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "from",
				"type": "address"
			},
			{
				"internalType": "address",
				"name": "to",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "tokenId",
				"type": "uint256"
			}
		],
		"name": "transferFrom",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "newOwner",
				"type": "address"
			}
		],
		"name": "transferOwnership",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "_newAdminFee",
				"type": "uint256"
			}
		],
		"name": "updateAdminFee",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "_newMaximumLoanDuration",
				"type": "uint256"
			}
		],
		"name": "updateMaximumLoanDuration",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "_newMaximumNumberOfActiveLoans",
				"type": "uint256"
			}
		],
		"name": "updateMaximumNumberOfActiveLoans",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"name": "whitelistForAllowedERC20",
		"outputs": [
			{
				"internalType": "bool",
				"name": "",
				"type": "bool"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"name": "whitelistForAllowedNFT",
		"outputs": [
			{
				"internalType": "bool",
				"name": "",
				"type": "bool"
			}
		],
		"stateMutability": "view",
		"type": "function"
	}
]