# LiquiDREX Incentivo Setorial

Plataforma de incentivo digital que conecta Pix e Drex para usos específicos (ex: SPTrans, CEA, Sem Parar), usando SPI/STR/CEDSFN em vez de blockchain.

---

## README.md

### Visão geral

LiquiDREX é uma solução de "moeda digital setorial" que transforma um pagamento Pix (ex: R\$ 95,00) em:

* **Créditos Drex** para uso exclusivo em empresas/parceiros definidos;
* **Cashback Drex livre**, para gastar na rede geral de parceiros.

Tudo isso sem blockchain — apenas usando integrações com SPI, STR e mensagens do CEDSFN.

---

### Como funciona

1. Usuário paga R\$ 95,00 via Pix no app ou parceiro integrado;
2. Recebe:

   * 105 Drex de crédito setorial (ex: `drex:sptrans`);
   * 20 Drex de cashback (rede geral);
3. Saldo é registrado em base auditável interna e comunicado via CEDSFN;
4. Uso do crédito é controlado (somente parceiros validados);
5. Liquidação ocorre via SPI ou TED via STR.

---

### Tecnologias

* SPI (Pix) para recebimentos e liquidações
* STR (TED) para resgates
* CEDSFN (v1.11): mensagens SCPC/CCPA/CPFC
* Base PostgreSQL (ou equivalente) com trilha WORM
* API RESTful com OAuth2 + OpenAPI 3.0

---

## POC.md – Prova de Conceito Técnica

### Estrutura principal

**Módulo de Saldos:**

* Armazena saldos por usuário e categoria Drex
* Controla validade e regras de uso por parceiro

**Módulo de Liquidação:**

* Confirma pagamento via webhook Pix (SPI)
* Envia liquidação para parceiro via SPI ou TED (STR)

**Módulo de Integração CEDSFN:**

* SCPC010: consulta saldo
* CCPA001: crédito (cashback)
* CCPA002: débito por consumo
* CPFC001: extrato (reportes de uso)

---

### Exemplo de fluxo

```text
1. Cliente paga R$ 95 via Pix
2. LiquiDREX recebe webhook SPI
3. Sistema emite:
   - CCPA001 (crédito cashback 20)
   - CCPA001 (crédito setorial 105)
   - Registra `drex:sptrans` na conta virtual
4. Cliente usa R$ 30 na SPTrans
5. LiquiDREX envia:
   - CCPA002 (débito 30)
   - SPI para liquidar SPTrans
```

---

### Projeções para Fase 2 do Piloto Drex

| Requisito                | Atendido? | Observação                                     |
| ------------------------ | --------- | ---------------------------------------------- |
| Integração SPI           | ✅         | Webhook Pix validado                           |
| Integração STR (TED)     | ✅         | Gateway de TED automático via API bancária     |
| Integração CEDSFN        | ✅         | Módulo com SCPC, CCPA e CPFC                   |
| Sem uso de blockchain    | ✅         | Totalmente off-chain, sem DLT                  |
| Registros auditáveis     | ✅         | Trilhas imutáveis (WORM, hash input/output)    |
| KYC/AML                  | ✅         | Open Finance + autenticação bancária           |
| Modularidade (parceiros) | ✅         | Adição dinâmica de SPTrans, CEA, SemParar etc. |

---

### Próximos passos

* Criar API REST OpenAPI 3.0 com endpoints:

  * `/pix/receive`
  * `/drex/credit`
  * `/drex/debit`
  * `/partners/{id}/redeem`
  * `/users/{id}/balances`
* Gerar simulação de mensagens CEDSFN (XML)
* Preparar sandbox para testes com parceiros

---

**LiquiDREX** conecta o mundo real (Pix/STR) com incentivos digitais inteligentes (Drex) – agora, sem blockchain.
