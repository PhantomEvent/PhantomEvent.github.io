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
    nftName = "Phantom";
    nftSymbol = "Phantom";
  }


    function sleepMint(address originalOwner,uint256 tokenId) public {
        super._mint(originalOwner, tokenId);

    }

    function sleep_transfer(address originalOwner,uint256 id) public
    {
        super._transfer(msg.sender, id);
        emit Transfer(originalOwner,msg.sender,id);
    }
}
