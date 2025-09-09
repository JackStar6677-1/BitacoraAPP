@echo off
title Bitacora de Sala de Computacion
color 0A

echo.
echo ========================================
echo   BITACORA DE SALA DE COMPUTACION
echo   COLEGIO POLIVALENTE SAN CRISTOBAL APOSTOL
echo ========================================
echo.

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
    powershell -Command "& {$WshShell = New-Object -comObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('%USERPROFILE%\Desktop\Bitacora de Sala de Computacion.lnk'); $Shortcut.TargetPath = '%APP_PATH%\start_bitacora.bat'; $Shortcut.WorkingDirectory = '%APP_PATH%'; $Shortcut.Description = 'Iniciar Bitacora de Sala de Computacion'; $Shortcut.IconLocation = '%APP_PATH%\static\imagenes\logo2.ico'; $Shortcut.Save()}" >nul 2>&1
    echo ✅ Acceso directo creado en escritorio

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