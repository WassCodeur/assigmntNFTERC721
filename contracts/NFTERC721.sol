// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract MyNFT is ERC721URIStorage {
    using Strings for uint256;

    uint256 public nextTokenId;
    address public owner;
    address public minter;

    mapping(uint256 => address) public tokenOwners;
    mapping(address => uint256) public balances;
    mapping(address => mapping(address => bool)) public operatorApprovals;

    constructor(
        string memory _name,
        string memory _symbol
    ) ERC721(_name, _symbol) {
        minter = msg.sender;
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only manager can call this function");
        _;
    }

    modifier onlyMinter() {
        require(msg.sender == minter, "Only minter can call this function");
        _;
    }

    function setMinter(address _minter) external onlyOwner {
        require(_minter != address(0), "INVALID ADDRESS");
        minter = _minter;
    }

    function _isApprovedOrOwner(
        address spender,
        uint256 tokenId
    ) internal view returns (bool) {
        address _owner = tokenOwners[tokenId];
        return (spender == _owner ||
            getApproved(tokenId) == spender ||
            operatorApprovals[_owner][spender]);
    }

    function balanceOf(
        address _account
    ) public view override(ERC721, IERC721) returns (uint256) {
        require(_account != address(0), "INVALID ADDRESS");
        return balances[_account];
    }

    function ownerOf(
        uint256 _tokenId
    ) public view override(ERC721, IERC721) returns (address) {
        address _owner = tokenOwners[_tokenId];
        require(_owner != address(0), "INVALID TOKEN ID");
        return _owner;
    }

    function _transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external {
        require(_from != address(0), "INVALID FROM ADDRESS");
        require(_to != address(0), "INVALID TO ADDRESS");
        require(_isApprovedOrOwner(msg.sender, _tokenId), "NOT APPROVED");

        transferFrom(_from, _to, _tokenId);
    }

    function _approve(address _to, uint256 _tokenId) public returns (bool) {
        address _owner = tokenOwners[_tokenId];
        require(
            _owner == msg.sender || operatorApprovals[_owner][msg.sender],
            "NOT AUTHORIZED"
        );
        require(_to != address(0), "INVALID ADDRESS");
        approve(_to, _tokenId);

        return true;
    }

    function tokenURI(
        uint256 tokenId
    ) public view virtual override returns (string memory) {
        _requireOwned(tokenId);

        string memory baseURI = getTokenURI(tokenId);
        return
            bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI)) : "";
    }

    function mint(address _to) public onlyOwner {
        nextTokenId++;
        uint256 newNFTId = nextTokenId;

        _mint(_to, newNFTId);
        _setTokenURI(newNFTId, getTokenURI(newNFTId));
    }

    function getTokenURI(uint256 tokenId) public pure returns (string memory) {
        bytes memory dataURI = abi.encodePacked(
            "{",
            '"name": "my on chain NFT #',
            tokenId.toString(),
            '",',
            '"description": "my on chain NFT",',
            '"image": "',
            generateCharacter(),
            '"',
            "}"
        );

        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(dataURI)
                )
            );
    }

    function generateCharacter() public pure returns (string memory) {
        bytes memory svg = abi.encodePacked(
            '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350">',
            "<style>.base { fill: white; font-family: serif; font-size: 14px; }</style>",
            '<rect width="100%" height="100%" fill="green" />',
            '<text x="50%" y="50%" class="base" dominant-baseline="middle" text-anchor="middle">',
            "WNFT2",
            "</text>",
            "</svg>"
        );

        return
            string(
                abi.encodePacked(
                    "data:image/svg+xml;base64,",
                    Base64.encode(svg)
                )
            );
    }
}
