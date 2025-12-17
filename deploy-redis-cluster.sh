#!/bin/bash

echo "======================================================"
echo "        РАЗВЕРТЫВАНИЕ КЛАСТЕРА REDIS"
echo "======================================================"
echo "Автор: Олеся Шишкова"
echo "Группа: 22 ГМУ-УЦП 11.2"
echo "Дата: $(date)"
echo "======================================================"
echo ""

# Проверка наличия Docker
echo "1. Проверка установки Docker..."
if ! command -v docker &> /dev/null; then
    echo "   ❌ Ошибка: Docker не установлен."
    echo "   Установите Docker: https://docs.docker.com/get-docker/"
    exit 1
else
    echo "   ✅ Docker установлен: $(docker --version)"
fi

# Проверка наличия Docker Compose
echo "2. Проверка установки Docker Compose..."
if ! command -v docker-compose &> /dev/null; then
    echo "   ❌ Ошибка: Docker Compose не установлен."
    echo "   Установите Docker Compose: https://docs.docker.com/compose/install/"
    exit 1
else
    echo "   ✅ Docker Compose установлен: $(docker-compose --version)"
fi

echo ""
echo "3. Запуск кластера Redis..."
echo "   Конфигурация:"
echo "   - 3 мастера (порты: 7001, 7002, 7003)"
echo "   - 6 реплик (порты: 7004-7009)"
echo "   - Всего: 9 узлов"
echo ""

# Запуск контейнеров
echo "4. Запуск Docker контейнеров..."
docker-compose up -d

echo "5. Ожидание запуска всех узлов (30 секунд)..."
for i in {1..30}; do
    echo -n "."
    sleep 1
done
echo ""

echo "6. Проверка состояния контейнеров..."
echo "------------------------------------------------------"
docker ps --filter "name=redis" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
echo "------------------------------------------------------"

echo ""
echo "7. Проверка работы кластера..."
echo "Подключаемся к мастер-ноде 1..."

# Даем дополнительное время для настройки кластера
sleep 10

echo "8. Получение информации о кластере..."
echo "------------------------------------------------------"
docker exec redis-node-1 redis-cli -p 7001 cluster info | grep -E "(cluster_state|cluster_slots|cluster_size|cluster_known_nodes)"
echo "------------------------------------------------------"

echo ""
echo "9. Просмотр распределения слотов..."
echo "------------------------------------------------------"
docker exec redis-node-1 redis-cli -p 7001 cluster slots | head -20
echo "------------------------------------------------------"

echo ""
echo "10. Просмотр всех узлов кластера..."
echo "------------------------------------------------------"
docker exec redis-node-1 redis-cli -p 7001 cluster nodes
echo "------------------------------------------------------"

echo ""
echo "11. Тестирование записи/чтения данных..."
echo "Записываем тестовые данные в кластер..."
docker exec redis-node-1 redis-cli -p 7001 SET student:1 "Олеся Шишкова, 22 ГМУ-УЦП 11.2"
docker exec redis-node-1 redis-cli -p 7001 SET project "Redis Cluster Deployment"
docker exec redis-node-1 redis-cli -p 7001 SET test_key "Hello from Redis Cluster!"

echo "Читаем данные..."
echo "Данные студента: $(docker exec redis-node-2 redis-cli -p 7002 GET student:1)"
echo "Название проекта: $(docker exec redis-node-3 redis-cli -p 7003 GET project)"
echo "Тестовое сообщение: $(docker exec redis-node-4 redis-cli -p 7004 GET test_key)"

echo ""
echo "======================================================"
echo "              КЛАСТЕР REDIS РАЗВЕРНУТ!"
echo "======================================================"
echo ""
echo "ИНФОРМАЦИЯ О КЛАСТЕРЕ:"
echo "• Мастер-ноды:"
echo "  - redis-node-1:7001"
echo "  - redis-node-2:7002"
echo "  - redis-node-3:7003"
echo ""
echo "• Реплики:"
echo "  - redis-node-4:7004"
echo "  - redis-node-5:7005"
echo "  - redis-node-6:7006"
echo "  - redis-node-7:7007"
echo "  - redis-node-8:7008"
echo "  - redis-node-9:7009"
echo ""
echo "КОМАНДЫ ДЛЯ УПРАВЛЕНИЯ:"
echo "• Просмотр логов:    docker-compose logs -f"
echo "• Остановка:         docker-compose down"
echo "• Перезапуск:        docker-compose restart"
echo "• Проверка здоровья: docker exec redis-node-1 redis-cli -p 7001 cluster info"
echo ""
echo "======================================================"
echo "               ВЫПОЛНЕНИЕ ЗАВЕРШЕНО"
echo "======================================================"
