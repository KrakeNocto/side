import requests
import time
from telegram import Bot
from telegram.error import TelegramError

# Задайте параметры
COSMOS_NODE_RPC = "http://localhost:26657"              # URL RPC вашего Cosmos-узла
VALIDATOR_ADDRESSES = ["cosmosvaloper1...", "cosmosvaloper2..."]  # список адресов валидаторов
TELEGRAM_TOKEN = "your_telegram_bot_token"              # токен вашего Telegram-бота
CHAT_ID = "your_telegram_chat_id"                       # ID чата для отправки уведомлений
CHECK_INTERVAL = 60                                     # интервал проверки в секундах

# Инициализация бота
bot = Bot(token=TELEGRAM_TOKEN)

# Функция для проверки пропущенных блоков у валидаторов
def check_missed_blocks():
    try:
        # Получаем текущий блок сети
        response = requests.get(f"{COSMOS_NODE_RPC}/status").json()
        block_height = int(response['result']['sync_info']['latest_block_height'])
        
        missed_validators_info = []

        for validator_address in VALIDATOR_ADDRESSES:
            # Запрос информации по валидатору
            validator_info = requests.get(
                f"{COSMOS_NODE_RPC}/cosmos/slashing/v1beta1/signing_infos/{validator_address}"
            ).json()
            
            # Получаем количество пропущенных блоков
            missed_blocks = int(validator_info["val_signing_info"].get("missed_blocks_counter", 0))

            # Если валидатор пропустил блоки, добавляем в список
            if missed_blocks > 0:
                missed_validators_info.append(f"{validator_address}: {missed_blocks} missed blocks")

        # Отправляем уведомление в Telegram, если есть валидаторы, пропускающие блоки
        if missed_validators_info:
            message = f"⚠️ Пропущенные блоки у валидаторов на высоте {block_height}:\n\n" + "\n".join(missed_validators_info)
            bot.send_message(chat_id=CHAT_ID, text=message)
    
    except requests.RequestException as e:
        print(f"Ошибка при запросе к узлу: {e}")
    except TelegramError as e:
        print(f"Ошибка при отправке сообщения в Telegram: {e}")

# Основной цикл для регулярной проверки
def main():
    while True:
        check_missed_blocks()
        time.sleep(CHECK_INTERVAL)

if __name__ == "__main__":
    main()
