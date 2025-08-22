# O que é a “bandeira LiquiDREX”

* **Função**: ser a “**bandeira**” que conecta **pagamentos em Real (Pix/Open Finance)** com **contratos e ativos no Drex**.
* **Modelo de receita**: **fee por passagem** (orquestração/execução), **não** MDR de cartão, **não** funding em balanço.
* **Quem usa**: emissores/PSPs, credenciadores, bancos, fintechs, varejo, registradoras/“cartórios digitais”, investidores.

---

# Como funciona (camadas)

1. **Open Finance + Pix (mundo Real)**

   * A LiquiDREX age como **iniciadora** (quando aplicável) e/ou integra **PSPs/credenciadores** para:

     * iniciar **Pix** (D+0 para o lojista),
     * obter **consentimentos** e **dados** (limites, risco),
     * ancorar **provas de pagamento** (TxID/E2E) que alimentam os contratos on‑chain.
2. **Smart Contracts (mundo Drex)**

   * A “bandeira” publica **templates certificados** que consolidam as **regras de negócio**:

     * **Crédito parcelado/BNPL** (juros, multa, carência, renegociação),
     * **Cessão de recebíveis** (ERC‑1155),
     * **Colateral** (NFT de garantia; CDB/depósito tokenizado),
     * **DvP** (entrega‑contra‑pagamento) entre recebíveis e Drex‑ERC20.
   * A execução é **atômica**: prova Pix → fecha DvP/baixa parcela.
3. **Permissionamento & Compliance**

   * Integra com o **plugin de permissionamento** (Besu) e um contrato de **Governança** (hash de policy pack).
   * **Policy Engine** (off‑chain) + **enforcement on‑chain** (limites/roles/selectors).
   * **KYC/AML/LGPD** embutidos na orquestração (logs WORM, mTLS, HSM/KMS).

---

# Fluxos típicos (em 3 passos)

**A) Real → Drex (venda/parcelado)**

1. Checkout: “Pagar com LiquiDREX”.
2. **Pix** liquida o lojista (D+0); **oráculo** publica a prova.
3. **Contrato‑Drex** nasce (parcelado/BNPL); se quiser, **recebível** é emitido e pode ser **cedido** (DvP) a um investidor.

**B) Drex → Real (resgate/liquidação)**

1. Investidor ou banco pede **resgate** de recebíveis (ou execução de colateral).
2. **Contrato** libera valores; **Open Finance** inicia **Pix** para a conta destino (ou TED/STR, conforme regra).
3. Registros e **baixas** ficam on‑chain; espelho contábil no ERP do participante.

**C) Garantia tokenizada (opcional)**

* NFT (cartório/registradora) fica **travado**; adimplência → liberação automática; inadimplência → **execução** (transferência ou leilão).

---

# Onde a LiquiDREX cobra (e onde não cobra)

| Item                                   | Cobra? | Observação                                                               |
| -------------------------------------- | :----: | ------------------------------------------------------------------------ |
| **Passagem de sistema** (orquestração) |    ✅   | R\$/tx previsível (ou por lote). Sem MDR de cartão.                      |
| Gás/quota on‑chain (meta‑tx/relayer)   |    ✅   | Inclusa no fee ou cobrada à parte por pacotes (quota).                   |
| Funding/crédito em balanço             |    ❌   | Não faz. É rede/bandeira, não emissor de crédito.                        |
| Custódia de ativos                     |    ❌   | Preferencialmente **não**; tokens ficam nos participantes/registradoras. |
| Dados de Open Finance                  |    ✅   | Custo operacional/consent; sempre com base legal do cliente.             |

**Resultados**: MDR \~0 (Pix), **spread** menor (risco→colateral e DvP), **capex/opex** menor (templates e policy prontos).

---

# Consolidação de regras (Smart Contracts)

**Catálogo de templates (auditáveis):**

