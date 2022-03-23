//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./AxleToken.sol";

interface Token {
    function mint(address to, uint256 amount) external;
}

contract TokenSale is Ownable {    
    using SafeMath for uint256;

    uint public startTime;
    uint public endTime;

    uint256 public exchangeRate = 1;
    uint256 public minAmount;
    uint256 public maxAmount;

    address public token;

    uint public totalBalances;

    mapping(address => uint256) public userBalance;
    mapping(address => bool) public whitelist;
    address[] public users;

    event Whitelisted(address indexed account, bool allow);
    event Deposited(address indexed account, uint256 amount);

    constructor() {
        token = address(new AxleToken());
    }

    function deposit() external payable {
        require(msg.sender != address(0), "invalid address");
        require(startTime <= block.timestamp && block.timestamp <= endTime, "Sale Began");
        address user = msg.sender;
        uint256 amount = msg.value.div(exchangeRate);
        require(amount >= minAmount && amount <= maxAmount, "should deposit proper amount of tokens");

        if (!findUser(user)) {
            users.push(user);
        }

        userBalance[user] = userBalance[user].add(amount);
        totalBalances = totalBalances.add(amount);

        if (!whitelist[user]) {
            whitelist[user] = true;
            emit Whitelisted(user, true);
        }

        emit Deposited(user, amount);
    }

    function findUser(address user) internal view returns(bool) {
        for (uint i = 0; i < users.length ; i++) {
            if (users[i] == user) return true;
        }

        return false;
    }

    function transfer() external onlyOwner {
        for (uint i = 0; i < users.length; i++) {
            Token(token).mint(users[i], userBalance[users[i]]);
        }
    }

    function setExchangeRate(uint256 rate) external onlyOwner{
        exchangeRate = rate;
    }

    function setPeriod(uint _startTime, uint _endTime) external onlyOwner {
        startTime = _startTime;
        endTime = _endTime;
    }

    /*
    ** set stage for croundfounding. 
    ** rate: ratio between eth and token
    ** _startTime: time to start selling tokens
    ** _endTime: time to end selling tokens
    ** _maxAmount: maximum amount of tokens to sell at this stage
    ** _minAmount: minimum amount of tokens to sell at this stage
    */
    function setStage(uint256 rate, uint256 _startTime, uint256 _endTime, uint256 _maxAmount, uint256 _minAmount) external onlyOwner {
        exchangeRate = rate;
        startTime = _startTime;
        endTime = _endTime;
        maxAmount = _maxAmount;
        minAmount = _minAmount;
    }
}
