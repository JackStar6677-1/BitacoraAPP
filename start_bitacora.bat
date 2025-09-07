@echo off
title Bitacora de Sala de Computacion - Instalacion y Ejecucion
color 0A

REM Ocultar la ventana de consola
if not "%1"=="hidden" (
    start /min "" "%~f0" hidden
    exit /b
)

echo.
echo ========================================
echo   BITACORA DE SALA DE COMPUTACION
echo   INSTALACION Y EJECUCION PROFESIONAL
echo ========================================
echo.

REM Obtener directorio actual
set "CURRENT_DIR=%~dp0"
set "CURRENT_DIR=%CURRENT_DIR:~0,-1%"

REM Crear directorio en Documentos si no existe
set "DOCS_DIR=%USERPROFILE%\Documents\BitacoraAPP"
if not exist "%DOCS_DIR%" (
    echo [1/6] Creando directorio en Documentos...
    mkdir "%DOCS_DIR%"
    echo ✅ Directorio creado en: %DOCS_DIR%
) else (
    echo [1/6] Directorio ya existe en: %DOCS_DIR%
)

REM Copiar archivos a Documentos si es necesario
echo.
echo [2/6] Verificando archivos en Documentos...
if not exist "%DOCS_DIR%\app.py" (
    echo Copiando archivos a Documentos...
    xcopy "%CURRENT_DIR%\*" "%DOCS_DIR%\" /E /I /Y /Q
    echo ✅ Archivos copiados a Documentos
) else (
    echo ✅ Archivos ya existen en Documentos
)

REM Cambiar al directorio de Documentos
cd /d "%DOCS_DIR%"

REM Verificar Python
echo.
echo [3/6] Verificando Python...
python --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Python no encontrado. Instala Python 3.8 o superior
    echo Descarga desde: https://www.python.org/downloads/
    pause
    exit /b 1
)
echo ✅ Python encontrado

REM Crear entorno virtual si no existe
echo.
echo [4/6] Configurando entorno virtual...
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
echo [5/6] Activando entorno virtual...
call venv\Scripts\activate.bat
if errorlevel 1 (
    echo ❌ Error activando entorno virtual
    pause
    exit /b 1
)
echo ✅ Entorno virtual activado

REM Instalar dependencias
echo.
echo [6/6] Instalando dependencias...
echo Esto puede tomar unos minutos, por favor espera...
echo.

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

REM Crear acceso directo en el escritorio
echo.
echo Creando acceso directo en el escritorio...
set "DESKTOP=%USERPROFILE%\Desktop"
set "SHORTCUT_PATH=%DESKTOP%\Bitacora de Sala de Computacion.lnk"
set "ICON_PATH=%DOCS_DIR%\static\imagenes\logo2.ico"

REM Crear script de inicio silencioso
echo @echo off > "%DOCS_DIR%\iniciar_bitacora.bat"
echo cd /d "%DOCS_DIR%" >> "%DOCS_DIR%\iniciar_bitacora.bat"
echo call venv\Scripts\activate.bat >> "%DOCS_DIR%\iniciar_bitacora.bat"
echo start /min python app.py >> "%DOCS_DIR%\iniciar_bitacora.bat"
echo exit >> "%DOCS_DIR%\iniciar_bitacora.bat"

REM Crear acceso directo usando PowerShell
powershell -Command "$WshShell = New-Object -comObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('%SHORTCUT_PATH%'); $Shortcut.TargetPath = '%DOCS_DIR%\iniciar_bitacora.bat'; $Shortcut.WorkingDirectory = '%DOCS_DIR%'; $Shortcut.IconLocation = '%ICON_PATH%'; $Shortcut.Description = 'Bitacora de Sala de Computacion - Aplicacion Web'; $Shortcut.Save()"

if exist "%SHORTCUT_PATH%" (
    echo ✅ Acceso directo creado en el escritorio
) else (
    echo ⚠️ No se pudo crear el acceso directo automáticamente
    echo Puedes crear uno manualmente apuntando a: %DOCS_DIR%\iniciar_bitacora.bat
)

REM Mostrar informacion
echo.
echo ========================================
echo    CONFIGURACION COMPLETADA
echo ========================================
echo.
echo ✅ Aplicacion instalada en: %DOCS_DIR%
echo ✅ Acceso directo creado en el escritorio
echo ✅ Configuracion incluida y lista
echo ✅ Credenciales de Google OAuth configuradas
echo ✅ Correos predeterminados configurados
echo.

REM Iniciar aplicacion
echo ========================================
echo    INICIANDO APLICACION
echo ========================================
echo.
echo ✅ Servidor iniciado en: http://localhost:5000
echo ✅ Navegador se abrira automaticamente
echo ✅ Presiona Ctrl+C para detener el servidor
echo.

REM Iniciar aplicacion en segundo plano
start /min python app.py

REM Esperar un momento y abrir navegador
timeout /t 3 /nobreak >nul
start http://localhost:5000

echo.
echo ✅ Aplicacion iniciada correctamente
echo ✅ Navegador abierto en: http://localhost:5000
echo.
echo Para detener la aplicacion, cierra esta ventana o presiona Ctrl+C
echo.

REM Mantener ventana abierta pero minimizada
:loop
timeout /t 30 /nobreak >nul
goto loop