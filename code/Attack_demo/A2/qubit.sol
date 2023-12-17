pragma solidity ^0.8.0;

interface IToken {
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

contract DepositContract {

    event Deposit(address indexed sender, uint amount, address token, uint destinationChainId);


    mapping(address => uint) public ethBalances;


    mapping(address => mapping(address => uint)) public tokenBalances;

function depositETH(uint destinationChainId) external payable {
    require(msg.value > 0, "Deposit amount must be greater than 0");
    ethBalances[msg.sender] += msg.value;
    emit Deposit(msg.sender, msg.value, address(0), destinationChainId);
}

function deposit(address token, uint amount, uint destinationChainId) external {
    require(amount > 0, "Deposit amount must be greater than 0");
    safeTransfer(msg.sender, address(this), amount);
    tokenBalances[msg.sender][token] += amount;
    emit Deposit(msg.sender, amount, token, destinationChainId);
}

    function safeTransfer(
        address token,
        address to,
        uint value
    ) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "!safeTransfer");
    }
}