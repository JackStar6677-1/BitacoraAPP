@echo off
title Bitacora de Sala de Computacion - Inicio Directo
color 0A

echo.
echo ========================================
echo   BITACORA DE SALA DE COMPUTACION
echo   COLEGIO POLIVALENTE SAN CRISTOBAL APOSTOL
echo ========================================
echo.

REM Verificar Python
echo [1/4] Verificando Python...
python --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Python no encontrado. Instalando Python...
    echo Descarga desde: https://www.python.org/downloads/
    start https://www.python.org/downloads/
    pause
    exit /b 1
)
echo ✅ Python encontrado

REM Crear/activar entorno virtual
echo.
echo [2/4] Configurando entorno virtual...
if not exist "venv" (
    echo Creando entorno virtual...
    python -m venv venv
    if errorlevel 1 (
        echo ❌ Error creando entorno virtual
        pause
        exit /b 1
    )
    echo ✅ Entorno virtual creado
) else (
    echo ✅ Entorno virtual ya existe
)

REM Activar entorno virtual
call venv\Scripts\activate.bat
if errorlevel 1 (
    echo ❌ Error activando entorno virtual
    pause
    exit /b 1
)
echo ✅ Entorno virtual activado

REM Instalar dependencias
echo.
echo [3/4] Instalando dependencias...
echo Esto puede tomar unos minutos...

python -m pip install --upgrade pip >nul 2>&1
pip install flask flask-dance flask-mail reportlab python-docx requests werkzeug jinja2 markupsafe itsdangerous click blinker oauthlib requests-oauthlib certifi charset-normalizer idna urllib3 lxml pillow >nul 2>&1

if errorlevel 1 (
    echo ❌ Error instalando dependencias. Intentando instalacion manual...
    pip install flask flask-dance flask-mail reportlab python-docx requests werkzeug jinja2 markupsafe itsdangerous click blinker oauthlib requests-oauthlib certifi charset-normalizer idna urllib3 lxml pillow
    if errorlevel 1 (
        echo ❌ Error persistente instalando dependencias.
        pause
        exit /b 1
    )
)
echo ✅ Dependencias instaladas

REM Verificar archivos
echo.
echo [4/4] Verificando archivos...
if not exist "app.py" (
    echo ❌ app.py no encontrado
    pause
    exit /b 1
)
if not exist "templates" (
    echo ❌ Carpeta templates no encontrada
    pause
    exit /b 1
)
if not exist "static" (
    echo ❌ Carpeta static no encontrada
    pause
    exit /b 1
)
echo ✅ Archivos verificados

REM Mostrar informacion
echo.
echo ========================================
echo    INICIANDO APLICACION
echo ========================================
echo.
echo ✅ Servidor iniciado en: http://localhost:5000
echo ✅ Navegador se abrira automaticamente
echo ✅ Presiona Ctrl+C para detener el servidor
echo.

REM Iniciar aplicacion
python app.py