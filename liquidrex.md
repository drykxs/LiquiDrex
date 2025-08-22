# LiquiDREX – Smart Contracts (POC)

Este repositório contém os contratos inteligentes que compõem a POC (Prova de Conceito) da **bandeira LiquiDREX**, uma rede de integração entre o **sistema financeiro tradicional (Pix / Open Finance / Real)** e a **infraestrutura Drex** via blockchain permissionada.

---

## 📦 Contratos

### `CreditAgreement.sol`
Contrato que representa um **empréstimo parcelado (BNPL)**, vinculado a uma **prova Pix** assinada por oráculo. Ao final do pagamento, o contrato é quitado automaticamente.

- Permite criação de contratos com parcelas fixas.
- Apenas o oráculo autorizado pode dar baixa nas parcelas.
- Pode ser integrado com colaterais e emissão de recebíveis.

---

### `ReceivableToken.sol`
Implementação de **ERC‑1155** para representar **recebíveis fracionáveis** gerados a partir de contratos de crédito.

- Cada `id` representa um fluxo (contrato).
- Permite cessão de recebíveis para investidores.
- Pode ser usado como colateral ou em liquidações via DvP.

---

### `DvP1155.sol`
Contrato de **entrega‑contra‑pagamento (Delivery vs Payment)** para ativos ERC‑1155 ↔ tokens Drex (ERC‑20).

- Usa `safeTransferFrom` com aprovação.
- Garantia de liquidação atômica.
- Ideal para negociação entre credores e investidores.

---

### `Collateral.sol`
Gestor de **garantias tokenizadas (NFT)**:

- Trava NFTs de garantia durante o contrato de crédito.
- Permite execução do colateral em caso de inadimplência.
- Pode ser estendido com **leilão on‑chain** (como em `LiquidAcaoDrex`).

---

### `Governance.sol`
Gestão de **policy packs** e **controle de governança**:

- Armazena o hash do pacote de políticas vigente.
- Define papéis (roles) e partições (domínios).
- Referência para permissionamento no plugin Besu.

---

## 📁 Estrutura sugerida do projeto

```
/contracts
  CreditAgreement.sol
  ReceivableToken.sol
  DvP1155.sol
  Collateral.sol
  Governance.sol
/test
  creditAgreement.test.ts
  ...
/scripts
  deploy.ts
/README.md
/POC.md
```

---

## 🚀 Como usar

1. Instale dependências e Hardhat:

```bash
npm install
npx hardhat compile
```

2. Rode testes (exemplo):

```bash
npx hardhat test
```

3. Adapte os scripts de deploy conforme o seu ambiente (ex: sandbox Drex ou rede permissionada local).

---

## 📌 Requisitos

- Solidity ^0.8.24
- Node.js + Hardhat
- OpenZeppelin Contracts
- Ambiente compatível com EVM / Drex-Pilot

---

# POC.md – Explicação Técnica

## 1. CreditAgreement

Permite criar contratos parcelados com valores fixos, definidos por um oráculo de pagamento (Pix). Cada pagamento é validado via `pay(id, pixTxId)` pelo oráculo autorizado. O contrato é encerrado automaticamente ao fim das parcelas.

## 2. ReceivableToken

Emite um token ERC-1155 representando o fluxo de recebíveis de um contrato. O token pode ser fracionado e cedido a terceiros. Ideal para operações de antecipação e funding.

## 3. DvP1155

Realiza trocas atômicas entre tokens de recebíveis (ERC-1155) e tokens Drex (ERC-20). Usa mecanismos seguros de `safeTransferFrom` e `transferFrom`.

## 4. Collateral

Permite que NFTs (provenientes de cartórios, registros ou ativos tokenizados) sejam usados como garantia em contratos. Em caso de inadimplência, permite executar o colateral.

## 5. Governance

Armazena e verifica o hash dos "policy packs" — pacotes de regras operacionais, limites, restrições e permissões. Garante rastreabilidade e controle de mudanças.

---

## 🔒 Compliance

- Projetado para redes permissionadas (Besu plugin).
- Integração com KYC, AML, LGPD via oráculos e política off-chain.
- Metadados e trilhas auditáveis.

---

## 🔜 Próximos passos

- Integração com Open Finance (consentimento e iniciação de pagamento).
- Implementar provas Pix assinadas com mTLS/HSM.
- Adicionar leilão on-chain (LiquidAcaoDrex).
- Versionamento dos policy packs com logs WORM.

---

Para dúvidas ou colaboração, entre em contato com o mantenedor do projeto LiquiDREX.
