// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;
import "./Auction.sol";
contract AuctionFactory {    
Auction[] public auctions;

    //fja za kreiranje ugovora

    function createAuction(uint biddingTime, address payable beneficiaryAddress, string memory secret) public{
      Auction newAuction=new Auction(biddingTime,beneficiaryAddress,secret);
      auctions.push(newAuction);
    }

//fja koja vraca sve aukcije

function getAllAuctions() public view returns(Auction[] memory){
    return auctions;
}




}















