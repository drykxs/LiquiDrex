# 💳 LiquiDREX – Bandeira Drex/Pix Promocional (sem custódia)

A **LiquiDREX** é uma *fintech-bandeira* que atua como **SaaS de reconciliação e regras de negócio**, conectando **Pix (SPI)** com a rede **Drex centralizada**.

⚠️ Importante:
- A LiquiDREX **não faz custódia de valores**.
- **Ordens ao Bacen (SPI/STR/SELIC)** são sempre enviadas pelos **bancos parceiros**.
- A LiquiDREX apenas **consolida posições, aplica regras promocionais e organiza créditos**.

---

## 🚀 Como funciona

1. **Usuário (App LiquiDREX)** paga **R$95 via Pix**.  
2. O valor é liquidado pelo **SPI** em **conta do banco parceiro** (lastro 1:1 no Bacen).  
3. O **Core SaaS LiquiDREX** recebe confirmação via Open Finance / CEDSFN.  
4. LiquiDREX aplica regras comerciais:  
   - **R$105** em **créditos de parceiro** (SPTrans, CEA, SemParar).  
   - **R$20** em **cashback DrexPromo** (promocional, restrito à rede LiquiDREX).  
5. O cliente enxerga no app:  
   - **Saldo consolidado (Open Finance)** → direto do banco.  
   - **Créditos comprados** em parceiros (SPTrans, etc.).  
   - **Cashback DrexPromo** → promocional, restrito à rede.  
6. Parceiros consomem os créditos do cliente via integração com seus **bancos parceiros**.  
7. LiquiDREX **consolida net positions** em clearing privado.  
8. **Bancos parceiros** emitem ordens de liquidação ao **STR/Selic**.  
9. O **Bacen** registra a liquidação final.

---

## 📊 Workflow ASCII

```text
[Usuário - App LiquiDREX]
        |
        | (1) Pix R$95 (consentimento Open Finance)
        v
[Banco do Cliente] -----------------------------.
        |                                         \
        | (2) Liquidação SPI/STR (1:1)             \  CEDSFN (ISO 20022)
        v                                           \  Mensageria Bacen
[Bacen - SPI/STR]                                   \
        |                                            v
        | (3) Crédito no Banco do Parceiro     [Banco do Parceiro]
        |                                            |
        '--------------------------------------------'
                         (confirmação bancária)

[LiquiDREX - Core SaaS (sem custódia)]
        |
        | (4) Aplica regras comerciais:
        |       - R$105 “créditos de parceiro” (SPTrans/CEA/SemParar)
        |       - +R$20 “cashback DrexPromo” (restrito à rede LiquiDREX)
        v
[App do Cliente] --- exibe:
        • Saldo consolidado (Open Finance)
        • Créditos comprados em parceiros (SPTrans/CEA/etc.)
        • Cashback DrexPromo (promocional, rede LiquiDREX)

[Consumo no Parceiro]
        |
        | (5) Débito dos créditos via Banco do Parceiro
        v
[LiquiDREX - Consolidação (clearing privado)]
        |
        | (6) Calcula posições líquidas (NET) entre bancos/parceiros
        v
[Bancos Parceiros]  --> (7) Envio de ordens ao Bacen (SPI/STR/SELIC)
        |
        v
[Bacen - Liquidação Final e Registro Contábil]

```

## ✅ Benefícios

- Compliance garantido: apenas bancos interagem com Bacen.
- LiquiDREX sem risco regulatório: não faz custódia → atua como bandeira/orquestradora.
- Valor ao cliente: “Pague R$95 → receba R$105 em créditos + R$20 de cashback DrexPromo”.
- Escalabilidade: modelo de clearing privado + liquidação final no STR.
- Flexível: funciona tanto para convênios públicos (SPTrans) quanto para contratos privados (SemParar, CEA).

## 📌 Tagline
LiquiDREX – Pague em Pix, receba em benefícios. Reconciliação inteligente, lastro 1:1 no Bacen.
