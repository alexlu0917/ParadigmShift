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

    event Whitelisted(address indexed account, bool indexed allow);
    event Deposited(address indexed account, uint256 amount);
    event ChangedExchangeRate(uint256 value);
    constructor() {
        token = address(new AxleToken());
    }

    function deposit() external payable {
        address user = msg.sender;
        uint256 amount = msg.value.div(exchangeRate);

        if (!findUser(user)) {
            users.push(user);
        }

        userBalance[user] = userBalance[user].add(amount);

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

    function setExchangeRate(uint256 rate) external onlyOwner {
        exchangeRate = rate;
        emit ChangedExchangeRate(rate);
    }

}
