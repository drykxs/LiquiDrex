# LiquiDREX – Collateral Credit (POC)

Empréstimo parcelado com **garantia NFT**, **desembolso em RealToken (mock CBDC)** e **baixa de parcelas por prova Pix** (assinada por oráculo).

> POC educacional para testes locais com Hardhat. Não usar em produção.

## Como rodar

```bash
npm i
npx hardhat test
```

## Contratos

* `CollateralCredit.sol` – cria empréstimos:

  * trava NFT do tomador,
  * puxa principal do lender (ERC-20) e desembolsa ao tomador,
  * baixa parcelas via `amortizeWithPixProof` (somente oráculo),
  * executa garantia em default (`markDefault` + `liquidate`).

* `RealTokenMintable.sol` – ERC‑20 mock do Real.

* `MockNFT.sol` – ERC‑721 mock para garantia.

## Limitações (POC)

* Cálculo de juros/schedule simplificado (fixo).
* Sem partições/privacidade (adequar para DLT permissionada).
* Compliance/KYC/AML ficam off‑chain (SaaS + permissionamento).
* Oráculo Pix simulado via conta `oracle` nos testes.

## Próximos passos

* Adicionar **Policy Engine** (limits/regra do Bacen) e **DvP** para cessão.
* Provas Pix com assinatura real (mTLS/HSM) e logs WORM.
* Integração Open Finance (iniciador de pagamento).