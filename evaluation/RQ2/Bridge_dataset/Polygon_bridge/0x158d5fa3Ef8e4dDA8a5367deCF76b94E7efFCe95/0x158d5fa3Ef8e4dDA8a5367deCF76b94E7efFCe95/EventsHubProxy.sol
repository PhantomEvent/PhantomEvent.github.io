// File: contracts/common/governance/IGovernance.sol

pragma solidity ^0.5.17;

interface IGovernance {
    function update(address target, bytes calldata data) external;
}

// File: contracts/common/governance/Governable.sol

pragma solidity ^0.5.17;


contract Governable {
    IGovernance public governance;

    constructor(address _governance) public {
        governance = IGovernance(_governance);
    }

    modifier onlyGovernance() {
        _assertGovernance();
        _;
    }

    function _assertGovernance() private view {
        require(
            msg.sender == address(governance),
            "Only governance contract is authorized"
        );
    }
}

// File: contracts/root/withdrawManager/IWithdrawManager.sol

pragma solidity ^0.5.17;

contract IWithdrawManager {
    function createExitQueue(address token) external;

    function verifyInclusion(
        bytes calldata data,
        uint8 offset,
        bool verifyTxInclusion
    ) external view returns (uint256 age);

    function addExitToQueue(
        address exitor,
        address childToken,
        address rootToken,
        uint256 exitAmountOrTokenId,
        bytes32 txHash,
        bool isRegularExit,
        uint256 priority
    ) external;

    function addInput(
        uint256 exitId,
        uint256 age,
        address utxoOwner,
        address token
    ) external;

    function challengeExit(
        uint256 exitId,
        uint256 inputId,
        bytes calldata challengeData,
        address adjudicatorPredicate
    ) external;
}

// File: contracts/common/Registry.sol

pragma solidity ^0.5.17;




contract Registry is Governable {
    // @todo hardcode constants
    bytes32 private constant WETH_TOKEN = keccak256("wethToken");
    bytes32 private constant DEPOSIT_MANAGER = keccak256("depositManager");
    bytes32 private constant STAKE_MANAGER = keccak256("stakeManager");
    bytes32 private constant VALIDATOR_SHARE = keccak256("validatorShare");
    bytes32 private constant WITHDRAW_MANAGER = keccak256("withdrawManager");
    bytes32 private constant CHILD_CHAIN = keccak256("childChain");
    bytes32 private constant STATE_SENDER = keccak256("stateSender");
    bytes32 private constant SLASHING_MANAGER = keccak256("slashingManager");

    address public erc20Predicate;
    address public erc721Predicate;

    mapping(bytes32 => address) public contractMap;
    mapping(address => address) public rootToChildToken;
    mapping(address => address) public childToRootToken;
    mapping(address => bool) public proofValidatorContracts;
    mapping(address => bool) public isERC721;

    enum Type {Invalid, ERC20, ERC721, Custom}
    struct Predicate {
        Type _type;
    }
    mapping(address => Predicate) public predicates;

    event TokenMapped(address indexed rootToken, address indexed childToken);
    event ProofValidatorAdded(address indexed validator, address indexed from);
    event ProofValidatorRemoved(address indexed validator, address indexed from);
    event PredicateAdded(address indexed predicate, address indexed from);
    event PredicateRemoved(address indexed predicate, address indexed from);
    event ContractMapUpdated(bytes32 indexed key, address indexed previousContract, address indexed newContract);

    constructor(address _governance) public Governable(_governance) {}

    function updateContractMap(bytes32 _key, address _address) external onlyGovernance {
        emit ContractMapUpdated(_key, contractMap[_key], _address);
        contractMap[_key] = _address;
    }

    /**
     * @dev Map root token to child token
     * @param _rootToken Token address on the root chain
     * @param _childToken Token address on the child chain
     * @param _isERC721 Is the token being mapped ERC721
     */
    function mapToken(
        address _rootToken,
        address _childToken,
        bool _isERC721
    ) external onlyGovernance {
        require(_rootToken != address(0x0) && _childToken != address(0x0), "INVALID_TOKEN_ADDRESS");
        rootToChildToken[_rootToken] = _childToken;
        childToRootToken[_childToken] = _rootToken;
        isERC721[_rootToken] = _isERC721;
        IWithdrawManager(contractMap[WITHDRAW_MANAGER]).createExitQueue(_rootToken);
        emit TokenMapped(_rootToken, _childToken);
    }

    function addErc20Predicate(address predicate) public onlyGovernance {
        require(predicate != address(0x0), "Can not add null address as predicate");
        erc20Predicate = predicate;
        addPredicate(predicate, Type.ERC20);
    }

    function addErc721Predicate(address predicate) public onlyGovernance {
        erc721Predicate = predicate;
        addPredicate(predicate, Type.ERC721);
    }

    function addPredicate(address predicate, Type _type) public onlyGovernance {
        require(predicates[predicate]._type == Type.Invalid, "Predicate already added");
        predicates[predicate]._type = _type;
        emit PredicateAdded(predicate, msg.sender);
    }

    function removePredicate(address predicate) public onlyGovernance {
        require(predicates[predicate]._type != Type.Invalid, "Predicate does not exist");
        delete predicates[predicate];
        emit PredicateRemoved(predicate, msg.sender);
    }

    function getValidatorShareAddress() public view returns (address) {
        return contractMap[VALIDATOR_SHARE];
    }

    function getWethTokenAddress() public view returns (address) {
        return contractMap[WETH_TOKEN];
    }

    function getDepositManagerAddress() public view returns (address) {
        return contractMap[DEPOSIT_MANAGER];
    }

    function getStakeManagerAddress() public view returns (address) {
        return contractMap[STAKE_MANAGER];
    }

    function getSlashingManagerAddress() public view returns (address) {
        return contractMap[SLASHING_MANAGER];
    }

    function getWithdrawManagerAddress() public view returns (address) {
        return contractMap[WITHDRAW_MANAGER];
    }

    function getChildChainAndStateSender() public view returns (address, address) {
        return (contractMap[CHILD_CHAIN], contractMap[STATE_SENDER]);
    }

    function isTokenMapped(address _token) public view returns (bool) {
        return rootToChildToken[_token] != address(0x0);
    }

    function isTokenMappedAndIsErc721(address _token) public view returns (bool) {
        require(isTokenMapped(_token), "TOKEN_NOT_MAPPED");
        return isERC721[_token];
    }

    function isTokenMappedAndGetPredicate(address _token) public view returns (address) {
        if (isTokenMappedAndIsErc721(_token)) {
            return erc721Predicate;
        }
        return erc20Predicate;
    }

    function isChildTokenErc721(address childToken) public view returns (bool) {
        address rootToken = childToRootToken[childToken];
        require(rootToken != address(0x0), "Child token is not mapped");
        return isERC721[rootToken];
    }
}

