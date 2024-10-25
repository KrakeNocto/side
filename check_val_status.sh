#!/bin/bash

OUTPUT_FILE="active_vals"
JAILED_OUTPUT_FILE="jailed_vals"

VALIDATOR_ADDRESSES=(
  "cosmosvaloper1..."
  "cosmosvaloper2..."
  "cosmosvaloper3..."
)

> "$OUTPUT_FILE"
> "$JAILED_OUTPUT_FILE"

for VALIDATOR_ADDRESS in "${VALIDATOR_ADDRESSES[@]}"; do
  response=$(/root/go/bin/sided query staking validator "$VALIDATOR_ADDRESS" -o json)
  
 if [[ "$status" == "BOND_STATUS_BONDED" && "$jailed" == "false" ]]; then
    echo "$VALIDATOR_ADDRESS активен"
    echo "$VALIDATOR_ADDRESS" >> "$ACTIVE_OUTPUT_FILE"
  elif [[ "$jailed" == "true" ]]; then
    echo "$VALIDATOR_ADDRESS находится в статусе jailed"
    echo "$VALIDATOR_ADDRESS" >> "$JAILED_OUTPUT_FILE"
  else
    echo "$VALIDATOR_ADDRESS не активен"
  fi
done

echo "Список активных валидаторов записан в $ACTIVE_OUTPUT_FILE"
echo "Список валидаторов в статусе jailed записан в $JAILED_OUTPUT_FILE"
