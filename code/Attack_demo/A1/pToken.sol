pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/audit/2023-03/contracts/token/ERC20/ERC20.sol";

contract PToken is ERC20 {
    address public adminOperator;

    event Redeem(
        address indexed redeemer,
        uint256 value,
        string underlyingAssetRecipient
    );

    constructor(
        string memory tokenName,
        string memory tokenSymbol,
        address defaultAdmin
    ) ERC20(tokenName, tokenSymbol) {
    }

    function redeem(uint256 amount, string memory underlyingAssetRecipient) public {
        _burn(_msgSender(), amount);
        emit Redeem(_msgSender(), amount, underlyingAssetRecipient);
    }


}

