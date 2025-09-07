@echo off
title Bitacora de Sala de Computacion - Instalacion y Ejecucion
color 0A
echo.
echo ========================================
echo   BITACORA DE SALA DE COMPUTACION
echo   INSTALACION Y EJECUCION SIMPLE
echo ========================================
echo.

cd /d "%~dp0"

REM Verificar Python
echo [1/4] Verificando Python...
python --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Python no encontrado. Instala Python 3.8 o superior
    pause
    exit /b 1
)
echo ✅ Python encontrado

REM Crear entorno virtual si no existe
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
echo.
echo [3/4] Activando entorno virtual...
call venv\Scripts\activate.bat
if errorlevel 1 (
    echo ❌ Error activando entorno virtual
    pause
    exit /b 1
)
echo ✅ Entorno virtual activado

REM Instalar dependencias
echo.
echo [4/4] Instalando dependencias...
echo Esto puede tomar unos minutos, por favor espera...
echo.

pip install flask flask-dance flask-mail reportlab python-docx requests werkzeug jinja2 markupsafe itsdangerous click blinker oauthlib requests-oauthlib certifi charset-normalizer idna urllib3 lxml pillow

if errorlevel 1 (
    echo ❌ Error instalando dependencias
    pause
    exit /b 1
)
echo ✅ Dependencias instaladas

REM Verificar archivos necesarios
echo.
echo Verificando archivos de la aplicacion...
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
echo    CONFIGURACION INCLUIDA
echo ========================================
echo.
echo ✅ La aplicacion incluye configuracion predeterminada
echo ✅ No se requiere configuracion adicional
echo ✅ Credenciales de Google OAuth ya configuradas
echo ✅ Correos predeterminados ya configurados
echo.

REM Ejecutar aplicacion
echo ========================================
echo    INICIANDO APLICACION
echo ========================================
echo.
echo ✅ Servidor iniciado en: http://localhost:5000
echo ✅ Navegador se abrira automaticamente
echo ✅ Presiona Ctrl+C para detener el servidor
echo.

python app.py

pause