// File: contracts/common/mixin/Initializable.sol

pragma solidity ^0.5.17;

contract Initializable {
    bool inited = false;

    modifier initializer() {
        require(!inited, "already inited");
        inited = true;
        
        _;
    }
}

// File: contracts/staking/EventsHub.sol

pragma solidity ^0.5.17;



contract IStakeManagerEventsHub {
    struct Validator {
        uint256 amount;
        uint256 reward;
        uint256 activationEpoch;
        uint256 deactivationEpoch;
        uint256 jailTime;
        address signer;
        address contractAddress;
    }

    mapping(uint256 => Validator) public validators;
}

contract EventsHub is Initializable {
    Registry public registry;

    modifier onlyValidatorContract(uint256 validatorId) {
        address _contract;
        (, , , , , , _contract) = IStakeManagerEventsHub(registry.getStakeManagerAddress()).validators(validatorId);
        require(_contract == msg.sender, "not validator");
        _;
    }

    modifier onlyStakeManager() {
        require(registry.getStakeManagerAddress() == msg.sender,
        "Invalid sender, not stake manager");
        _;
    }

    function initialize(Registry _registry) external initializer {
        registry = _registry;
    }

    event ShareBurnedWithId(
        uint256 indexed validatorId,
        address indexed user,
        uint256 indexed amount,
        uint256 tokens,
        uint256 burnId
    );

    function logShareBurnedWithId(
        uint256 validatorId,
        address user,
        uint256 amount,
        uint256 tokens,
        uint256 burnId
    ) public onlyValidatorContract(validatorId) {
        emit ShareBurnedWithId(validatorId, user, amount, tokens, burnId);
    }

    event RewardParams(
        uint256 rewardDecreasePerCheckpoint,
        uint256 maxRewardedCheckpoints,
        uint256 checkpointRewardDelta
    );

    function logRewardParams(
        uint256 rewardDecreasePerCheckpoint,
        uint256 maxRewardedCheckpoints,
        uint256 checkpointRewardDelta
    ) public onlyStakeManager {
        emit RewardParams(rewardDecreasePerCheckpoint, maxRewardedCheckpoints, checkpointRewardDelta);
    }
}

