
# 🔄 Novo Modelo LiquiDrex (sem blockchain)

### 📌 Contexto

O **Drex fase final (2026)** não rodará em blockchain, mas em **infraestrutura centralizada do Bacen**:

* **STR** → liquidação de reservas bancárias em moeda oficial.
* **SPI** → sistema do Pix (24/7, instantâneo, comunicação ISO 20022).
* **Selic** → registro e custódia de títulos públicos.
* **CEDSFN** → mensageria de comunicação segura entre participantes.

A LiquiDREX funciona como **camada SaaS orquestradora**, **consolidando regras de negócio em contratos digitais** (não mais smart contracts on-chain, mas sim lógicas SaaS auditáveis), e usando as interfaces do Bacen.

---

## ⚙️ Fluxo Técnico (sem blockchain)

```text
[Usuário - App LiquiDREX]
        |
        | (1) Envia Pix de R$95
        v
[SPI - Pagamentos Instantâneos]
        |
        | (2) Confirma liquidação instantânea
        v
[LiquiDREX - Core SaaS + Regras]
        |
        | (3) Credita R$105 "saldo Drex específico" (SPTrans, CEA, SemParar)
        | (4) Credita +20 "saldo cashback" (rede livre)
        v
[Carteira Virtual Drex-like - off-ledger]
        |
        | (5) Usuário gasta nos parceiros
        v
[Parceiro credenciado]
        |
        | (6) Solicita compensação via CEDSFN/SPI
        v
[LiquiDREX + STR]
        |
        | (7) LiquiDREX envia instruções de liquidação no STR (reservas bancárias)
        v
[Bacen - STR/Selic]
        |
        | (8) Liquidação final + registro contábil
```

---

## 🏦 Pontos-chave

1. **Sem blockchain:**

   * O saldo “Drex” é **contábil em SaaS LiquiDREX**, lastreado em contas de liquidação no **STR**.
   * Não há emissão de tokens, mas sim créditos representativos (similar a “saldo pré-pago regulado”).

2. **Regras de negócio como contratos digitais:**

   * Definidos em SaaS (JSON/YAML configs + código).
   * Auditáveis e registrados via **CEDSFN** para garantir integridade.

3. **Integração técnica:**

   * Interfaces seguem o **Manual de Comunicação CEDSFN 1.11 (ISO 20022 adaptado)**.
   * LiquiDREX conversa via mensageria segura com o Bacen, como os bancos já fazem hoje.

4. **Segregação de fluxos:**

   * **Pix (SPI):** entrada de fundos de cliente.
   * **STR:** liquidação de reservas entre bancos/participantes.
   * **Selic:** eventual uso futuro como lastro ou colateral.
   * **LiquiDREX SaaS:** controle de saldo virtual, cashback e regras.

---

## 📐 Regras Digitais – Exemplo

```yaml
contrato: cashback-transporte
versao: 1.0
entrada:
  - metodo: Pix
  - valor: 95
saida:
  - credito_especifico: 105 (uso: SPTrans, CEA, SemParar)
  - cashback_livre: 20
compensacao:
  sistema: STR
  reconciliacao: CEDSFN
  liquidacao: D+0
```

---
## Fluxograma

<img width="2055" height="1470" alt="image" src="https://github.com/user-attachments/assets/6eb61542-92e3-4493-8def-b6b87182fec1" />


1. Usuário paga **Pix (R\$95)** via **SPI**.
2. **LiquiDREX SaaS** recebe confirmação e credita:

   * **R\$105 em saldo específico** (ex.: SPTrans, CEA, SemParar).
   * **+20 em cashback Drex livre**.
3. Usuário gasta nos **parceiros credenciados**.
4. Parceiro solicita compensação via **CEDSFN (mensageria ISO 20022)**.
5. LiquiDREX emite ordem no **STR** (reservas bancárias).
6. **Selic** pode registrar títulos de lastro/colateral.
7. **Bacen** faz a liquidação final e registro contábil.

---


