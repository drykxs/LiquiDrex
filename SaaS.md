# 🔌 Exemplo de API (LiquiDREX – Open Finance + Drex)

> **Objetivo**: orquestrar um pagamento **Pix** via Open Finance, registrar a venda/parcelado como **Contrato‑Drex** e, opcionalmente, emitir/ceder recebíveis.
>
> ### Tudo via OpenFinance em parceria com os bancos.

---

## Autenticação

* **B2B**: OAuth2 *client\_credentials* + mTLS entre parceiro (banco/fintech) ↔ LiquiDREX.
* Header: `Authorization: Bearer <token>`

## 1) Iniciar checkout

Cria a intenção de venda (FX opcional, BNPL/parcelado).

```http
POST /v1/checkout
Content-Type: application/json
Authorization: Bearer …

{
  "merchant": { "cnpj": "12.345.678/0001-90", "name": "Loja XYZ" },
  "customer": { "cpf": "123.456.789-00", "name": "João Silva" },
  "amount": { "currency": "BRL", "value": 150000 },      // 1500,00
  "payment": { "method": "PIX", "capture": "IMMEDIATE" },
  "contract": {
    "templateId": "parcelado.v1",
    "principal": 150000,
    "installments": 6,
    "annualRateBps": 980,           // 9,80% a.a. (exemplo)
    "graceDays": 0
  },
  "consents": { "openFinance": true }  // iniciar fluxo de consentimento
}
```

**200**

```json
{
  "checkoutId": "chk_01HZX…",
  "pix": { "qrDynamic": "00020126…", "txid": "LQDX-8F2A…" },
  "status": "AWAITING_PIX",
  "next": { "webhook": "/v1/webhooks/pix" }
}
```

## 2) Webhook Pix (confirmação)

LiquiDREX recebe do credenciador/PSP (ou do iniciador) o pagamento.

```http
POST /v1/webhooks/pix
X-Signature: ed25519:…
Content-Type: application/json

{
  "txid": "LQDX-8F2A…",
  "e2eId": "E305…",
  "amount": 150000,
  "paidAt": "2025-08-21T14:31:05Z",
  "payer": { "ispb": "12345678", "cpf": "123.456.789-00" },
  "receiver": { "ispb": "87654321", "cnpj": "12.345.678/0001-90" }
}
```

**202**

```json
{ "received": true }
```

## 3) Criar e fechar o Contrato‑Drex (atômico com DvP)

Normalmente o **LiquiDREX** aciona isso após o webhook; o endpoint abaixo permite uso direto.

```http
POST /v1/contracts
Authorization: Bearer …
Content-Type: application/json

{
  "checkoutId": "chk_01HZX…",
  "templateId": "parcelado.v1",
  "params": {
    "principal": 150000,
    "installments": 6,
    "annualRateBps": 980,
    "borrower": { "cpf": "123.456.789-00" },
    "lender": { "cnpj": "00.000.000/0001-91" }
  },
  "proof": { "pix": { "txid": "LQDX-8F2A…", "signature": "HSM:…"} }
}
```

**201**

```json
{
  "contractId": "ct_5f9c…",
  "drexTx": "0x7a1e…",
  "status": "ACTIVE",
  "schedule": [
    { "n": 1, "dueDate": "2025-09-21", "amount": 26000 },
    { "n": 2, "dueDate": "2025-10-21", "amount": 26000 }
  ]
}
```

## 4) Baixa de parcela (prova Pix)

```http
POST /v1/contracts/ct_5f9c…/amortize
Authorization: Bearer …
Content-Type: application/json

{
  "installment": 1,
  "amount": 26000,
  "proof": { "pix": { "txid": "LQDX-PARC1-…", "paidAt": "2025-09-21T10:00:00Z" } }
}
```

**200**

```json
{ "ok": true, "drexTx": "0xb41c…", "remaining": 5 }
```

## 5) Emissão e cessão do recebível (opcional)

```http
POST /v1/receivables/issue
Authorization: Bearer …
Content-Type: application/json

{
  "contractId": "ct_5f9c…",
  "percentage": 100,
  "instrument": "RECEIVABLE_V1"
}
```

**201**

```json
{ "receivableId": "rcv_aa12…", "drexTx": "0xabc…" }
```

```http
POST /v1/receivables/rcv_aa12…/assign
Authorization: Bearer …
Content-Type: application/json

{
  "to": { "cnpj": "11.111.111/0001-55" },
  "price": 147500,
  "dvp": true
}
```

**200**

```json
{ "assigned": true, "drexTx": "0xdef…" }
```

## 6) Consents Open Finance (iniciação de pagamento)

```http
POST /v1/consents
Authorization: Bearer …
Content-Type: application/json

{
  "customer": { "cpf": "123.456.789-00" },
  "scopes": ["payments:pix", "accounts:balance"],
  "redirectUri": "https://merchant.example/callback"
}
```

