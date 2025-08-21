ótimo — dá pra montar um **MVP de testes** no GitHub que simula o “mundo Drex” usando EVM (Hardhat) com:

* um **MockDrex (ERC-20)** para representar o real digital,
* um **token de ativo** (ex.: CDB/recebível),
* um **contrato DvP (Delivery-versus-Payment)** para liquidação atômica,
* **testes automatizados** e **GitHub Actions** rodando em cada push/PR.

Abaixo vai um guia direto + trechos de código prontos.

---

# 1) Estrutura do repositório

```
liquidrex-mvp/
├─ contracts/
│  ├─ MockDrex.sol
│  ├─ AssetToken.sol
│  └─ DvP.sol
├─ test/
│  ├─ dvp.test.ts
├─ scripts/
│  ├─ deploy.ts
├─ package.json
├─ hardhat.config.ts
├─ .github/workflows/ci.yml
├─ README.md
└─ LICENSE
```

---

# 2) Inicialização

```bash
mkdir liquidrex-mvp && cd liquidrex-mvp
npm init -y
npm i -D typescript ts-node @types/node hardhat @nomicfoundation/hardhat-toolbox
npx hardhat init     # escolha "Create a TypeScript project"
npm i @openzeppelin/contracts
```

No `hardhat.config.ts` (caso não venha com toolbox), garanta:

```ts
import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

const config: HardhatUserConfig = {
  solidity: "0.8.24"
};
export default config;
```

---

# 3) Contratos

## `contracts/MockDrex.sol`

Token fungível que simula o Drex para testes locais.

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockDrex is ERC20 {
    address public minter;

    constructor() ERC20("Mock Drex", "DREX") {
        minter = msg.sender;
        _mint(msg.sender, 1_000_000e18);
    }

    function mint(address to, uint256 amount) external {
        require(msg.sender == minter, "not minter");
        _mint(to, amount);
    }
}
```

## `contracts/AssetToken.sol`

Representa um ativo tokenizado (ex.: CDB) fungível.

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract AssetToken is ERC20 {
    address public issuer;

    constructor(string memory name_, string memory symbol_, uint256 initialSupply, address issuer_) 
        ERC20(name_, symbol_) 
    {
        issuer = issuer_;
        _mint(issuer_, initialSupply);
    }
}
```

## `contracts/DvP.sol`

Liquidação **atômica** Drex ↔ ativo (entrega contra pagamento).

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title DvP (Delivery-versus-Payment)
 * @notice Atomic swap between Drex (paymentToken) and AssetToken (assetToken).
 * Maker deposita asset; Taker deposita Drex; contrato entrega ambos simultaneamente.
 */
contract DvP {
    struct Order {
        address maker;       // quem vende o ativo
        address taker;       // opcional: 0 = livre
        IERC20 assetToken;   // ativo tokenizado
        IERC20 paymentToken; // MockDrex no MVP
        uint256 assetAmount;
        uint256 paymentAmount;
        bool assetDeposited;
        bool paymentDeposited;
        bool settled;
        bool canceled;
    }

    uint256 public nextId;
    mapping(uint256 => Order) public orders;

    event OrderCreated(uint256 id, address maker, address taker);
    event AssetDeposited(uint256 id, address from);
    event PaymentDeposited(uint256 id, address from);
    event Settled(uint256 id);
    event Canceled(uint256 id);

    function createOrder(
        address taker,
        IERC20 assetToken,
        IERC20 paymentToken,
        uint256 assetAmount,
        uint256 paymentAmount
    ) external returns (uint256 id) {
        id = nextId++;
        orders[id] = Order({
            maker: msg.sender,
            taker: taker,
            assetToken: assetToken,
            paymentToken: paymentToken,
            assetAmount: assetAmount,
            paymentAmount: paymentAmount,
            assetDeposited: false,
            paymentDeposited: false,
            settled: false,
            canceled: false
        });
        emit OrderCreated(id, msg.sender, taker);
    }

    function depositAsset(uint256 id) external {
        Order storage o = orders[id];
        require(!o.canceled && !o.settled, "closed");
        require(msg.sender == o.maker, "only maker");
        require(!o.assetDeposited, "already");
        require(o.assetToken.transferFrom(msg.sender, address(this), o.assetAmount), "asset xfer fail");
        o.assetDeposited = true;
        emit AssetDeposited(id, msg.sender);
    }

    function depositPayment(uint256 id) external {
        Order storage o = orders[id];
        require(!o.canceled && !o.settled, "closed");
        require(o.taker == address(0) || msg.sender == o.taker, "not allowed");
        require(!o.paymentDeposited, "already");
        require(o.paymentToken.transferFrom(msg.sender, address(this), o.paymentAmount), "pay xfer fail");
        o.paymentDeposited = true;
        emit PaymentDeposited(id, msg.sender);
    }

    function settle(uint256 id, address takerAddr) external {
        Order storage o = orders[id];
        require(!o.canceled && !o.settled, "closed");
        // lock de destinatário (se definido)
        if (o.taker == address(0)) {
            o.taker = takerAddr;
        }
        require(o.assetDeposited && o.paymentDeposited, "not ready");

        // entrega contra pagamento (atômico)
        require(o.assetToken.transfer(o.taker, o.assetAmount), "asset out fail");
        require(o.paymentToken.transfer(o.maker, o.paymentAmount), "pay out fail");

        o.settled = true;
        emit Settled(id);
    }

    function cancel(uint256 id) external {
        Order storage o = orders[id];
        require(!o.canceled && !o.settled, "closed");
        require(msg.sender == o.maker, "only maker");
        // devolver o que estiver no cofre
        if (o.assetDeposited) {
            o.assetToken.transfer(o.maker, o.assetAmount);
        }
        if (o.paymentDeposited) {
            o.paymentToken.transfer(o.taker == address(0) ? msg.sender : o.taker, o.paymentAmount);
        }
        o.canceled = true;
        emit Canceled(id);
    }
}
```

---

# 4) Teste automatizado

## `test/dvp.test.ts`

```ts
import { expect } from "chai";
import { ethers } from "hardhat";

