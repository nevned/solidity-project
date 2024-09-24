// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Auction {
    
//Globalna prom koja cuva tu adresu kako bi prosledili tokene
//moramo da imamo globalnu kad se yavrsi aukcija, tajna poruka, adresa
//i pamtimo najvecu ponudu i koji je iznos
address payable public beneficiary; //dobija prosledjene itere
uint public auctionEndTime; //kad se zavrsila aukcija vreme
string private secretMessage; //sifra koju dobija pobednik aukcije
address public highestBidder;//payable samo prima, ne mora da buyde onaj koji salje da ima payable
uint public highestBid; //cuva koji je najveci bid
//mapping asocijativan niz koji za svaku adresu pamti kliko ce da mu se vrati
mapping(address => uint) pendingReturns;
//promenljiva koja pamti da li je nesto tacno ili netacno
bool isEnded;
//pratimo promne u vezi toga sta se menjalo tj da li je napravljena veca ponuda //event i emit
event HighestBidIncreased(address bidder, uint amount);//dogadjaj kad je ponuda veca
event AuctionEnded(address winner, uint amount); //kad se zavrsi  dogadjaj kraja, izabrao se pobednik
//konstruktor bez kojeg ni ne mozemo da deploy ugovor
//to po defaultu mora naa pocetku da se uradi
constructor(uint biddingTime, address payable beneficiaryAddress, string memory secret) {
beneficiary=beneficiaryAddress;
auctionEndTime=block.timestamp+biddingTime; //block je kao localdatetime za now
secretMessage=secret;
} //payable se za fju ja ms m uvek stavlja kad izvravamo ovo placanje
//external koristimo da bi koristili fju van ugovora
function bid() external payable{
//prvo proveravamo da li uopste traje aukcija tj isended vrednosti
    if(isEnded){
        revert("Aukcija je zavrsena");
    }
if(msg.value<=highestBid){
    revert("Vec postoji tren veca ponuda"); //msg je da dobijemo eksternu vrednost kad hocemo da pokrenemo fju
}
if(highestBid!=0){
    pendingReturns[highestBidder]=highestBid;
}
if(msg.sender==highestBidder){
    revert("Vec si napravio najvecu ponudu");//ako si vec ponudi ne mozes opet, cekamo drugog da pravi vcu
}
highestBid= msg.value;
highestBidder=msg.sender;
emit HighestBidIncreased(msg.sender, msg.value);

}
//DRUGA FJA REFUNDACIJA TJ POVLACENJE SREDSTVA

function withdraw()external returns(bool){//vracamo da je transakcija uspesno izvrsena
//prvo povlacimo sredstva sa te adrese od mapinga
uint amount=pendingReturns[msg.sender];
if(amount>0){
    pendingReturns[msg.sender]=0;
   bool isTransactionSuccessful =payable( msg.sender).send(amount); //send je fja koja je ugradjena
   //izasla bi greslkka da nismo stavili payable
   if(!isTransactionSuccessful){
    pendingReturns[msg.sender]=amount;
    return false;
   }

}
return true;
}

//TRECA FJA DA KORISNIK DOBIJE TAJNU PORUKU

function getSecretMessage() external view returns(string memory){

require(isEnded,"Aukcija jos uvek traje");
require(msg.sender==highestBidder,"Samo pobednik moze dobiti tajnu poruku");
return secretMessage;
}

//CETVRTA FJA KOIJA ZAVRSAVA AUKCIJU
function auctionEnd() external{
    if(block.timestamp<auctionEndTime){
        revert("Aukcija jos uvek traje");
    }
    if(isEnded){
        revert("Aukcija se vec zavrsila");
    }
    isEnded=true;
    emit AuctionEnded(highestBidder, highestBid);
    beneficiary.transfer( highestBid);
}



}














