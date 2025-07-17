pragma solidity =0.5.16;
pragma experimental ABIEncoderV2;

import '../interfaces/IUniswapV2Factory.sol';
import './UniswapV2Pair.sol';
import './interfaces/IWhiteListAuth.sol';

interface IERC721Receiver {
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);
}

contract WhiteListFactory is IUniswapV2Factory {
    address public feeTo;
    address public feeToSetter;
    address public authContract;

    mapping(address => mapping(address => address)) public getPair;
    address[] public allPairs;

    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    constructor(address _feeToSetter, address _authContract) public {
        feeToSetter = _feeToSetter;
        authContract = _authContract;
    }

    function isFactoryKycVerified(address tokenAddress) public view returns (bool) {
        if (authContract == address(0)) return false;

        IWhiteListAuth auth = IWhiteListAuth(authContract);
        IWhiteListAuth.KYCAttribute[] memory attributes = auth.getKYCAttributes(address(this));

        (
          string memory name,
          string memory symbol,
          uint8 decimals,
          uint8 tokenType,
          bool isActive
        ) = auth.getERC20Info(tokenAddress);

        if (attributes.length == 0) return false;
        bool res = false;
        for (uint i = 0; i < attributes.length; i++) {
          if (!auth.getSupplierStatus(attributes[i].supplier)) continue;
          if (attributes[i].verifyType == tokenType) continue;
          if (attributes[i].deadlock) continue;
          if (!attributes[i].activity) continue;
          if (!attributes[i].isVerifiedToken && attributes[i].expireTime < block.timestamp) continue;
          res = true;
          break;
        }
        return res;
    }

    function isErc20TokenValid(address tokenAddress) public view returns (bool) {
        if (authContract == address(0)) return false;
        IWhiteListAuth auth = IWhiteListAuth(authContract);

        (, , , , bool isActive, address minter) = auth.getERC20Info(tokenAddress);
        if (!isActive) return false;
        if (!auth.getCTIStatus(minter)) return false;
        return true;
    }

    function allPairsLength() external view returns (uint) {
        return allPairs.length;
    }

    function createPair(address tokenA, address tokenB) external returns (address pair) {
        require(isFactoryKycVerified(tokenA), 'UniswapV2: FACTORY_KYC_INVALID');
        require(isFactoryKycVerified(tokenB), 'UniswapV2: FACTORY_KYC_INVALID');
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

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4) {
        return 0x150b7a02;
    }
}
