//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/presets/ERC20PresetMinterPauser.sol";

contract AxleToken is ERC20PresetMinterPauser {    
    constructor() ERC20PresetMinterPauser("Axle", "AXL") {}
}
