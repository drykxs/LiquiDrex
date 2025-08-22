# LiquiDREX – Open Finance + Drex (SaaS)

LiquiDREX é um **SaaS neutro** que orquestra:
- **Pagamento** via **Open Finance** (Pix),
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

