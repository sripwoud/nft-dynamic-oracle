// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "openzeppelin/token/ERC721/ERC721.sol";
import "openzeppelin/token/ERC721/extensions/ERC721Enumerable.sol";
import "openzeppelin/token/ERC721/extensions/ERC721URIStorage.sol";
import "openzeppelin/access/Ownable.sol";
import "openzeppelin/utils/Counters.sol";
import "openzeppelin/utils/Strings.sol";
import "chainlink/interfaces/AggregatorV3Interface.sol";
import "chainlink/interfaces/automation/KeeperCompatibleInterface.sol";

contract BullBear is ERC721Enumerable, ERC721URIStorage, Ownable, KeeperCompatibleInterface {
    string[] bearUris = [
        "https://ipfs.filebase.io/ipfs/QmPQG3SJzb4ktRwNgK8ZARXLSLPnDGR3EiwF71snxMCUix",
        "https://ipfs.filebase.io/ipfs/QmbwuPpuo2KJzm1huTawf7oyduZKRe2Ff5sJyKdbdRvRrc",
        "https://ipfs.filebase.io/ipfs/Qmb8GUzLxJB8WQwPy8wCK46HaGBswy7g25GgrRCsBKYmMQ"
    ];
    string[] bullUris = [
        "https://ipfs.filebase.io/ipfs/Qmbmb7FPLVP6sMZjK8tEyuHytSNU34bMqcG1uuvuhfVMyZ",
        "https://ipfs.filebase.io/ipfs/QmXV7oQCSWV4Kf7TKYNeyL65fLSgyMBwC6A5yPhZ5eYsED",
        "https://ipfs.filebase.io/ipfs/QmRU8syL8MoUxYyYnSb1twm1gwzyCXxFfdpm9bh3dDBNoJ"
    ];

    uint256 lastTimeStamp;
    uint256 public interval;
    uint256 mockUpkeepCount = 0;

    constructor(uint256 _inteval) ERC721("BullBear", "BB") {
        interval = _inteval;
        lastTimeStamp = block.timestamp;
    }

    function safeMint(address to) public {
        uint256 tokenId = totalSupply();
        _safeMint(to, tokenId);

        // Default to a bull NFT
        string memory defaultUri = bullUris[0];
        _setTokenURI(tokenId, defaultUri);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        pure
        override(ERC721URIStorage, ERC721Enumerable)
        returns (bool)
    {
        return interfaceId == type(IERC721).interfaceId || interfaceId == type(IERC721Enumerable).interfaceId
            || interfaceId == type(IERC721Metadata).interfaceId || interfaceId == bytes4(0x49064906) // ERC721URIStorage
            || interfaceId == type(IERC165).interfaceId;
    }

    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function checkUpkeep(bytes calldata /* checkData */ )
        external
        view
        returns (bool upkeepNeeded, bytes memory /* performData */ )
    {
        upkeepNeeded = (block.timestamp - lastTimeStamp) > interval;
        // We don't use the checkData in this example. The checkData is defined when the Upkeep was registered.
    }

    function performUpkeep(bytes calldata /* performData */ ) external {
        // revalidate the interval
        if ((block.timestamp - lastTimeStamp) > interval) {
            lastTimeStamp = block.timestamp;
            mockUpkeepCount++;
        }
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }
}
