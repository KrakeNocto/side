#!/bin/bash

KEYRING_BACKEND="test"

# Получение списка ключей
KEYS=$(/root/go/bin/sided keys list --keyring-backend $KEYRING_BACKEND --output json | jq -r '.[].name')

# Удаление каждого ключа
for KEY in $KEYS; do
  echo "Удаляем ключ: $KEY"
  /root/go/bin/sided keys delete $KEY --keyring-backend $KEYRING_BACKEND -y
done

echo "Все ключи удалены."
