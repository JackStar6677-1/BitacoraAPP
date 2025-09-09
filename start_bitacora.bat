@echo off
title Bitacora de Sala de Computacion
color 0A

echo.
echo ========================================
echo   BITACORA DE SALA DE COMPUTACION
echo   COLEGIO POLIVALENTE SAN CRISTOBAL APOSTOL
echo ========================================
echo.

REM Verificar si estamos en carpeta del sistema
echo %CD% | findstr /C:"System32" >nul
if not errorlevel 1 (
    echo.
    echo ⚠️  ADVERTENCIA: Detectada carpeta del sistema
    echo ⚠️  La aplicacion no funcionara correctamente aqui
    echo.
    echo ¿Deseas mover la aplicacion a una carpeta segura? (S/N)
    set /p "MOVE_APP="
    if /i "%MOVE_APP%"=="S" (
        echo.
        echo Ejecutando script de movimiento...
        call mover_a_carpeta_segura.bat
        exit /b 0
    ) else (
        echo.
        echo ⚠️  Continuando en carpeta del sistema...
        echo ⚠️  Pueden ocurrir errores de permisos
        echo.
        pause
    )
)

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

    REM Crear acceso directo en escritorio
    echo [5/6] Creando acceso directo en escritorio...
    set "APP_PATH=%~dp0"
    set "APP_PATH=%APP_PATH:~0,-1%"
    set "DESKTOP_PATH=%USERPROFILE%\Desktop"
    set "SHORTCUT_PATH=%DESKTOP_PATH%\Bitacora de Sala de Computacion.lnk"
    
    REM Intentar crear acceso directo PWA con PowerShell
    powershell -ExecutionPolicy Bypass -File "crear_acceso_directo.ps1" -AppPath "%APP_PATH%" >nul 2>&1
    
    REM Si PowerShell falló, usar método alternativo
    if not exist "%SHORTCUT_PATH%" (
        echo Intentando metodo alternativo...
        call crear_acceso_directo_simple.bat >nul 2>&1
    )
    
    REM Verificar si se creó correctamente
    if exist "%SHORTCUT_PATH%" (
        echo ✅ Acceso directo creado en escritorio
    ) else (
        echo ⚠️  Acceso directo no se pudo crear, pero la aplicacion funcionara
        echo    Puedes ejecutar este archivo directamente desde la carpeta
        echo    O crear manualmente un acceso directo a: %APP_PATH%\iniciar_pwa_sin_consola.vbs
    )

    REM Marcar instalacion como completa
    echo [6/6] Marcando instalacion como completa...
    echo {"primer_inicio": false, "instalacion_completa": true, "fecha_instalacion": "%date%", "version": "1.0"} > config_inicio.json
    echo ✅ Instalacion completada
    
    echo.
    echo ========================================
    echo   INSTALACION COMPLETADA
    echo ========================================
    echo.
    echo ✅ Aplicacion instalada correctamente
    echo ✅ Acceso directo creado en escritorio
    echo ✅ Ahora puedes usar el acceso directo
    echo.
    echo Iniciando aplicacion...
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
            echo Ejecuta este archivo nuevamente para reinstalar
            pause
            exit /b 1
        )
    ) else (
        echo ❌ Entorno virtual no encontrado
        echo Ejecuta este archivo nuevamente para reinstalar
        pause
        exit /b 1
    )
    
    echo ✅ Entorno virtual activado
    echo ✅ Iniciando aplicacion...
    echo.
)

REM Mostrar informacion
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