// File: contracts/common/misc/ERCProxy.sol

/*
 * SPDX-License-Identitifer:    MIT
 */

pragma solidity ^0.5.17;

// See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-897.md

interface ERCProxy {
    function proxyType() external pure returns (uint256 proxyTypeId);
    function implementation() external view returns (address codeAddr);
}

// File: contracts/common/misc/DelegateProxyForwarder.sol

pragma solidity ^0.5.17;

contract DelegateProxyForwarder {
    function delegatedFwd(address _dst, bytes memory _calldata) internal {
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            let result := delegatecall(
                sub(gas, 10000),
                _dst,
                add(_calldata, 0x20),
                mload(_calldata),
                0,
                0
            )
            let size := returndatasize

            let ptr := mload(0x40)
            returndatacopy(ptr, 0, size)

            // revert instead of invalid() bc if the underlying call failed with invalid() it already wasted gas.
            // if the call returned error data, forward it
            switch result
                case 0 {
                    revert(ptr, size)
                }
                default {
                    return(ptr, size)
                }
        }
    }
    
    function isContract(address _target) internal view returns (bool) {
        if (_target == address(0)) {
            return false;
        }

        uint256 size;
        assembly {
            size := extcodesize(_target)
        }
        return size > 0;
    }
}

// File: contracts/common/misc/DelegateProxy.sol

pragma solidity ^0.5.17;



contract DelegateProxy is ERCProxy, DelegateProxyForwarder {
    function proxyType() external pure returns (uint256 proxyTypeId) {
        // Upgradeable proxy
        proxyTypeId = 2;
    }

    function implementation() external view returns (address);
}

// File: contracts/common/misc/UpgradableProxy.sol

pragma solidity ^0.5.17;


contract UpgradableProxy is DelegateProxy {
    event ProxyUpdated(address indexed _new, address indexed _old);
    event OwnerUpdate(address _new, address _old);

    bytes32 constant IMPLEMENTATION_SLOT = keccak256("matic.network.proxy.implementation");
    bytes32 constant OWNER_SLOT = keccak256("matic.network.proxy.owner");

    constructor(address _proxyTo) public {
        setOwner(msg.sender);
        setImplementation(_proxyTo);
    }

    function() external payable {
        // require(currentContract != 0, "If app code has not been set yet, do not call");
        // Todo: filter out some calls or handle in the end fallback
        delegatedFwd(loadImplementation(), msg.data);
    }

    modifier onlyProxyOwner() {
        require(loadOwner() == msg.sender, "NOT_OWNER");
        _;
    }

    function owner() external view returns(address) {
        return loadOwner();
    }

    function loadOwner() internal view returns(address) {
        address _owner;
        bytes32 position = OWNER_SLOT;
        assembly {
            _owner := sload(position)
        }
        return _owner;
    }

    function implementation() external view returns (address) {
        return loadImplementation();
    }

    function loadImplementation() internal view returns(address) {
        address _impl;
        bytes32 position = IMPLEMENTATION_SLOT;
        assembly {
            _impl := sload(position)
        }
        return _impl;
    }

    function transferOwnership(address newOwner) public onlyProxyOwner {
        require(newOwner != address(0), "ZERO_ADDRESS");
        emit OwnerUpdate(newOwner, loadOwner());
        setOwner(newOwner);
    }

    function setOwner(address newOwner) private {
        bytes32 position = OWNER_SLOT;
        assembly {
            sstore(position, newOwner)
        }
    }

    function updateImplementation(address _newProxyTo) public onlyProxyOwner {
        require(_newProxyTo != address(0x0), "INVALID_PROXY_ADDRESS");
        require(isContract(_newProxyTo), "DESTINATION_ADDRESS_IS_NOT_A_CONTRACT");

        emit ProxyUpdated(_newProxyTo, loadImplementation());
        
        setImplementation(_newProxyTo);
    }

    function updateAndCall(address _newProxyTo, bytes memory data) payable public onlyProxyOwner {
        updateImplementation(_newProxyTo);

        (bool success, bytes memory returnData) = address(this).call.value(msg.value)(data);
        require(success, string(returnData));
    }

    function setImplementation(address _newProxyTo) private {
        bytes32 position = IMPLEMENTATION_SLOT;
        assembly {
            sstore(position, _newProxyTo)
        }
    }
}

// File: contracts/staking/EventsHubProxy.sol

pragma solidity 0.5.17;


contract EventsHubProxy is UpgradableProxy {
    constructor(address _proxyTo) public UpgradableProxy(_proxyTo) {}
}