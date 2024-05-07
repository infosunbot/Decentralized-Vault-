// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

interface IWETH {
    function deposit() external payable;
    function withdraw(uint amount) external;
}

contract Vault is ReentrancyGuard {
    using SafeERC20 for IERC20;
    
    IWETH public immutable weth;
    mapping(address => uint256) private _ethBalances;
    mapping(address => mapping(address => uint256)) private _tokenBalances;

    event DepositETH(address indexed user, uint256 amount);
    event WithdrawETH(address indexed user, uint256 amount);
    event WrapToWETH(address indexed user, uint256 amount);
    event UnwrapWETH(address indexed user, uint256 amount);
    event DepositERC20(address indexed user, address indexed token, uint256 amount);
    event WithdrawERC20(address indexed user, address indexed token, uint256 amount);

    constructor(address _wethAddress) {
        weth = IWETH(_wethAddress);
    }

    // Deposit ETH without conversion
    function depositETH() external payable {
        _ethBalances[msg.sender] += msg.value;
        emit DepositETH(msg.sender, msg.value);
    }

    // Withdraw ETH
    function withdrawETH(uint256 amount) external nonReentrant {
        require(_ethBalances[msg.sender] >= amount, "Insufficient balance");
        _ethBalances[msg.sender] -= amount;
        (bool sent, ) = msg.sender.call{value: amount}("");
        require(sent, "Failed to send ETH");
        emit WithdrawETH(msg.sender, amount);
    }

    // Wrap ETH to WETH
    function wrapToWETH(uint256 amount) external nonReentrant {
        require(_ethBalances[msg.sender] >= amount, "Insufficient ETH balance");
        _ethBalances[msg.sender] -= amount;
        weth.deposit{value: amount}();
        _tokenBalances[address(weth)][msg.sender] += amount;
        emit WrapToWETH(msg.sender, amount);
    }

    // Unwrap WETH to ETH
    function unwrapWETH(uint256 amount) external nonReentrant {
        require(_tokenBalances[address(weth)][msg.sender] >= amount, "Insufficient WETH balance");
        _tokenBalances[address(weth)][msg.sender] -= amount;
        weth.withdraw(amount);
        (bool sent, ) = msg.sender.call{value: amount}("");
        require(sent, "Failed to send ETH");
        emit UnwrapWETH(msg.sender, amount);
    }

    // Deposit ERC20 tokens
    function depositToken(address token, uint256 amount) external {
        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
        _tokenBalances[token][msg.sender] += amount;
        emit DepositERC20(msg.sender, token, amount);
    }

    // Withdraw ERC20 tokens
    function withdrawToken(address token, uint256 amount) external nonReentrant {
        require(_tokenBalances[token][msg.sender] >= amount, "Insufficient balance");
        _tokenBalances[token][msg.sender] -= amount;
        IERC20(token).safeTransfer(msg.sender, amount);
        emit WithdrawERC20(msg.sender, token, amount);
    }

    // Receive function to handle direct ETH deposits
    receive() external payable {
        // Directly depositing ETH is not expected behavior; should only accept ETH as part of WETH wrapping.
        // Hence, we can revert any direct ETH transfers that aren't part of a function call (like depositETH or wrapToWETH)
        revert("Direct ETH deposits are not allowed, use depositETH.");
    }
}
