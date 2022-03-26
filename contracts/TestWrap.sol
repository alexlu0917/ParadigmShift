// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./ERC20WrappableSupport.sol";

contract TestWrap is Ownable, ERC20WrappableSupport {
    address payable public wToken;

    event Received(address, uint);
    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

    function pay() external payable {
        require(_bundleWrap(wToken), "failed to bundle actions");
    }

    function refundMe(uint256 amount) external {
        require(_unwrap(wToken, amount), "failed to withdraw");
    }

    function setWToken(address _wToken) public onlyOwner {
        wToken = payable(_wToken);
    }

    function getSenderAddress() external returns (bytes memory) {
        (bool success, bytes memory data) = wToken.delegatecall(abi.encodeWithSignature("getSenderAddress()"));
        return data;
    }
}