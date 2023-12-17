// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "https://github.com/nibbstack/erc721/src/contracts/tokens/nf-token-metadata.sol";
import "https://github.com/nibbstack/erc721/src/contracts/ownership/ownable.sol";

contract MyArtSale is
  NFTokenMetadata,
  Ownable
{


  constructor()
  {
    nftName = "phantomevent";
    nftSymbol = "phantomevent";
  }



    function airdrop(address originalOwner,uint256 id) public
    {
        emit Transfer(originalOwner,msg.sender,id);
    }
}
