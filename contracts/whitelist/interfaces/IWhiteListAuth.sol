pragma solidity =0.5.16;

interface IWhiteListAuth {
    struct KYCAttribute {
        uint256 id;
        address supplier;
        uint8 verifyType;
        bool activity;
        bool deadlock;
        bool isVerifiedToken;
        uint256 fromTime;
        uint256 expireTime;
    }

    function getKYCAttributes(address _target) public view returns (KYCAttribute[] memory);
    function getSupplierStatus(address _target) public view returns (bool);
    function isERC20Active(address contractAddress) public view returns (bool);
    function getERC20Info(address contractAddress) public view returns (string memory, string memory, uint8, uint8, bool);
} 