describe("DvP MVP", function () {
  it("faz liquidação atômica Drex ↔ Ativo", async () => {
    const [maker, taker] = await ethers.getSigners();

    const Drex = await ethers.getContractFactory("MockDrex");
    const drex = await Drex.connect(maker).deploy();
    await drex.waitForDeployment();

    const Asset = await ethers.getContractFactory("AssetToken");
    const asset = await Asset.connect(maker).deploy("CDB Token", "CDBT", ethers.parseEther("10000"), maker.address);
    await asset.waitForDeployment();

    const DvP = await ethers.getContractFactory("DvP");
    const dvp = await DvP.deploy();
    await dvp.waitForDeployment();

    // fundos iniciais
    await drex.mint(taker.address, ethers.parseEther("1000"));

    // aprovações
    await asset.connect(maker).approve(await dvp.getAddress(), ethers.parseEther("100"));
    await drex.connect(taker).approve(await dvp.getAddress(), ethers.parseEther("500"));

    // cria ordem: maker vende 100 CDBT por 500 DREX
    const tx = await dvp.connect(maker).createOrder(
      taker.address,
      await asset.getAddress(),
      await drex.getAddress(),
      ethers.parseEther("100"),
      ethers.parseEther("500")
    );
    const rc = await tx.wait();
    const id = rc!.logs[0].args?.[0] ?? 0n; // OrderCreated event

    await dvp.connect(maker).depositAsset(id);
    await dvp.connect(taker).depositPayment(id);

    // settle
    await dvp.connect(taker).settle(id, taker.address);

    // verificações
    expect(await asset.balanceOf(taker.address)).to.equal(ethers.parseEther("100"));
    expect(await drex.balanceOf(maker.address)).to.equal(ethers.parseEther("500"));
  });
});
```

Rodar local:

```bash
npx hardhat test
```

---

# 5) Deploy de exemplo

## `scripts/deploy.ts`

```ts
import { ethers } from "hardhat";

async function main() {
  const [deployer] = await ethers.getSigners();

  const Drex = await ethers.getContractFactory("MockDrex");
  const drex = await Drex.deploy();
  await drex.waitForDeployment();

  const Asset = await ethers.getContractFactory("AssetToken");
  const asset = await Asset.deploy("CDB Token", "CDBT", ethers.parseEther("1000000"), deployer.address);
  await asset.waitForDeployment();

  const DvP = await ethers.getContractFactory("DvP");
  const dvp = await DvP.deploy();
  await dvp.waitForDeployment();

  console.log("MockDrex:", await drex.getAddress());
  console.log("AssetToken:", await asset.getAddress());
  console.log("DvP:", await dvp.getAddress());
}

main().catch((e) => { console.error(e); process.exit(1); });
```

---

# 6) CI no GitHub Actions

## `.github/workflows/ci.yml`

```yaml
name: CI
on:
  push:
  pull_request:

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: "20.x"
          cache: "npm"
      - run: npm ci
      - run: npx hardhat test
```

---

# 7) README (resumo)

Inclua um `README.md` explicando:

* objetivo do MVP (simulação Drex/ativo/DvP),
* como instalar, testar e fazer deploy local,
* limitações (não é Drex real, sem controles de permissão, sem KYC/AML),
* próximos passos.

---

# 8) Próximos passos úteis

* **Papéis/Permissões**: simular rede permissionada (owners, emissores, investidores).
* **KYC/AML**: mock de whitelist on-chain.
* **Oráculos/Parâmetros**: exemplo de seguro paramétrico (clima).
* **API SaaS**: uma API Node/TS simples para orquestrar ordens e emitir transações (Express/Fastify) + Postman collection.
* **Front demo**: página Next.js para criar ordem DvP e ver liquidação.

---

Se quiser, eu já preparo um **README.md completo** e agrego **mais testes** (cancelamento, ordens públicas, reentrância, limites) — é só dizer que eu colo aqui na conversa.
