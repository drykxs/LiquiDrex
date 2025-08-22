# Descrição
> **Drex sobre Besu (ou DLT compatível)** 
>**Bacen** controla o acesso via **Permissioning Plugin** (node‑level e/ou smart‑contract‑level). 
> E  o **gateway Pix** é um **capability** atrelado ao Real, exposto apenas a participantes com permissão explícita.

---

# 🔐 Modelo de permissionamento (visão geral)

**Três camadas**:

1. **Node permissioning (plugin)** – quem pode rodar nó, parear (P2P) e enviar tx RPC.
2. **Account/Tx permissioning (plugin)** – quais contas (EOA/contratos) podem **invocar** métodos (por ABI/selector) e em quais redes/partições.
3. **On‑chain policy (smart contracts)** – “business guardrails” (roles, limites, KYC, DV P, etc.) versionados pelo Bacen.

O **Bacen** publica e versiona as **listas de permissão** (allowlists) e **pacotes de políticas** (policy packs). Os bancos/fintechs só operam dentro desse “funil”.

---

# 🧱 Como o LiquiDREX opera nesse arranjo

* **Sem ser banco**: atua como **iniciador Open Finance** + **relayer** autorizado.
* **Plugin**: o nó (ou endpoint RPC) do LiquiDREX aparece em allowlist **somente** para chamadas específicas (p. ex. `eth_sendRawTransaction` para contratos certificados).
* **On‑chain**: os **templates de contrato** (parcelado, DvP, cessão, colateral) são **pré‑aprovados** e publicados pelo Bacen/Bancos; LiquiDREX só instancia/parametriza conforme **policy pack** vigente.

---

# 🧩 Exemplo de configuração (plugin de permissionamento)

> Ilustrativo; o Bacen hospedaria o repositório “single‑source‑of‑truth”.

## 1) Node permissioning (peers e RPC)

`permissioning-nodes.toml`

```toml
[accounts]  # nós com RPC permitido
allowlist = [
  "enode://PUBKEY_BC@10.0.0.1:30303",
  "enode://PUBKEY_B3@10.0.0.2:30303",
  "enode://PUBKEY_BANKA@10.0.0.3:30303",
  "enode://PUBKEY_LIQUIDREX@10.0.0.10:30303"
]

[p2p]  # pares autorizados
allowlist = [
  "enode://PUBKEY_BC@10.0.0.1:30303",
  "enode://PUBKEY_B3@10.0.0.2:30303",
  "enode://PUBKEY_BANKA@10.0.0.3:30303",
  "enode://PUBKEY_BANKB@10.0.0.4:30303",
  "enode://PUBKEY_LIQUIDREX@10.0.0.10:30303"
]
```

## 2) Account/Tx permissioning (por método/contrato)

`permissioning-accounts.json`

```json
{
  "allowlist": [
    {
      "address": "0xRelayerLiquiDREX",
      "methods": [
        { "contract": "0xFactoryParceladoV1", "selector": "0x60806040" },
        { "contract": "0xDVPv1",              "selector": "0xa9059cbb" },
        { "contract": "0xReceivivelV1",       "selector": "0x23b872dd" }
      ],
      "rateLimit": { "tps": 30, "burst": 100 },
      "constraints": {
        "maxNotionalBRL": 5000000,
        "partitions": ["drex-retail", "drex-receivables"]
      }
    }
  ]
}
```

> **Observação**: Seletores de função (4 bytes) podem ser controlados por **lista positiva**, reduzindo superfície de ataque.
> O plugin pode bloquear `eth_sendRawTransaction` **exceto** para destinos/métodos autorizados.

---

# 🏛️ On‑chain policy (contrato de governança)

O Bacen ancora o plugin com **políticas on‑chain** (hashes/versões) e **roles** (ex.: `ROLE_INITIATOR`, `ROLE_ORACLE_PIX`, `ROLE_EMISSOR`).

