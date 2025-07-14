pragma solidity =0.5.16;

import '../interfaces/IUniswapV2Factory.sol';
import './UniswapV2Pair.sol';
import './interfaces/IKycSbt.sol';
import './interfaces/IAuthManager.sol';

interface IERC721Receiver {
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);
}

contract SbtFactory is IUniswapV2Factory {
    address public feeTo;
    address public feeToSetter;
    address public kycSbtContract;
    address public authContract;

    mapping(address => mapping(address => address)) public getPair;
    address[] public allPairs;

    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    constructor(address _feeToSetter, address _authContract, address _kycSbtContract) public {
        feeToSetter = _feeToSetter;
        authContract = _authContract;
        kycSbtContract = _kycSbtContract;
    }

    function isFactoryKycVerified() public view returns (bool) {
        if (authContract == address(0) || kycSbtContract == address(0)) return false;
        IAuthManager authManager = IAuthManager(authContract);
        IKycSbt kycSbt = IKycSbt(kycSbtContract);
        if (kycSbt.balanceOf(address(this)) == 0) return false;

        uint256[] memory holdtokens = kycSbt.getHoldTokens(address(this));
        if (holdtokens.length == 0) return false;
        uint256 maxTokenId = 0;
        for (uint i = 0; i < holdtokens.length; i++) {
            if (holdtokens[i] > maxTokenId) {
                maxTokenId = holdtokens[i];
            }
        }

        (address minter, uint8 verifyType, bool isActive, bool isDeadLock, bool isVerified, uint256 expire) = kycSbt
            .getKYCAttribute(holdtokens[maxTokenId]);
        if (!authManager.getMinterActivity(minter)) return false;
        if (isDeadLock) return false;
        if (!isActive) return false;
        if (!isVerified && expire < block.timestamp) return false;
        return true;
    }

    function isErc20TokenValid(address tokenAddress) public view returns (bool) {
        if (!isFactoryKycVerified()) return false;
        IAuthManager authManager = IAuthManager(authContract);
        IKycSbt kycSbt = IKycSbt(kycSbtContract);
        (uint8 tokenType, bool isActive, address minter) = authManager.getERC20Attribute(tokenAddress);
        if (!isActive) return false;
        if (!authManager.getMinterActivity(minter)) return false;
        if (!authManager.isERC20Active(tokenAddress)) return false;

        uint256[] memory holdtokens = kycSbt.getHoldTokens(address(this));
        if (holdtokens.length == 0) return false;
        for (uint i = 0; i < holdtokens.length; i++) {
            (
                address sbtMinter,
                uint8 sbtVerifyType,
                bool sbtIsActive,
                bool sbtIsDeadLock,
                bool sbtIsVerified,
                uint256 sbtExpire
            ) = kycSbt.getKYCAttribute(holdtokens[i]);
            if (
                sbtVerifyType == tokenType &&
                !sbtIsDeadLock &&
                sbtIsActive &&
                sbtIsVerified &&
                sbtExpire > block.timestamp
            ) return true;
        }
        return false;
    }

    function allPairsLength() external view returns (uint) {
        return allPairs.length;
    }

    function createPair(address tokenA, address tokenB) external returns (address pair) {
        require(isFactoryKycVerified(), 'UniswapV2: FACTORY_KYC_INVALID');
        require(isErc20TokenValid(tokenA), 'UniswapV2: TOKENA_NOT_VALID');
        require(isErc20TokenValid(tokenB), 'UniswapV2: TOKENB_NOT_VALID');

        require(tokenA != tokenB, 'UniswapV2: IDENTICAL_ADDRESSES');
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'UniswapV2: ZERO_ADDRESS');
        require(getPair[token0][token1] == address(0), 'UniswapV2: PAIR_EXISTS'); // single check is sufficient
        bytes memory bytecode = type(UniswapV2Pair).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(token0, token1));
        assembly {
            pair := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        IUniswapV2Pair(pair).initialize(token0, token1);
        getPair[token0][token1] = pair;
        getPair[token1][token0] = pair; // populate mapping in the reverse direction
        allPairs.push(pair);
        emit PairCreated(token0, token1, pair, allPairs.length);
    }

    function setFeeTo(address _feeTo) external {
        require(msg.sender == feeToSetter, 'UniswapV2: FORBIDDEN');
        feeTo = _feeTo;
    }

    function setFeeToSetter(address _feeToSetter) external {
        require(msg.sender == feeToSetter, 'UniswapV2: FORBIDDEN');
        feeToSetter = _feeToSetter;
    }

    function setAuthContract(address _authContract) external {
        require(msg.sender == feeToSetter, 'UniswapV2: FORBIDDEN');
        authContract = _authContract;
    }

    function setKycSBTContract(address _kycsbtContract) external {
        require(msg.sender == feeToSetter, 'UniswapV2: FORBIDDEN');
        kycSbtContract = _kycsbtContract;
    }

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4) {
        return 0x150b7a02;
    }
}
