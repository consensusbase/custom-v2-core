pragma solidity >=0.5.0;

interface IKycSbt {
    function balanceOf(address owner) public view returns (uint256);
    function getHoldTokens(address holder) public view returns (uint256[] memory);
    function getKYCAttribute(uint256 tokenId) public view returns (address, uint8, bool, bool, bool, uint256);
    function locked(uint256 tokenId) public view returns (bool);
} 