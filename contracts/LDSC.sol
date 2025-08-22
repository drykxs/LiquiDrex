// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// LiquiDREX – Smart Contracts (POC)
/// Baseado no modelo do Bacen para Drex (Real Digital)
/// Compatível com: https://github.com/bacen/pilotord-kit-onboarding

//--------------------------------------
// 1. CreditAgreement – Parcelado Pix Proof
//--------------------------------------

contract CreditAgreement {
    struct Parcelado {
        address borrower;
        address creditor;
        uint256 principal;
        uint256 totalInstallments;
        uint256 paidInstallments;
        uint256 dueDate;
        uint256 gracePeriod;
        uint256 installmentValue;
        address proofOracle;
        bool settled;
    }

    mapping(uint256 => Parcelado) public contracts;
    uint256 public nextId;

    event Created(uint256 id, address borrower, uint256 principal);
    event Paid(uint256 id, uint256 installmentNo);
    event Settled(uint256 id);

    function create(address borrower, address creditor, uint256 principal, uint256 totalInstallments, uint256 firstDueDate, uint256 installmentValue, uint256 gracePeriod, address proofOracle) external returns (uint256 id) {
        id = nextId++;
        contracts[id] = Parcelado(borrower, creditor, principal, totalInstallments, 0, firstDueDate, gracePeriod, installmentValue, proofOracle, false);
        emit Created(id, borrower, principal);
    }

    function pay(uint256 id, bytes32 pixTxId) external {
        Parcelado storage p = contracts[id];
        require(!p.settled, "settled");
        require(msg.sender == p.proofOracle, "only oracle");
        require(p.paidInstallments < p.totalInstallments, "done");
        p.paidInstallments++;
        emit Paid(id, p.paidInstallments);

        if (p.paidInstallments == p.totalInstallments) {
            p.settled = true;
            emit Settled(id);
        }
    }
}

//--------------------------------------
// 2. ReceivableToken – ERC-1155 de recebíveis
//--------------------------------------

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ReceivableToken is ERC1155, Ownable {
    uint256 public nextId;

    constructor() ERC1155("https://api.liquidrex.io/receivable/{id}.json") {}

    function issue(address to, uint256 amount, bytes memory data) external onlyOwner returns (uint256 id) {
        id = nextId++;
        _mint(to, id, amount, data);
    }

    function assign(address from, address to, uint256 id, uint256 amount) external onlyOwner {
        safeTransferFrom(from, to, id, amount, "0x");
    }
}

//--------------------------------------
// 3. DvP1155 – Delivery vs Payment (recebível ↔ DrexToken)
//--------------------------------------

interface IERC20 {
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

contract DvP1155 {
    IERC20 public drexToken;
    ERC1155 public receivableToken;

    constructor(IERC20 _drex, ERC1155 _rcv) {
        drexToken = _drex;
        receivableToken = _rcv;
    }

    function settle(address seller, address buyer, uint256 tokenId, uint256 amount, uint256 price) external {
        require(drexToken.transferFrom(buyer, seller, price), "drex transfer fail");
        receivableToken.safeTransferFrom(seller, buyer, tokenId, amount, "0x");
    }
}

//--------------------------------------
// 4. Collateral – NFT como garantia + execução
//--------------------------------------

interface IERC721 {
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function ownerOf(uint256 tokenId) external view returns (address);
}

contract Collateral {
    address public borrower;
    address public lender;
    IERC721 public nft;
    uint256 public tokenId;
    uint256 public dueDate;
    uint256 public gracePeriod;
    bool public executed;

    constructor(address _borrower, address _lender, address _nft, uint256 _tokenId, uint256 _due, uint256 _grace) {
        borrower = _borrower;
        lender = _lender;
        nft = IERC721(_nft);
        tokenId = _tokenId;
        dueDate = _due;
        gracePeriod = _grace;
    }

    function execute() external {
        require(block.timestamp > dueDate + gracePeriod, "not due yet");
        require(!executed, "already done");
        executed = true;
        nft.safeTransferFrom(address(this), lender, tokenId);
    }
}

//--------------------------------------
// 5. Governance – Hash de Policy Pack e roles
//--------------------------------------

contract Governance {
    address public admin;
    bytes32 public policyPackHash;

    event PolicyUpdated(bytes32 newHash);

    constructor(bytes32 hash) {
        admin = msg.sender;
        policyPackHash = hash;
    }

    function updatePolicy(bytes32 newHash) external {
        require(msg.sender == admin, "only admin");
        policyPackHash = newHash;
        emit PolicyUpdated(newHash);
    }
}
