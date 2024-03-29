```shell
forge test --match-path ./test/Reentrancy.t.sol
forge test --match-path ./test/SelectorClash.t.sol
forge test --match-path ./test/Overflow.t.sol
forge test --match-path ./test/SigReplay.t.sol
forge test --match-path ./test/Randomness.t.sol
forge test --match-path ./test/Dos.t.sol
forge test --match-path ./test/Dos.t.sol --mt "testDosGame"
forge test --match-path ./test/ContractCheck.t.sol
forge test --match-path ./test/txOrigin.t.sol
forge test --match-path ./test/Oracle.t.sol -vvv
forge test --match-path ./test/SelfDestruct.t.sol -vvv
```

## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

-   **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
-   **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
-   **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
-   **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
