#!/bin/bash

# Количество кошельков, которые нужно создать
WALLET_COUNT=220
KEYRING_BACKEND="test"  # Для тестирования можно использовать keyring backend "test"
CHAIN_ID="sidechain-testnet-4" # id сети

# Файлы для хранения мнемоник и адресов
MNEMONICS_FILE="mnems.txt"
ADDRESSES_FILE="addresses.txt"

# Очистим или создадим файлы для хранения данных
> $MNEMONICS_FILE
> $ADDRESSES_FILE

for ((i=1; i<=WALLET_COUNT; i++)); do
  # Генерация нового кошелька
  WALLET_NAME="wallet_$i"
  echo "Создаем кошелек: $WALLET_NAME"

  # Создание кошелька с использованием gaiad (или другой утилиты)
  /root/.side/cosmovisor/genesis/bin/sided keys add $WALLET_NAME --keyring-backend $KEYRING_BACKEND --output json > wallet_$i.json

  # Извлечение адреса и мнемоники из JSON
  ADDRESS=$(jq -r '.address' wallet_$i.json)
  MNEMONIC=$(jq -r '.mnemonic' wallet_$i.json)

  # Сохранение только мнемоники в файл
  echo "$MNEMONIC" >> $MNEMONICS_FILE

  # Сохранение только адреса в файл с добавлением явного переноса строки
  echo "$ADDRESS" >> $ADDRESSES_FILE

  # Удаление временного JSON файла
  rm wallet_$i.json
done

echo "Кошельки успешно созданы!"
echo "Мнемоники сохранены в $MNEMONICS_FILE"
echo "Адреса сохранены в $ADDRESSES_FILE"
