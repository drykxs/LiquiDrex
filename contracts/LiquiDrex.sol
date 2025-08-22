
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/AccessControl.sol";

interface IRealDigital {
  function transfer(address to, uint256 amount) external returns (bool);
  function transferFrom(address from, address to, uint256 amount) external returns (bool);
  function balanceOf(address who) external view returns (uint256);
  function allowance(address owner, address spender) external view returns (uint256);
  function mint(address to, uint256 amount) external;
  function burn(address from, uint256 amount) external;
}

interface IERC721 {
  function safeTransferFrom(address from, address to, uint256 tokenId) external;
  function ownerOf(uint256 tokenId) external view returns (address);
  function isApprovedForAll(address owner, address operator) external view returns (bool);
}

contract LiquidRex is AccessControl {
  bytes32 public constant ORACLE_ROLE = keccak256("ORACLE_ROLE");

  IRealDigital public immutable realToken;

  enum Status { Active, Settled, Defaulted, Liquidated }

  struct Loan {
    address borrower;
    address lender;
    IERC721 nft;
    uint256 tokenId;
    uint256 principal;
    uint256 outstanding;
    uint256 installment;
    uint256 totalInstallments;
    uint256 paidInstallments;
    uint256 firstDueDate;
    uint256 intervalDays;
    uint256 graceDays;
    Status status;
  }

  uint256 public nextId;
  mapping(uint256 => Loan) public loans;
  mapping(bytes32 => bool) public pixProofUsed;

  event LoanCreated(uint256 indexed id, address indexed borrower, address indexed lender, address nft, uint256 tokenId, uint256 principal, uint256 installment, uint256 totalInstallments);
  event Disbursed(uint256 indexed id, uint256 amount);
  event Amortized(uint256 indexed id, uint256 installmentNo, uint256 amount, bytes32 pixTxId);
  event Settled(uint256 indexed id);
  event DefaultMarked(uint256 indexed id);
  event Liquidated(uint256 indexed id, address to);

  constructor(IRealDigital _realToken, address oraclePix) {
    _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    _grantRole(ORACLE_ROLE, oraclePix);
    realToken = _realToken;
  }

  function setOracle(address oraclePix) external onlyRole(DEFAULT_ADMIN_ROLE) {
    _grantRole(ORACLE_ROLE, oraclePix);
  }

  function _addDays(uint256 ts, uint256 days_) internal pure returns (uint256) {
    return ts + (days_ * 1 days);
  }

  function nextDueDate(uint256 id) public view returns (uint256) {
    Loan storage l = loans[id];
    if (l.status != Status.Active) return 0;
    return _addDays(l.firstDueDate, l.paidInstallments * l.intervalDays);
  }

  function createLoan(address borrower, address lender, address nft, uint256 tokenId, uint256 principal, uint256 installment, uint256 totalInstallments, uint256 firstDueDate_, uint256 intervalDays, uint256 graceDays) external returns (uint256 id) {
    require(principal > 0, "principal=0");
    require(installment > 0 && totalInstallments > 0, "installments invalid");
    require(firstDueDate_ > block.timestamp, "firstDueDate in past");

    IERC721 _nft = IERC721(nft);
    require(_nft.isApprovedForAll(borrower, address(this)), "nft not approved");
    _nft.safeTransferFrom(borrower, address(this), tokenId);

    id = nextId++;
    loans[id] = Loan({
      borrower: borrower,
      lender: lender,
      nft: _nft,
      tokenId: tokenId,
      principal: principal,
      outstanding: principal,
      installment: installment,
      totalInstallments: totalInstallments,
      paidInstallments: 0,
      firstDueDate: firstDueDate_,
      intervalDays: intervalDays,
      graceDays: graceDays,
      status: Status.Active
    });

    require(realToken.transferFrom(lender, borrower, principal), "disburse fail");
    emit LoanCreated(id, borrower, lender, nft, tokenId, principal, installment, totalInstallments);
    emit Disbursed(id, principal);
  }

  function amortizeWithPixProof(uint256 id, bytes32 pixTxId, uint256 amount) external onlyRole(ORACLE_ROLE) {
    require(!pixProofUsed[pixTxId], "pix already used");
    Loan storage l = loans[id];
    require(l.status == Status.Active, "not active");
    require(l.paidInstallments < l.totalInstallments, "all paid");

    uint256 due = nextDueDate(id);
    require(due > 0, "no due");

    uint256 pay = amount;
    if (pay > l.installment) pay = l.installment;
    if (pay > l.outstanding) pay = l.outstanding;

    l.outstanding -= pay;
    l.paidInstallments += 1;
    pixProofUsed[pixTxId] = true;

    emit Amortized(id, l.paidInstallments, pay, pixTxId);

    if (l.paidInstallments >= l.totalInstallments || l.outstanding == 0) {
      l.status = Status.Settled;
      l.nft.safeTransferFrom(address(this), l.borrower, l.tokenId);
      emit Settled(id);
    }
  }

  function markDefault(uint256 id) public {
    Loan storage l = loans[id];
    require(l.status == Status.Active, "not active");
    uint256 due = nextDueDate(id);
    require(due > 0, "no due");
    require(block.timestamp > _addDays(due, l.graceDays), "still in grace");
    l.status = Status.Defaulted;
    emit DefaultMarked(id);
  }

  function liquidate(uint256 id) external {
    Loan storage l = loans[id];
    if (l.status == Status.Active) {
      uint256 due = nextDueDate(id);
      require(due > 0 && block.timestamp > _addDays(due, l.graceDays), "not overdue");
      l.status = Status.Defaulted;
      emit DefaultMarked(id);
    }
    require(l.status == Status.Defaulted, "not defaulted");
    l.status = Status.Liquidated;
    l.nft.safeTransferFrom(address(this), l.lender, l.tokenId);
    emit Liquidated(id, l.lender);
  }

  function scheduleInfo(uint256 id) external view returns (uint256 nextDue, uint256 remainingInstallments, uint256 outstanding, Status status) {
    Loan storage l = loans[id];
    nextDue = nextDueDate(id);
    remainingInstallments = l.totalInstallments - l.paidInstallments;
    outstanding = l.outstanding;
    status = l.status;
  }
}
