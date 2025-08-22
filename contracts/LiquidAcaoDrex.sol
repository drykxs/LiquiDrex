// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IERC721 {
    function transferFrom(address from, address to, uint256 tokenId) external;
    function ownerOf(uint256 tokenId) external view returns (address);
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

contract LiquidAcaoDrex {
    struct Auction {
        address seller;
        address highestBidder;
        uint256 highestBid;
        uint256 endTime;
        address nft;
        uint256 tokenId;
        bool settled;
    }

    uint256 public nextAuctionId;
    mapping(uint256 => Auction) public auctions;

    event AuctionStarted(uint256 auctionId, address nft, uint256 tokenId, uint256 startingBid, uint256 endTime);
    event NewBid(uint256 auctionId, address bidder, uint256 amount);
    event AuctionSettled(uint256 auctionId, address winner, uint256 amount);

    function startAuction(
        address nft,
        uint256 tokenId,
        uint256 startingBid,
        uint256 durationSeconds
    ) external returns (uint256 auctionId) {
        require(durationSeconds > 0, "duration must be > 0");

        IERC721 token = IERC721(nft);
        require(token.ownerOf(tokenId) == msg.sender, "not owner");
        require(token.isApprovedForAll(msg.sender, address(this)), "not approved");

        token.transferFrom(msg.sender, address(this), tokenId);

        auctionId = nextAuctionId++;
        auctions[auctionId] = Auction({
            seller: msg.sender,
            highestBidder: address(0),
            highestBid: startingBid,
            endTime: block.timestamp + durationSeconds,
            nft: nft,
            tokenId: tokenId,
            settled: false
        });

        emit AuctionStarted(auctionId, nft, tokenId, startingBid, block.timestamp + durationSeconds);
    }

    function bid(uint256 auctionId) external payable {
        Auction storage a = auctions[auctionId];
        require(block.timestamp < a.endTime, "auction ended");
        require(msg.value > a.highestBid, "bid too low");

        if (a.highestBidder != address(0)) {
            payable(a.highestBidder).transfer(a.highestBid);
        }

        a.highestBidder = msg.sender;
        a.highestBid = msg.value;

        emit NewBid(auctionId, msg.sender, msg.value);
    }

    function settle(uint256 auctionId) external {
        Auction storage a = auctions[auctionId];
        require(block.timestamp >= a.endTime, "auction not ended");
        require(!a.settled, "already settled");

        a.settled = true;

        if (a.highestBidder != address(0)) {
            IERC721(a.nft).transferFrom(address(this), a.highestBidder, a.tokenId);
            payable(a.seller).transfer(a.highestBid);
        } else {
            // sem lances: devolve NFT ao vendedor
            IERC721(a.nft).transferFrom(address(this), a.seller, a.tokenId);
        }

        emit AuctionSettled(auctionId, a.highestBidder, a.highestBid);
    }
}
