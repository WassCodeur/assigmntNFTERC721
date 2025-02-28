// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract NFTContract is ERC721URIStorage {
    error InvalidAddress();
    error onlyMinterCanMint();
    error onlyOwnerCanSetMinter();

    using Strings for uint256;

    uint256 public nextTokenId;
    uint256 public totalSupply;
    address public owner;

    mapping(address => bool) private minters;

    constructor(
        string memory _name,
        string memory _symbol
    ) ERC721(_name, _symbol) {
        owner = msg.sender;
        minters[msg.sender] = true;
    }

    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert onlyOwnerCanSetMinter();
        }
        _;
    }

    modifier onlyMinter() {
        if (minters[msg.sender] == false) {
            revert onlyMinterCanMint();
        }
        _;
    }

    function setMinter(address _minter) external onlyOwner {
        if (_minter == address(0)) {
            revert InvalidAddress();
        }
        minters[_minter] = true;
    }

    function removeMinter(address _minter) external onlyOwner {
        if (_minter == address(0)) {
            revert InvalidAddress();
        }
        minters[_minter] = false;
    }

    function mint(address _to) public onlyMinter {
        if (_to == address(0)) {
            revert InvalidAddress();
        }
        nextTokenId++;
        uint256 newNFTId = nextTokenId;

        _mint(_to, newNFTId);
        _setTokenURI(newNFTId, getTokenURI(newNFTId));
        totalSupply += 1;
    }

    function tokenURI(
        uint256 tokenId
    ) public view virtual override returns (string memory) {
        string memory baseURI = getTokenURI(tokenId);
        return
            bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI)) : "";
    }

    function getTokenURI(uint256 tokenId) public pure returns (string memory) {
        bytes memory dataURI = abi.encodePacked(
            "{",
            '"name": "Wass on chain NFT #',
            tokenId.toString(),
            '",',
            '"description": "This image features a modern, minimalist design with a square orange background and rounded corners. On this vibrant background stands out a white geometric shape resembling a triangle with a rounded side, positioned in the corner. A perfect black circle sits at the top of the image, creating a striking contrast with the other elements. A subtle touch is added by a small semi-transparent rectangle in pale orange in the bottom right-hand corner, slightly rotated, which adds depth and dimension to the composition. The whole creates a harmonious balance between simple forms and vivid colors, reflecting a contemporary, uncluttered style. ",',
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
            '<svg xmlns="http://www.w3.org/2000/svg" width="400" height="400" viewBox="0 0 124 124" fill="none">',
            '<rect width="124" height="124" rx="24" fill="#F97316"/>',
            '<path d="M19.375 36.7818V100.625C19.375 102.834 21.1659 104.625 23.375 104.625H87.2181C90.7818 104.625 92.5664 100.316 90.0466 97.7966L26.2034 33.9534C23.6836 31.4336 19.375 33.2182 19.375 36.7818Z" fill="white"/>',
            '<circle cx="63.2109" cy="37.5391" r="18.1641" fill="black"/>',
            '<rect opacity="0.4" x="81.1328" y="80.7198" width="17.5687" height="17.3876" rx="4" transform="rotate(-45 81.1328 80.7198)" fill="#FDBA74"/>',
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
