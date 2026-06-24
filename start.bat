@echo off
cls
chcp 65001 > nul
echo ===================================================
echo       Умный запуск проекта TRELLIS-DOCKER
echo ===================================================
echo.

:: 1. Проверяем, запущен ли сам Docker Desktop
docker info >nul 2>&1
if %errorlevel% neq 0 (
    echo [ОШИБКА] Docker Desktop не запущен! 
    echo Пожалуйста, включите Docker Desktop, подождите полминуты и запустите этот файл снова.
    echo.
    pause
    exit /b
)

:: 2. Проверяем, существует ли уже контейнер trellis-container
docker ps -a --format "{{.Names}}" | findstr /I "^trellis-container$" >nul
if %errorlevel% equ 0 (
    echo [ИНФО] Контейнер trellis-container найден в системе.
    
    :: Проверяем, запущен ли он прямо сейчас
    docker ps --format "{{.Names}}" | findstr /I "^trellis-container$" >nul
    if %errorlevel% equ 0 (
        echo [ИНФО] Контейнер уже работает в активном режиме.
    ) else (
        echo [ИНФО] Контейнер остановлен. Пробуждаем его...
        docker start trellis-container
    )
) else (
    echo [ИНФО] Контейнер не найден. Создаем и запускаем новый из образа 3d-gpu-app...
    docker run -d --gpus all -p 7860:7860 --name trellis-container 3d-gpu-app
)

echo.
echo [ИНФО] Даем серверу время на загрузку нейросети в память видеокарты...
:: Команда timeout сделает паузу на 15 секунд. 
:: Если сервер стартует быстрее или дольше, поменяйте цифру 15.
timeout /t 15

echo.
echo [УСПЕХ] Открываем веб-интерфейс в браузере...
start http://localhost:7860

echo ---------------------------------------------------
echo Вывод логов контейнера (Для закрытия окна нажмите Ctrl+C):
echo ---------------------------------------------------
:: 4. Подключаемся к логам
docker logs -f trellis-container

pause