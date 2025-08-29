# 💳 LiquiDREX – Bandeira Drex/Pix Promocional

A **LiquiDREX** é uma *fintech-bandeira* que atua como **SaaS de reconciliação e regras de negócio**, conectando **Pix (SPI)** com **Drex centralizado**.

⚠️ Importante:  
- A LiquiDREX **não faz custódia** de valores.  
- **Os bancos parceiros** são os responsáveis por enviar ordens de liquidação ao STR/Selic.  
- A LiquiDREX apenas **consolida posições, aplica regras promocionais e organiza créditos**.

---

## 🚀 Como funciona

1. **Usuário (App LiquiDREX)** paga **R$95 via Pix**.  
2. O valor é liquidado pelo **SPI** diretamente em **conta de banco parceiro** (lastro 1:1 no Bacen).  
3. O **Core SaaS LiquiDREX** recebe a confirmação via Open Finance / CEDSFN.  
4. LiquiDREX aplica regras:  
   - R$105 em **créditos restritos** (SPTrans, CEA, SemParar)  
   - R$20 em **cashback DrexPromo** (rede livre)  
5. Cliente enxerga **apenas o saldo de cashback** no app.  
6. Parceiros (SPTrans, etc.) consomem diretamente o saldo restrito.  
7. LiquiDREX **consolida reconciliação multilateral** entre parceiros.  
8. **Bancos parceiros** enviam ordens de liquidação no STR/Selic.  
9. **Bacen** registra a liquidação final.

---

## 📊 Workflow ASCII

```text
[Usuário - App LiquiDREX]
        |
        | (1) Envia Pix de R$95
        v
[SPI - Pagamentos Instantâneos]
        |
        | (2) Liquidação 1:1
        v
[Banco Parceiro]
        |
        | (3) Confirmação via API (Open Finance / CEDSFN)
        v
[LiquiDREX - Core SaaS]
        |
        | (4) Credita R$105 "restrito" (SPTrans, CEA, SemParar)
        | (5) Credita +20 "cashback" (rede livre, app mostra)
        v
[Carteira Virtual - off-ledger]
        |
        | (6) Consumo de créditos nos parceiros
        v
[Parceiro credenciado]
        |
        | (7) Solicita reconciliação via CEDSFN
        v
[LiquiDREX - Consolidação]
        |
        | (8) Envia posições para bancos parceiros
        v
[Bancos parceiros → STR/Selic]
        |
        | (9) Ordem de liquidação enviada ao Bacen
        v
[Bacen - Registro contábil final]