**Governance.sol (trecho simplificado)**

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract Governance {
  address public bacen;
  mapping(bytes32 => bool) public policyPackActive; // hash -> ativo
  mapping(address => mapping(bytes4 => bool)) public methodAllowed; // quem pode chamar qual método
  mapping(address => mapping(bytes32 => bool)) public tenantPartition; // partições habilitadas

  event PolicyPackUpdated(bytes32 hash, bool active);
  event MethodToggled(address caller, bytes4 selector, bool allowed);
  event PartitionGranted(address caller, bytes32 partition, bool granted);

  modifier onlyBacen() { require(msg.sender == bacen, "not-bacen"); _; }

  constructor(address _bacen) { bacen = _bacen; }

  function setPolicy(bytes32 pack, bool active) external onlyBacen {
    policyPackActive[pack] = active; emit PolicyPackUpdated(pack, active);
  }

  function allowMethod(address who, bytes4 selector, bool allowed) external onlyBacen {
    methodAllowed[who][selector] = allowed; emit MethodToggled(who, selector, allowed);
  }

  function setPartition(address who, bytes32 p, bool granted) external onlyBacen {
    tenantPartition[who][p] = granted; emit PartitionGranted(who, p, granted);
  }
}
```

O **plugin** pode consultar periodicamente a **raiz/merkle** publicada pelo Governance (via oracle/bridge) para manter **sincronismo** entre **arquivo do plugin** e **estado on‑chain** (prova criptográfica).

---

# 🔄 Fluxo fim‑a‑fim (Pix + contrato Drex) com permissionamento

1. **Checkout** (LiquiDREX) → inicia **Pix** via Open Finance.
2. **Pagamento** cai no PSP → webhook assinado para LiquiDREX (oráculo Pix).
3. **LiquiDREX Relayer** envia **tx** para `FactoryParceladoV1` **somente** porque:

   * o **plugin** do Bacen permite `0xRelayerLiquiDREX` chamar **aquele** selector,
   * a **partição** `drex-retail` está habilitada,
   * o **PolicyPack** atual está ativo (hash confere).
4. **Contrato** nasce; DV P com `ReceivivelV1`/cessionário, se aplicável.
5. **Logs WORM** (hash da política + bytecode + inputs + tx hash) para auditoria.

Se algo desvia (método não autorizado, valor acima do teto, partição errada), o **plugin barra** a tx **antes** de atingir o consenso.

---

# 🧰 Operação do LiquiDREX (SaaS) nesse cenário

* **Relayer com mTLS** para o **RPC permissionado** do Bacen/B3.
* **Policy Engine** consome os **policy packs** (manifesto YAML/JSON) e **compila checagens** no backend **e** nos parâmetros on‑chain (duplica defesas).
* **Feature flags por tenant** (CNPJ) → mapeadas a **partições**/limites do plugin.
* **Emergency kill‑switch**: Bacen desativa seletor/partição e **corta** capacidade do relayer sem mexer em contratos já imutáveis.

---

# 🔎 Manifesto de política (exemplo YAML → hash)

```yaml
version: 2.1.0
pack: "retail-parcelado-v1"
roles:
  initiators: ["0xRelayerLiquiDREX"]
partitions:
  - drex-retail
limits:
  per_tx_max_brl: 500000
  per_day_max_brl: 5000000
methods:
  FactoryParceladoV1:
    - createAgreement(principal, installments, rateBps, borrower, lender)
  DVPv1:
    - settle(orderId)
aml:
  pep: true
  sanctions: true
  kyc_level: 2
proofs:
  - PIX_TX_REQUIRED
```

**Pipeline**:

1. Converte YAML → JSON canônico → calcula **SHA‑256**.
2. Publica **hash** no `Governance.sol`.
3. Distribui **mesmo pack** ao **plugin** (arquivo assinado).
4. LiquiDREX só envia tx se `hash_atual == hash_governance == hash_plugin`.

---

# 🛡️ Segurança & privacidade

* **Partições/ledgers privados** para dados sensíveis (ex.: limite do cliente).
* **Selectors allowlist**: reduz ABI surface.
* **Rate‑limit no plugin** (TPS/tenant) + **quotas** no relayer.
* **mTLS + OAuth2** entre SaaS ↔ PSPs/bancos.
* **LGPD**: minimização, criptografia at‑rest/in‑transit, retenção.
* **Provas** (hash pack/payload/bytecode/tx) → auditoria regulatória.

---

# 🚀 Passos práticos (MVP com permissionamento)

1. **Subir rede dev** (Besu) com **plugins de node/account permissioning** e arquivos de allowlist.
2. **Governance.sol** + CLI para publicar/atualizar **policy pack hash**.
3. **Factories certificadas** (ParceladoV1, DVPv1, ReceivivelV1) → endereços fixos.
4. **Relayer LiquiDREX** (Node/TS) com:

   * leitura do **pack** (YAML),
   * validações off‑chain,
   * envio de tx **apenas** para métodos/partições permitidos,
   * **fallback** se o plugin recusar (telemetria).
5. **Conector Pix sandbox** + **oráculo** (assinatura HSM) → `confirmPix`.
6. **WORM logs** e painéis (SLA, rejeições do plugin, divergência de hash de policy).

---

**Resumo:**
O **plugin de permissionamento** transforma a rede Drex numa **DLT com “porteiro”**: só entra quem o Bacen deixa e **só faz o que for permitido**. O **LiquiDREX**, como **SaaS não‑banco**, opera com **credenciais mínimas** (initiator/oracle/relayer), obedecendo **policy packs** do Bacen. Resultado: **interoperabilidade** (Open Finance + Pix), **segurança regulatória** e **tempo‑de‑mercado** muito menor para os bancos — sem cada um reinventar sua pilha on‑chain.
