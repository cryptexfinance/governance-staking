## Governance Token 

The **DelegatorFactory** is a contract that allows a governor to create a **Delegator** contract that allows it to receive governance token delegation from other users. If the **DelegatorFactory** contract is used, stakers / delegators will earn reward tokens the longer they have staked.

The **delegatorFactory** contract is based on Synthetix Liquidity Rewards contract.


### How to run

1. Clone the Repo
2. Install [dappTools](https://github.com/dapphub/dapptools#installation).
3. Install dependencies `yarn install`

### How to test

Run 

```shell
yarn test
``` 

or

```shell
dapp test --verbosity 1
```
