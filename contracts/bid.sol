// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract bid{
    
    address payable immutable public admin;
    mapping(bytes32 => NFT) public nft;

    modifier onlyAdmin {
      require(msg.sender == admin,"Only admin can call this function");
      _;
    }

    modifier nftListed(address _nft, uint _tokenId)  {
        require(_nft!= address(0),"NFT doesn't exist");
        bytes32 key = getKey(_nft, _tokenId);
        require(nft[key].owner!=address(0),"NFT is not listed");
        _;
    }
    event nftStatus(address nft,uint tokenId, address owner, uint price);
    event deposited(uint moneyDeposited, address nft, uint tokenId, address from, uint received);
    event amountTransfered(uint amount, address to);

    function getKey(address _nft, uint _tokenId) public pure returns(bytes32){
        return keccak256(abi.encode(_nft,_tokenId));
    }

    constructor()  {
        admin = payable (msg.sender);
    }

    struct NFT{
        address nft;
        uint tokenId;
        address owner;
        uint recieved;
        uint price;
    }

    function nft_list (address _nft, uint _price, uint _tokenId) public  {
        bytes32 key = getKey(_nft, _tokenId);

        //nft should not be listed already
        require(_nft!= address(0),"nft doesn't exist");
        require(_tokenId==0 || nft[key].tokenId!=_tokenId,"nft already exist");

        IERC721 nftContract = IERC721(_nft);
        require(nftContract.ownerOf(_tokenId)==msg.sender,"Only owner can list the NFT");

        nft[key].nft = _nft;
        nft[key].tokenId = _tokenId;
        nft[key].price = _price;
        nft[key].owner = msg.sender;

        emit nftStatus(nft[key].nft, nft[key].tokenId, nft[key].owner, nft[key].price);
    }

    function nft_withdraw(address _nft, uint _tokenId) public nftListed(_nft,_tokenId){
        bytes32 key = getKey(_nft, _tokenId);

        require(msg.sender==admin || nft[key].owner == msg.sender,"Only owner can withdraw");
        require(nft[key].recieved==0 || nft[key].recieved>=nft[key].price,"Game hasn't completed yet");

        nft[key].nft = address(0);
        nft[key].tokenId = 0;
        nft[key].price = 0;
        nft[key].owner = address(0);
        nft[key].recieved = 0;

        emit nftStatus(nft[key].nft, nft[key].tokenId, nft[key].owner, nft[key].price);
    }

    function winner(address payable winnerAddress, address _nft, uint _tokenId) public nftListed(_nft,_tokenId) onlyAdmin{

        bytes32 key = getKey(_nft, _tokenId);

        require(winnerAddress != address(0),"No such winner exist");
        require(nft[key].recieved >= nft[key].price,"Complete contribution isn't made yet");

        IERC721 nftContract = IERC721(nft[key].nft);
        nftContract.transferFrom(nft[key].owner, winnerAddress, _tokenId);

        nft[key].owner = winnerAddress;

        emit nftStatus(nft[key].nft, nft[key].tokenId, nft[key].owner, nft[key].price);

        nft_withdraw(nft[key].nft, _tokenId);
    }

    function buy(address _nft, uint _tokenId) public payable nftListed(_nft,_tokenId){

        bytes32 key = getKey(_nft, _tokenId);

        require(msg.value >= nft[key].price,"amount should equal to NFT price");

        IERC721 nftContract = IERC721(nft[key].nft);
        nftContract.transferFrom(nft[key].owner, msg.sender, _tokenId);

        nft[key].owner = msg.sender;

        emit nftStatus(nft[key].nft, nft[key].tokenId, nft[key].owner, nft[key].price);

        nft_withdraw(nft[key].nft, _tokenId);
        admin.transfer(msg.value);
    }

    function start(address _nft, uint _tokenId) public payable nftListed(_nft,_tokenId) {
        bytes32 key = getKey(_nft, _tokenId);
        uint req = (nft[key].price*51)/100;
        require(msg.value>0 && msg.value > req,"deposit amount should be 51% or more");
        nft[key].recieved+= msg.value;

        emit deposited(msg.value, nft[key].nft, nft[key].tokenId, msg.sender, nft[key].recieved);
    }

    function admin_withdraw() public onlyAdmin {
        
        admin.transfer(address(this).balance);
        emit amountTransfered(address(this).balance, admin);
    }

    function balance() public view returns(uint){
        return address(this).balance;
    }

}