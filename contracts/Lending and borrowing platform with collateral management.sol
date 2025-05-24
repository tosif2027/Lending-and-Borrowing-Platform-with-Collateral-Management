// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract LendingPlatform is Ownable {
    IERC20 public collateralToken;
    IERC20 public loanToken;
    uint256 public collateralRatio = 150; // 150% collateral required

    struct Loan {
        uint256 collateralAmount;
        uint256 loanAmount;
        bool isActive;
    }

    mapping(address => Loan) public loans;

    /// @notice Default constructor with dummy token addresses and collateralRatio
    constructor() Ownable(msg.sender) {
        collateralToken = IERC20(0x000000000000000000000000000000000000dEaD); // Replace with actual test token address
        loanToken = IERC20(0x000000000000000000000000000000000000bEEF); // Replace with actual test token address
        collateralRatio = 150; // 150% collateral
    }



    function depositCollateral(uint256 _collateralAmount, uint256 _loanAmount) external {
        require(_collateralAmount > 0 && _loanAmount > 0, "Invalid amounts");
        require(!loans[msg.sender].isActive, "Active loan exists");

        uint256 requiredCollateral = (_loanAmount * collateralRatio) / 100;
        require(_collateralAmount >= requiredCollateral, "Insufficient collateral");

        require(collateralToken.transferFrom(msg.sender, address(this), _collateralAmount), "Collateral transfer failed");
        require(loanToken.transfer(msg.sender, _loanAmount), "Loan transfer failed");

        loans[msg.sender] = Loan(_collateralAmount, _loanAmount, true);
    }

    function repayLoan() external {
        Loan storage loan = loans[msg.sender];
        require(loan.isActive, "No active loan");

        require(loanToken.transferFrom(msg.sender, address(this), loan.loanAmount), "Loan repayment failed");
        require(collateralToken.transfer(msg.sender, loan.collateralAmount), "Collateral return failed");

        loan.isActive = false;
    }

    function liquidate(address borrower) external onlyOwner {
        Loan storage loan = loans[borrower];
        require(loan.isActive, "No active loan");

        // In production: fetch oracle prices and validate undercollateralization
        require(collateralToken.transfer(owner(), loan.collateralAmount), "Collateral seizure failed");
        loan.isActive = false;
    }

    function updateCollateralRatio(uint256 _newRatio) external onlyOwner {
        require(_newRatio >= 100, "Ratio must be >= 100%");
        collateralRatio = _newRatio;
    }

    function withdrawLoanTokens(uint256 amount) external onlyOwner {
        require(loanToken.transfer(owner(), amount), "Withdraw failed");
    }

    function withdrawCollateralTokens(uint256 amount) external onlyOwner {
        require(collateralToken.transfer(owner(), amount), "Withdraw failed");
    }
}
