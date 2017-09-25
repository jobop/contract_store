pragma solidity ^0.4.13;


// Contracts that can be converted into other sourced of value
// should implement this.
contract Generatable{
    function generate() public returns(address);
}
