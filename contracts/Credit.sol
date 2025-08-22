// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// Este é o início do pacote de smart contracts para a "bandeira" LiquiDREX
/// Alinhado com o modelo do Bacen (realdigital), compatível com o kit do GitHub oficial
/// https://github.com/bacen/pilotord-kit-onboarding/tree/main/smartcontracts/realdigital

// Contratos POC a serem incluídos:
// - CreditAgreement (parcelado/BNPL com juros e Pix Proof)
// - ReceivableToken (ERC-1155)
// - DvP1155 (liquidação atômica entre ativo e pagamento Drex)
// - Collateral (NFT garantia com leilão opcional)
// - Governance (hash de policy pack, roles)

// 1. CreditAgreement básico (estrutura)
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

// (Outros contratos como ReceivableToken, DvP, Collateral, Governance podem ser adicionados na sequência)
