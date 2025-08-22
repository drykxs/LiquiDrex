# 💠 LiquiDREX

[www.liquidrex.tec.br](http://www.liquidrex.tec.br)

Fintech SaaS para **liquidações bancárias** no ecossistema **Drex (Real Digital)**.  
Construímos uma camada de tecnologia que conecta **Pix**, **Open Finance** e **ativos tokenizados** em contratos inteligentes, trazendo eficiência, rastreabilidade e compliance para instituições financeiras, empresas e usuários.

---

## 🚀 O que é o LiquiDREX?

O **LiquiDREX** é uma plataforma que atua como **consolidadora de regras de negócio** em cima da blockchain permissionada do Drex, oferecendo:

- Liquidação automatizada de operações financeiras  
- Integração direta com Pix (via plugin de permissionamento Bacen)  
- Registro e execução de contratos inteligentes regulados  
- Emissão de recebíveis tokenizados (ERC-1155)  
- Suporte a colaterais digitais (NFTs cartoriais)  
- Compliance embutido (KYC, AML, regras Bacen)

---

## 🏦 Casos de Uso

- **Bancos e fintechs** → terceirização da camada técnica de integração Drex  
- **Empresas** → crédito garantido via NFT tokenizado  
- **Investidores** → compra/venda de recebíveis em DvP (Delivery-versus-Payment)  
- **Cartórios digitais** → integração de garantias registradas na blockchain  

---

## ⚙️ Arquitetura

| Camada                    | Descrição                                                                 |
|----------------------------|---------------------------------------------------------------------------|
| `LiquiDrex.sol`            | Orquestrador/registry dos contratos de crédito                           |
| `CollateralCredit.sol`     | Crédito com garantia NFT + amortização via prova Pix                     |
| `ReceivableToken.sol`      | ERC-1155 representando recebíveis tokenizados                             |
| `DvP1155ForERC20.sol`      | Liquidação atômica entre recebíveis e tokens Drex (ERC-20)               |
| `Governance.sol`           | Registro de *policy packs* (hashes de regras definidas pelo Bacen)        |
| `mocks/`                   | Tokens de teste (ERC-20 e ERC-721) para simulações locais                 |

---

## 🔧 Como testar localmente

Clone o repositório:

```bash
git clone https://github.com/drykxs/LiquiDrex.git
cd LiquiDrex
npm install
