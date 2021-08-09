#!/usr/bin/env bash

export DAPP_BUILD_OPTIMIZE=1
export DAPP_BUILD_OPTIMIZE_RUNS=999999
# dapp build
dapp test --verbosity 1 # -m gas_usage
# dapp debug