* `CreditAgreement` (parcelado/BNPL): principal, tabela, juros, mora, carência, antecipação, renegociação, eventos.
* `ReceivableToken (ERC‑1155)`: 1 `id` = 1 contrato/fluxo; fracionável; apto a **cessão** e **colateralização**.
* `DvP` (1155↔ERC20): liquidação atômica venda de recebível ↔ pagamento em Drex.
* `Collateral` (NFT/CDB): trava, margem, execução, leilão (roadmap).
* `Governance`: âncora de **policy pack** (hash, versões); selectors/roles opcionais.

**Policy packs (exemplos):**

* Limites **por produto** (valor/parcelas/tenor).
* Regras **PIX** (prova obrigatória; estorno controlado).
* **KYC/AML** mínimo por ticket; bloqueios de sanções/PEP.
* **Risco**: exigir colateral quando score < X; haircut Y%.

---

# APIs (face SaaS)

* `POST /v1/checkout` → cria intenção; retorna QR Pix dinâmico.
* `POST /v1/webhooks/pix` → recebe prova Pix; dispara fechamento on‑chain (DvP/baixa).
* `POST /v1/contracts` → materializa contrato (parcelado/BNPL) a partir de template + policy.
* `POST /v1/receivables/issue` e `/assign` → emissão e cessão.
* `POST /v1/collateral/lock|unlock|liquidate` → colateral.
* `GET  /v1/policy-packs` → versões vigentes (hashes); auditoria/verificação.

> **Abstração de gás/quota:** meta‑transações e quotas por **CNPJ** (tenant), com rate‑limit e janelas de risco.

---

# Governança & Compliance (DLT permissionada)

* **Plugin de permissionamento** (Besu):

  * **Node/Account/Tx allowlist** → quem chama o quê (selectors).
  * **Partições** por domínio (varejo/recebíveis/colateral).
* **On‑chain Governance**: `policyPackHash` + roles/partições (quando aplicável).
* **Observabilidade**: logs WORM, hash de **policy/bytecode/input/tx**, tracing E2E Pix→Contrato→DvP.
* **LGPD**: minimização, criptografia, retenções; PII off‑chain, hash on‑chain.

---

# Economia (exemplo de precificação)

* **Plano Base**: R\$ 0,09/tx (até 1M tx/mês) + quota on‑chain inclusa (básica).
* **Pro**: R\$ 0,06/tx (≥1M tx) + quota ampliada + SLA 99,9%.
* **Enterprise**: preço por volume, **VPC dedicado**, BYOK/HSM, DR ativo‑ativo, *custom templates*.
* **Adicionais**: auditoria de templates, integração ERP, relatórios regulatórios.

---

# Diferenciais vs arranjos tradicionais

* **Sem MDR** → Pix + contratos on‑chain.
* **Baixo spread** → DvP + colateral (recebíveis/NFT/CDB).
* **Time‑to‑market** → templates auditados + policy packs.
* **Neutralidade** → não carrega risco de crédito, **conecta todos** via Open Finance.
* **Comprovabilidade** → trilhas imutáveis, reconciliação instantânea.

---

# Roadmap (curto → médio prazo)

1. **MVP**: parcelado + DvP + recebíveis; oráculo Pix; policy v1.
2. **Cessão avançada**: book de ofertas, netting, marketplace B2B.
3. **Colateral completo**: NFT cartorial + leilão; CDB tokenizado.
4. **Partições/privacidade**: dados sensíveis com “teleporte” entre domínios.
5. **Homologação**: bateria de conformidade com Bacen/participantes; SRE/DR.

---

## TL;DR

A **LiquiDREX** é a **bandeira Real ⇄ Drex** que **não cobra MDR**, **não dá crédito**, **só orquestra** — aplicando **Open Finance** de um lado e **smart contracts padronizados** do outro.
Resultado: **custo menor**, **liquidação mais rápida**, **risco controlado** e **compliance nativo**.

Se quiser, eu converto este desenho em um **one‑pager comercial** e um **deck de 6 slides** para apresentar a ideia a bancos/PSPs e parceiros do ecossistema.
