pragma solidity =0.5.16;
pragma experimental ABIEncoderV2;

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

    function getKYCAttributes(address _target) external view returns (KYCAttribute[] memory);
    function getSupplierStatus(address _target) external view returns (bool);
    function isERC20Active(address contractAddress) external view returns (bool);
    function getERC20Info(address contractAddress) external view returns (string memory, string memory, uint8, uint8, bool);
} 