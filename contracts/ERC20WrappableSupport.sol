pragma solidity >=0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface IERC20Wrappable is IERC20 {
    function deposit() external payable;

    function withdraw(uint256 wad) external;
}

contract ERC20WrappableSupport {
    modifier withWrap(address payable wToken) {
        require(_bundleWrap(wToken), "failed to wrap");
        _;
    }

    modifier withUnwrap(address payable wToken, uint256 amount) {
        _;
        _unwrap(wToken, amount);
    }

    modifier _underlyingTokenRequired(address payable wToken) {
        require(wToken != address(0), "underlying token not set");
        _;
    }

    /// @dev execute wrap transaction along the process and transfer wETH into original msg.sender account
    function _bundleWrap(address payable wToken)
        internal
        _underlyingTokenRequired(wToken)
        returns (bool)
    {
        // Note:
        // There exists a special variant of a message `call`,
        // named `delegatecall` which is identical to a message call
        // apart from the fact that the code at the target address
        // is executed in the context of the calling contract
        // and msg.sender and msg.value do not change their values.
        (bool deposited, ) = wToken.call{value: msg.value}(
            abi.encodeWithSignature("deposit()")
        );
        require(deposited, "failed to deposit");
        IERC20(wToken).transferFrom(address(this), msg.sender, msg.value);

        return true;
    }

    // @dev to unwrap an earned wETH -> ETH
    function _unwrap(address payable wToken, uint256 wad)
        internal
        _underlyingTokenRequired(wToken)
        returns (bool)
    {
        // this statement needs an approval in prior
        // transfer fund from user account to the current contract
        require(IERC20(wToken).allowance(msg.sender, address(this)) >= wad, "insufficient balance");
        require(
            IERC20(wToken).transferFrom(msg.sender, address(this), wad),
            "wERC20: failed to transfer to calling contract"
        );

        // here we will withdraw transfered wETH in the contract to ETH
        // then transfer it again to the recipient (msg.sender)
        // execution operated by this contract
        // IERC20Wrappable(wToken).withdraw(wad);
        // (bool withdrawn, ) = msg.sender.call{value: wad}("");

        return true;
    }
}