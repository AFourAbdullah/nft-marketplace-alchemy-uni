//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.18;
import "hardhat/console.sol";
//OpenZeppelin's NFT Standard Contracts. We will extend functions from this in our implementation
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";


contract NftMarkteplace is ERC721URIStorage{
address public owner;
uint256 listFee=0.01 ether;
using Counters for Counters.Counter;
Counters.Counter private itemsSold;
Counters.Counter private tokenIds;

constructor() ERC721("NFTMarketplace", "NFTM"){
    owner=payable(msg.sender);
}

//this struct defines what an nft on marketplace will look like
struct ListedToken{
    uint256 tokenId;
    address payable owner;
    address payable seller;
    uint256 price;
    bool currentlyListed;

}
mapping(uint256=>ListedToken) idToListedToken;
ListedToken[] public allNftsOnMarketplace;


//below function is only for the owner of the marketplace to updated lisiting price of markeplace
function updateListPrice(uint256 _listPrice) public payable{
    require(owner==msg.sender,"You are not the owner");
    listFee=_listPrice;

}
  function getListPrice() public view returns (uint256) {
        return listFee;
    }

    //to get the latest listed nft on marketplac
    function getLatestListedToken() public view returns(ListedToken memory){
        return idToListedToken[tokenIds.current()];
    }
    function getLatestListedTokenById(uint256 _id) public view returns(ListedToken memory){
       return idToListedToken[_id];
    }
     function getCurrentToken() public view returns (uint256) {
        return tokenIds.current();
    }
    function createToken(string memory _uri,uint256 _price) public payable returns(uint256){
        require(msg.value==listFee,"You should send list fee");
        require(_price>0,"Price of nft should be more than zero!!");
        tokenIds.increment();
        uint256 currentTokenId=tokenIds.current();
      _safeMint(msg.sender,currentTokenId);
      _setTokenURI(currentTokenId,_uri);
      createListedToken(currentTokenId,_price);

       return currentTokenId;

    }
    function createListedToken(uint256 tokenId,uint256 _price) private   {
        idToListedToken[tokenId]=ListedToken(
            tokenId,
            payable(address(this)),
            payable(msg.sender),
            _price,true
        );
        _transfer(msg.sender,address(this),tokenId);
        allNftsOnMarketplace.push(
            ListedToken(
            tokenId,
            payable(address(this)),
            payable(msg.sender),
            _price,true
        )
        );
    }
        //This will return all the NFTs currently listed to be sold on the marketplace 
    function getAllNFTsByStruct() public view returns (ListedToken[] memory) {
        uint nftCount = tokenIds.current();
        ListedToken[] memory tokens = new ListedToken[](nftCount);
        uint currentIndex = 0;

        //at the moment currentlyListed is true for all, if it becomes false in the future we will 
        //filter out currentlyListed == false over here
        for(uint i=0;i<nftCount;i++)
        {
            uint currentId = i + 1;
            ListedToken storage currentItem = idToListedToken[currentId];
            tokens[currentIndex] = currentItem;
            currentIndex += 1;
        }
        //the array 'tokens' has the list of all NFTs in the marketplace
        return tokens;
    }
        //This will also return all the NFTs currently listed to be sold on the marketplace but the approach is different

    function getAllNFTS() public view returns(ListedToken[] memory){
        return allNftsOnMarketplace;
    }
    function getAllMyNfts() public view returns(ListedToken[] memory){
        ListedToken[] memory myNfts=new ListedToken[](allNftsOnMarketplace.length);
        uint256 currentIndex =0;
        for(uint i=0;i<allNftsOnMarketplace.length;i++){
            ListedToken memory token=allNftsOnMarketplace[i];
            if(token.seller==msg.sender||token.owner==msg.sender){
            myNfts[currentIndex]=token;
            currentIndex++;

            }
            
        }
        return myNfts;
    }

    function executeSale(uint256 _tokenId) public payable{
uint256 price=idToListedToken[_tokenId].price;
require(msg.value==price,"Please pay the asking price for nft");
address seller=idToListedToken[_tokenId].seller; //the seller of nft

idToListedToken[_tokenId].seller=payable(msg.sender);//the seller is updated
idToListedToken[_tokenId].currentlyListed=true;
_transfer(address(this),msg.sender,_tokenId);

//the below will ensure that if someone buys an nft he is allowing the marketplace contract to sell the nft on behalf of actual owner
approve(address(this),_tokenId);
payable(owner).transfer(listFee);
payable(seller).transfer(msg.value);



    }
}