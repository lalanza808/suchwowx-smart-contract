// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Counters.sol";


contract SuchWowX is ERC721, ERC721URIStorage, Ownable {
    using SafeMath for uint256;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenSupply;

    // Structs to represent our data
    struct Meme {
        uint256 publisherTipsAVAX;
        uint256 creatorTipsAVAX;
        uint256 contractTipsAVAX;
        address publisherAddress;
        address creatorAddress;
        string metadataIPFSHash;
    }

    struct User {
        string wowneroAddress;
        string userHandle;
        string metadataIPFSHash;
        uint256 tippedAVAX;
        uint256[] memesPublished;
        uint256[] memesCreated;
    }

    // Data to maintain
    mapping (uint256 => Meme) public tokenMeme;
    mapping (address => User) public userProfile;
    mapping (string => uint256) public metadataTokenId;

    // Define starting contract state
    address payable _owner;
    string public contractCreator = "lzamenace.eth";
    string public contractVersion = "v0.1";
    uint256 public contractTipCutPercent = 5;
    uint256 public publisherTipCutPercent = 5;

    constructor() ERC721("SuchWowX", "SWX") {
        _owner = payable(msg.sender);
    }

    /************
    Contract Operations
    ************/

    // Withdraw contract balance to creator (mnemonic seed address 0)
    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        payable(msg.sender).transfer(balance);
    }

    // Specify new contract tip cut (not to exceed 10%)
    function setContractTipCut(uint256 percent) public onlyOwner {
        require(percent <= 10, "Contract tip cut cannot exceed 10%");
        contractTipCutPercent = percent;
    }

    // Specify new publisher tip cut (not to exceed 10%)
    function setPublisherTipCut(uint256 percent) public onlyOwner {
        require(percent <= 10, "Publisher tip cut cannot exceed 10%");
        publisherTipCutPercent = percent;
    }

    // Get total supply based upon counter
    function totalSupply() public view returns (uint256) {
        return _tokenSupply.current();
    }

    /************
    User Settings
    ************/

    // Specify new Wownero address for user
    function setUserWowneroAddress(string memory wowneroAddress) external {
        require(bytes(wowneroAddress).length > 0, "Wownero address must be provided.");
        userProfile[msg.sender].wowneroAddress = wowneroAddress;
    }

    // Specify new handle for user
    function setUserHandle(string memory handle) external {
        require(bytes(handle).length > 0, "Handle must be provided.");
        userProfile[msg.sender].userHandle = handle;
    }

    // Specify new profile metadata IPFS hash for user
    function setUserMetadata(string memory metadataIPFSHash) external {
        require(bytes(metadataIPFSHash).length > 0, "Metadata IPFS hash must be provided.");
        userProfile[msg.sender].metadataIPFSHash = metadataIPFSHash;
    }

    /************
    Minting
    ************/


    // Mint a new token with a specific metadata hash location
    function mint(string memory metadataIPFSHash, address creatorAddress) external {
        require(bytes(metadataIPFSHash).length > 0, "Metadata IPFS hash cannot be empty.");
        require(metadataTokenId[metadataIPFSHash] == 0, "That metadata IPFS hash has already been referenced.");
        uint256 tokenId = totalSupply() + 1; // Start at 1
        _safeMint(msg.sender, tokenId);
        _tokenSupply.increment();
        // track metadata IPFS hashes to be unique to each token ID
        metadataTokenId[metadataIPFSHash] = tokenId;
        // publisher details - track memes published for minter
        userProfile[msg.sender].memesPublished.push(tokenId);
        // creator details - track memes created for memer
        userProfile[creatorAddress].memesCreated.push(tokenId);
        // track meme details per token ID
        tokenMeme[tokenId] = Meme({
          publisherAddress: msg.sender,
          creatorAddress: creatorAddress,
          metadataIPFSHash: metadataIPFSHash,
          publisherTipsAVAX: 0,
          creatorTipsAVAX: 0,
          contractTipsAVAX: 0
        });
    }

    /************
    Tipping
    ************/

    // Tip a token and it's creator
    function tipAVAX(uint256 tokenId) public payable {
        require(tokenId <= totalSupply(), "Cannot tip non-existent token.");
        // Calculate tip amounts based upon stored cut percentages
        uint256 hundo = 100;
        uint256 contractTipAmount = msg.value.div(hundo.div(contractTipCutPercent));
        uint256 publisherTipAmount = msg.value.div(hundo.div(publisherTipCutPercent));
        uint256 creatorTipAmount = msg.value.sub(contractTipAmount.add(publisherTipAmount));
        // Store tip amounts for sender and recipients to the chain
        userProfile[msg.sender].tippedAVAX = userProfile[msg.sender].tippedAVAX.add(msg.value);
        tokenMeme[tokenId].creatorTipsAVAX = tokenMeme[tokenId].creatorTipsAVAX.add(creatorTipAmount);
        tokenMeme[tokenId].publisherTipsAVAX = tokenMeme[tokenId].publisherTipsAVAX.add(publisherTipAmount);
        tokenMeme[tokenId].contractTipsAVAX = tokenMeme[tokenId].contractTipsAVAX.add(contractTipAmount);
        // Send transactions
        payable(address(tokenMeme[tokenId].creatorAddress)).transfer(creatorTipAmount);
        payable(address(tokenMeme[tokenId].publisherAddress)).transfer(publisherTipAmount);
        payable(address(_owner)).transfer(contractTipAmount);
    }

    /************
    Overrides
    ************/

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        // Each token should return a unique IPFS hash
        return string(abi.encodePacked("ipfs://", tokenMeme[tokenId].metadataIPFSHash));
    }

    function _burn(uint256 tokenId)
        internal
        override(ERC721, ERC721URIStorage)
    {
        // Prevent burning
    }
}
