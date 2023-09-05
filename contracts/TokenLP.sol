// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./LP.sol";

contract TokenLP is LP {
    string private constant NAME = "TokenLP";
    string private constant SYMBOL = "LP";
    uint256 private INITIAL_SUPPLY = 0;
    constructor() {
        _name = NAME;
        _symbol = SYMBOL;
        _totalSupply = INITIAL_SUPPLY;
    }
}