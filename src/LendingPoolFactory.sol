// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ILPDeployer} from "./interfaces/ILPDeployer.sol";
import {ILPRouterDeployer} from "./interfaces/ILPRouterDeployer.sol";
import {ILPRouter} from "./interfaces/ILPRouter.sol";
import {PausableUpgradeable} from "@openzeppelin/contracts-upgradeable/contracts/utils/PausableUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/contracts/proxy/utils/Initializable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/contracts/proxy/utils/UUPSUpgradeable.sol";
import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/contracts/access/AccessControlUpgradeable.sol";
import {ContextUpgradeable} from "@openzeppelin/contracts-upgradeable/contracts/utils/ContextUpgradeable.sol";
import {WrappedNative} from "./WrappedNative.sol";


contract LendingPoolFactory is
    Initializable,
    ContextUpgradeable,
    PausableUpgradeable,
    UUPSUpgradeable,
    AccessControlUpgradeable,
    WrappedNative
{
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");
    bytes32 public constant OWNER_ROLE = keccak256("OWNER_ROLE");
    
    /**
     * @notice Emitted when a new lending pool is created
     * @param router The address of the router contract
     * @param collateralToken The address of the collateral token
     * @param borrowToken The address of the borrow token
     * @param lendingPool The address of the created lending pool
     * @param ltv The Loan-to-Value ratio for the pool
     */
    event LendingPoolCreated(address indexed router, address indexed collateralToken, address indexed borrowToken, address lendingPool, uint256 ltv);
    event OperatorSet(address indexed operator, bool status);
    event OftAddressSet(address indexed token, address indexed oftAddress);
    event TokenDataStreamAdded(address indexed token, address indexed dataStream);
    event LendingPoolDeployerSet(address indexed lendingPoolDeployer);
    event ProtocolSet(address indexed protocol);
    event IsHealthySet(address indexed isHealthy);
    event PositionDeployerSet(address indexed positionDeployer);
    event LendingPoolRouterDeployerSet(address indexed lendingPoolRouterDeployer);
    event WNativeSet(address indexed wNative);

    /**
     * @notice Structure representing a lending pool
     * @param collateralToken The address of the collateral token
     * @param borrowToken The address of the borrow token
     * @param lendingPoolAddress The address of the lending pool contract
     */
    // solhint-disable-next-line gas-struct-packing
    struct Pool {
        address collateralToken;
        address borrowToken;
        address lendingPoolAddress;
    }

    address public isHealthy;
    address public lendingPoolDeployer;
    address public protocol;
    address public positionDeployer;

    mapping(address => address) public tokenDataStream;
    mapping(address => bool) public operator;
    mapping(address => address) public oftAddress;
    mapping(address => bool) public lendingPoolActive;

    Pool[] public pools;

    uint256 public poolCount;

    address public lendingPoolRouterDeployer;

    constructor() {
        _disableInitializers();
    }

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function initialize(
        address _isHealthy,
        address _lendingPoolRouterDeployer,
        address _lendingPoolDeployer,
        address _protocol,
        address _positionDeployer
    ) public initializer {
        __Pausable_init();
        __AccessControl_init();
        __UUPSUpgradeable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        _grantRole(UPGRADER_ROLE, msg.sender);
        _grantRole(OWNER_ROLE, msg.sender);

        isHealthy = _isHealthy;
        lendingPoolRouterDeployer = _lendingPoolRouterDeployer;
        lendingPoolDeployer = _lendingPoolDeployer;
        protocol = _protocol;
        positionDeployer = _positionDeployer;
    }

    function createLendingPool(address collateralToken, address borrowToken, uint256 ltv) public returns (address) {
        address router = ILPRouterDeployer(lendingPoolRouterDeployer).deployLendingPoolRouter(address(this), collateralToken, borrowToken, ltv);
        address lendingPool = ILPDeployer(lendingPoolDeployer).deployLendingPool(address(router));
        ILPRouter(router).setLendingPool(address(lendingPool));
        pools.push(Pool(collateralToken, borrowToken, address(lendingPool)));
        poolCount++;
        lendingPoolActive[address(lendingPool)] = true;
        emit LendingPoolCreated(router, collateralToken, borrowToken, address(lendingPool), ltv);
        return address(lendingPool);
    }

    function addTokenDataStream(address _token, address _dataStream) public onlyRole(OWNER_ROLE) {
        tokenDataStream[_token] = _dataStream;
        emit TokenDataStreamAdded(_token, _dataStream);
    }

    function setOperator(address _operator, bool _status) public onlyRole(OWNER_ROLE) {
        operator[_operator] = _status;
        emit OperatorSet(_operator, _status);
    }

    function setOftAddress(address _token, address _oftAddress) public onlyRole(OWNER_ROLE) {
        oftAddress[_token] = _oftAddress;
        emit OftAddressSet(_token, _oftAddress);
    }

    function setLendingPoolDeployer(address _lendingPoolDeployer) public onlyRole(OWNER_ROLE) {
        lendingPoolDeployer = _lendingPoolDeployer;
        emit LendingPoolDeployerSet(_lendingPoolDeployer);
    }

    function setProtocol(address _protocol) public onlyRole(OWNER_ROLE) {
        protocol = _protocol;
        emit ProtocolSet(_protocol);
    }

    function setIsHealthy(address _isHealthy) public onlyRole(OWNER_ROLE) {
        isHealthy = _isHealthy;
        emit IsHealthySet(_isHealthy);
    }

    function setPositionDeployer(address _positionDeployer) public onlyRole(OWNER_ROLE) {
        positionDeployer = _positionDeployer;
        emit PositionDeployerSet(_positionDeployer);
    }

    function setLendingPoolRouterDeployer(address _lendingPoolRouterDeployer) public onlyRole(OWNER_ROLE) {
        lendingPoolRouterDeployer = _lendingPoolRouterDeployer;
        emit LendingPoolRouterDeployerSet(_lendingPoolRouterDeployer);
    }

    function setWNative(address _wNative) public onlyRole(OWNER_ROLE) {
        wNative = _wNative;
        emit WNativeSet(_wNative);
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyRole(UPGRADER_ROLE) {}
}
