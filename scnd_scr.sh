#!/bin/bash

# Скрипт для тестирования doesitwork.sh с тремя разными наборами параметров

echo "=== ТЕСТ 1 ==="
{
    echo "test_folder_1"    # путь к директории
    echo "10"            # размер образа в MB
    echo "50"            # лимит использования в %
} | ./deepseek.sh

echo ""
echo "=== ТЕСТ 2 ==="
{
    echo "test_folder_2"   # путь к директории  
    echo "20"            # размер образа в MB
    echo "70"            # лимит использования в %
} | ./deepseek.sh

echo ""
echo "=== ТЕСТ 3 ==="
{
    echo "test_folder_3"    # путь к директории
    echo "15"            # размер образа в MB
    echo "30"            # лимит использования в %
} | ./deepseek.sh

