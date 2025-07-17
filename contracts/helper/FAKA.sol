pragma solidity ^0.8.27;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract FAKA is ERC20, ERC20Permit {
    constructor() ERC20("FAKA", "FAKA") ERC20Permit("FAKA") {}
}