# 💳 LiquiDREX – Bandeira Drex/Pix Promocional (sem custódia)

A **LiquiDREX** é um **SaaS de regras e reconciliação** que conecta **Pix (SPI)** ao **Drex centralizado** (sem blockchain, sem tokenização).

* **Sem custódia**: a LiquiDREX não mantém dinheiro do cliente.
* **Ordens ao Bacen (CEDSFN/STR/SPI)**: **sempre** pelos **bancos parceiros**.
* **LiquiDREX consolida** posições multilaterais (clearing privado) e **instrui** os bancos a liquidarem entre si.

## 🚀 Como funciona (visão correta)

1. O cliente paga **R\$95 via Pix** → **Banco do Cliente** liquida no **SPI**.
2. O crédito entra no **Banco do Parceiro** (recebedor) via SPI/STR (lastro 1:1).
3. **LiquiDREX** recebe confirmações via APIs (Open Finance / integrações bancárias) e aplica regras:

   * **R\$105** de **crédito restrito** (SPTrans/CEA/SemParar).
   * **+R\$20** de **cashback** (rede livre, mostrado no app).
4. O cliente **só vê o cashback** no app; o **restrito** é consumido “no parceiro”.
5. **LiquiDREX** calcula **net positions** entre bancos e parceiros (clearing privado).
6. **Bancos** (do parceiro e do cliente, conforme o caso) **enviam as ordens** ao Bacen (CEDSFN/STR/SPI) para **liquidação final**.

> Exceções (fraude/roubo): devolução **somente** pelo mecanismo **Pix MED**, acionado **pelo(s) banco(s)**; a LiquiDREX apenas **congela** os saldos promocionais e **orquestra** o fluxo documental.

## 📊 Workflow ASCII (corrigido)

```
[Usuário - App LiquiDREX]
        |
        | (1) Pix R$95 (consent via Open Finance)
        v
[Banco do Cliente] -----------------------------.
        |                                         \
        | (2) Liquidação SPI/STR (1:1)             \  Mensageria Bacen
        v                                           \ (ISO 20022 / CEDSFN)
[Bacen - SPI/STR]                                   \
        |                                            v
        | (3) Crédito no Banco do Parceiro     [Banco do Parceiro]
        |                                            |
        '--------------------------------------------'
                         (confirmação bancária)

[LiquiDREX - Core SaaS (sem custódia)]
        |
        | (4) Aplica regras: +R$105 restrito (parceiro) +R$20 cashback (livre)
        v
[App do Cliente] --- exibe APENAS cashback --- (restrito é invisível)

[Consumo no Parceiro]
        |
        | (5) Parceiro debita saldo restrito (via integração c/ Banco do Parceiro)
        v
[LiquiDREX - Consolidação (clearing privado)]
        |
        | (6) Calcula NET entre bancos/parceiros e INSTRUI liquidação
        v
[Bancos Parceiros]  --> (7) Enviam ordens ao Bacen (CEDSFN/STR/SPI)
        |
        v
[Bacen - Liquidação Final e Registro Contábil]
```

## ✅ Benefícios

* **Compliance**: só bancos falam com Bacen; LiquiDREX é **bandeira/orquestradora**.
* **Sem risco de custódia**: dinheiro sempre em **bancos parceiros**.
* **Simples para o cliente**: “**Pague 95 → receba 105 + 20 de cashback**”.
* **Escalável**: clearing privado + liquidação interbancária padrão.

## 🔒 Regras essenciais

* **Sem reconversão** Drex→Pix (apenas **MED** em fraude/roubo).
* **Créditos restritos** consumidos no parceiro; **app mostra só cashback**.
* **Sem tokenização** e sem fracionamento de ativos (ativo **indivisível**).
* **Convênios** com entes públicos (SPTrans) e **contratos** com privados (SemParar/CEA) **bancam os incentivos**.
