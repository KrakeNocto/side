#!/bin/bash

OUTPUT_FILE="active_vals"

VALIDATOR_ADDRESSES=(
  "cosmosvaloper1..."
  "cosmosvaloper2..."
  "cosmosvaloper3..."
)

> "$OUTPUT_FILE"

for VALIDATOR_ADDRESS in "${VALIDATOR_ADDRESSES[@]}"; do
  status=$(/root/go/bin/sided query staking validator "$VALIDATOR_ADDRESS" -o json | jq -r '.status')
  
  if [[ "$status" == "BOND_STATUS_BONDED" ]]; then
    echo "$VALIDATOR_ADDRESS активен"
    echo "$VALIDATOR_ADDRESS" >> "$OUTPUT_FILE"
  else
    echo "$VALIDATOR_ADDRESS не активен"
  fi
done

echo "Список активных валидаторов записан в $OUTPUT_FILE"
