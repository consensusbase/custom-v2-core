pragma solidity >=0.5.0;

interface IAuthManager {
    function getMinterActivity(address target) external view returns (bool);
    function isERC20Active(address contractAddress) external view returns (bool);
    function getSBTContract() external view returns (address);
    function getERC20Attribute(address tokenAddress) external view returns (uint8 tokenType, bool isActive, address minter);
} 