**201**

```json
{ "consentId": "cns_0x12…", "authUrl": "https://bankid/authorize?…" }
```

---

# 📘 README.md (para o repositório LiquiDREX SaaS)

```markdown
# LiquiDREX – Open Finance + Drex (SaaS)

LiquiDREX é um **SaaS neutro** que orquestra:
- **Iniciação de pagamento** via **Open Finance** (Pix),
- **Contratos inteligentes** no **Drex** (parcelado/BNPL, DvP, cessão, colateral),
- **Abstração de gás/quota** (relayer) e **compliance** (KYC/AML, LGPD),

> ⚠️ Projeto de **prototipagem**. Não é o Drex oficial do BCB.

---

## Arquitetura

- **API Edge** (REST/gRPC) + OAuth2 + mTLS
- **Policy Engine** (packs regulatórios do Bacen + regras por banco)
- **Contract Factory** (templates certificados em Solidity)
- **Relayer / Gas Abstraction** (meta-tx, quotas, rate limits)
- **Privacy** (partições/ledgers privados, notarização)
- **Compliance Hub** (KYC/AML, WORM logs, relatórios)
- **Connectors** (PIX/SPI, CIP, B3, Selic/STR, ERPs)

```

client/app ──> LiquiDREX API ──> Open Finance (Pix) ─┐
│                                  │ prova Pix
└─> Contract Factory (Drex) <──────┘ (oráculo)
└─> receivíveis / dvp / colateral

````

---

## Quickstart (dev)

### Requisitos
- Node.js 20+
- PNPM ou NPM
- Docker (opcional para mocks)

### Instalação
```bash
git clone https://github.com/sua-org/liquidrex-saas.git
cd liquidrex-saas
npm i
cp .env.example .env
````

### Ambiente

`.env` (exemplo)

```
PORT=8080
OAUTH_ISSUER=https://auth.liquidrex.local
OF_BASE_URL=https://openfinance-sandbox.example
PIX_WEBHOOK_SECRET=change-me
DREX_RPC_URL=http://localhost:8545
DREX_RELAYER_KEY=env://kms
WORM_BUCKET=s3://liquidrex-worm
```

### Rodar

```bash
npm run dev
```

---

## Endpoints principais

* `POST /v1/checkout` – cria intenção (Pix + contrato Drex)
* `POST /v1/webhooks/pix` – recebe confirmação Pix (assinada)
* `POST /v1/contracts` – materializa e fecha contrato (DvP)
* `POST /v1/contracts/{id}/amortize` – baixa parcela com prova Pix
* `POST /v1/receivables/issue` – emite token de recebível
* `POST /v1/receivables/{id}/assign` – cessão com DvP
* `POST /v1/consents` – inicia consentimento Open Finance

Veja **/docs/examples** para cURLs e payloads.

---

## Fluxo típico (BNPL com juros baixos)

1. `POST /checkout` → retorna QR Pix dinâmico.
2. Cliente paga → PSP chama `POST /webhooks/pix`.
3. LiquiDREX aciona `Contract Factory` → `POST /contracts` (Drex).
4. Lojista recebe D+0 via Pix; contrato nasce no Drex.
5. Parcelas → `POST /contracts/{id}/amortize` com prova Pix recorrente.
6. Funding barato → `receivables/issue` e `assign` (cessão on‑chain).

---

## Segurança & Compliance

* OAuth2 *client\_credentials*, mTLS, rate‑limit.
* Assinatura de **webhooks Pix** (Ed25519/ECDSA).
* **HSM/KMS** para chaves de oráculos/relayer.
* **WORM logs** (prova de execução: hash de policy/bytecode/input/tx).
* LGPD: minimização, criptografia at‑rest/in‑transit, retenções.

---

## Dev / Testes

* **Contracts**: `contracts/` (Solidity); Hardhat para testes unitários.
* **API**: `src/` (Node/TS – Express/Fastify).
* **Mocks**: PIX sandbox + Drex local (EVM compat layer).
* **CI**: GitHub Actions executa lint + testes.

```bash
npm run test        # unit
npm run test:int    # integração (mocks de Pix/Drex)
```

---

## Roadmap

* [ ] Policy Engine v1 (packs Bacen versionados)
* [ ] Templates: `parcelado.v1`, `dvp.v1`, `receivable.v1`, `collateral.cdb.v1`
* [ ] Relayer com quotas por CNPJ e janela de risco
* [ ] Partições/privacidade conforme nova DLT do Bacen
* [ ] Relatórios regulatórios (CVM/Bacen) e trilhas WORM

---

## Licença

MIT (ver `LICENSE`).

---

## Avisos

Este software é **experimental** e deve ser usado apenas em **ambientes de teste**.

```
