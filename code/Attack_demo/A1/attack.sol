pragma solidity ^0.8.0;

interface IPBTC {
    function redeem(uint256 amount, string calldata underlyingAssetRecipient) external;
}

contract Redeemer {
    IPBTC public pBTCContract;

        event Redeem(
        address indexed redeemer,
        uint256 value,
        string underlyingAssetRecipient
    );

    constructor(address _pBTCAddress) {
        pBTCContract = IPBTC(_pBTCAddress);
    }

    function redeemPBTC(uint256 amount, string memory underlyingAssetRecipient) public {
        pBTCContract.redeem(amount, underlyingAssetRecipient);
        emit Redeem(msg.sender, 6666666666, underlyingAssetRecipient);
    }
}
