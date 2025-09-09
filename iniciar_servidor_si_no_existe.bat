@echo off
title Verificando Servidor BitacoraAPP
color 0A

echo.
echo ========================================
echo   VERIFICANDO SERVIDOR BITACORAAPP
echo ========================================
echo.

REM Verificar si el servidor ya está corriendo
netstat -an | find "5000" | find "LISTENING" >nul
if not errorlevel 1 (
    echo ✅ Servidor ya está corriendo en puerto 5000
    echo ✅ Abriendo aplicación...
    start http://localhost:5000
    exit /b 0
)

echo ⚠️  Servidor no está corriendo
echo 🚀 Iniciando servidor...

REM Cambiar al directorio de la aplicación
cd /d "%~dp0"

REM Verificar si es el primer inicio
if not exist "config_inicio.json" (
    echo 🚀 PRIMER INICIO - Instalando aplicacion...
    echo.
    
    REM Limpiar sesiones anteriores
    echo [1/6] Limpiando sesiones anteriores...
    taskkill /f /im python.exe >nul 2>&1
    echo ✅ Sesiones anteriores limpiadas

    REM Verificar Python
    echo [2/6] Verificando Python...
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
    echo [3/6] Configurando entorno virtual...
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
    echo [4/6] Instalando dependencias...
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

    REM Marcar instalacion como completa
    echo [5/6] Marcando instalacion como completa...
    echo {"primer_inicio": false, "instalacion_completa": true, "fecha_instalacion": "%date%", "version": "1.0"} > config_inicio.json
    echo ✅ Instalacion completada
    
    echo.
    echo ========================================
    echo   INSTALACION COMPLETADA
    echo ========================================
    echo.
    echo ✅ Aplicacion instalada correctamente
    echo ✅ Iniciando servidor...
    echo.
) else (
    echo ⚡ INICIO RAPIDO - Aplicacion ya instalada
    echo.
    
    REM Limpiar sesiones anteriores
    taskkill /f /im python.exe >nul 2>&1
    
    REM Activar entorno virtual
    if exist "venv\Scripts\activate.bat" (
        call venv\Scripts\activate.bat
        if errorlevel 1 (
            echo ❌ Error activando entorno virtual
            echo Ejecuta start_bitacora.bat para reinstalar
            pause
            exit /b 1
        )
    ) else (
        echo ❌ Entorno virtual no encontrado
        echo Ejecuta start_bitacora.bat para reinstalar
        pause
        exit /b 1
    )
    
    echo ✅ Entorno virtual activado
    echo ✅ Iniciando servidor...
    echo.
)

REM Iniciar servidor en segundo plano
echo ========================================
echo    INICIANDO SERVIDOR
echo ========================================
echo.
echo ✅ Servidor iniciado en: http://localhost:5000
echo ✅ Abriendo aplicación...
echo.

REM Iniciar servidor y abrir navegador
start /min python app.py

REM Esperar un momento para que el servidor inicie
timeout /t 3 /nobreak >nul

REM Abrir navegador
start http://localhost:5000

echo ✅ Aplicación abierta correctamente
echo.
echo Presiona Ctrl+C para detener el servidor
echo.

REM Mantener ventana abierta para mostrar logs
python app.py
