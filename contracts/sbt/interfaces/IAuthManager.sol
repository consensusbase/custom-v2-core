pragma solidity >=0.5.0;

interface IAuthManager {
    function getMinterActivity(address target) public view returns (bool);
    function isERC20Active(address contractAddress) public view returns (bool);
    function getSBTContract() public view returns (address);
} 