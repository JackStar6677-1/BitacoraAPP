@echo off
title Mover BitacoraAPP a Carpeta Segura
color 0A

echo.
echo ========================================
echo   MOVIENDO BITACORAAPP A CARPETA SEGURA
echo ========================================
echo.

REM Obtener directorio actual
set "CURRENT_DIR=%~dp0"
set "CURRENT_DIR=%CURRENT_DIR:~0,-1%"

REM Crear carpeta segura en Documentos del usuario
set "SAFE_DIR=%USERPROFILE%\Documents\BitacoraAPP"

echo [1/4] Verificando ubicacion actual...
echo Ubicacion actual: %CURRENT_DIR%

REM Verificar si estamos en carpeta del sistema
echo %CURRENT_DIR% | findstr /C:"System32" >nul
if not errorlevel 1 (
    echo ⚠️  Detectada carpeta del sistema - Se requiere movimiento
    set "NEED_MOVE=1"
) else (
    echo ✅ Ubicacion segura - No se requiere movimiento
    set "NEED_MOVE=0"
)

if "%NEED_MOVE%"=="1" (
    echo.
    echo [2/4] Creando carpeta segura...
    if not exist "%SAFE_DIR%" (
        mkdir "%SAFE_DIR%"
        echo ✅ Carpeta creada: %SAFE_DIR%
    ) else (
        echo ✅ Carpeta ya existe: %SAFE_DIR%
    )
    
    echo.
    echo [3/4] Copiando archivos...
    echo Copiando desde: %CURRENT_DIR%
    echo Copiando hacia: %SAFE_DIR%
    
    REM Copiar todos los archivos excepto venv
    xcopy "%CURRENT_DIR%\*" "%SAFE_DIR%\" /E /I /H /Y /EXCLUDE:exclude_list.txt >nul 2>&1
    
    REM Crear archivo de exclusion para venv
    echo venv\ > exclude_list.txt
    echo __pycache__\ >> exclude_list.txt
    echo *.pyc >> exclude_list.txt
    
    REM Copiar archivos importantes
    copy "%CURRENT_DIR%\*.py" "%SAFE_DIR%\" >nul 2>&1
    copy "%CURRENT_DIR%\*.bat" "%SAFE_DIR%\" >nul 2>&1
    copy "%CURRENT_DIR%\*.ps1" "%SAFE_DIR%\" >nul 2>&1
    copy "%CURRENT_DIR%\*.vbs" "%SAFE_DIR%\" >nul 2>&1
    copy "%CURRENT_DIR%\*.json" "%SAFE_DIR%\" >nul 2>&1
    copy "%CURRENT_DIR%\*.txt" "%SAFE_DIR%\" >nul 2>&1
    copy "%CURRENT_DIR%\*.md" "%SAFE_DIR%\" >nul 2>&1
    copy "%CURRENT_DIR%\*.ico" "%SAFE_DIR%\" >nul 2>&1
    
    REM Copiar carpetas
    if exist "%CURRENT_DIR%\static" (
        xcopy "%CURRENT_DIR%\static" "%SAFE_DIR%\static\" /E /I /H /Y >nul 2>&1
    )
    if exist "%CURRENT_DIR%\templates" (
        xcopy "%CURRENT_DIR%\templates" "%SAFE_DIR%\templates\" /E /I /H /Y >nul 2>&1
    )
    if exist "%CURRENT_DIR%\docs" (
        xcopy "%CURRENT_DIR%\docs" "%SAFE_DIR%\docs\" /E /I /H /Y >nul 2>&1
    )
    
    echo ✅ Archivos copiados correctamente
    
    echo.
    echo [4/4] Creando acceso directo en carpeta segura...
    cd /d "%SAFE_DIR%"
    
    REM Crear acceso directo en escritorio
    powershell -Command "& {$WshShell = New-Object -comObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('%USERPROFILE%\Desktop\Bitacora de Sala de Computacion.lnk'); $Shortcut.TargetPath = '%SAFE_DIR%\iniciar_pwa_sin_consola.vbs'; $Shortcut.WorkingDirectory = '%SAFE_DIR%'; $Shortcut.Description = 'Iniciar Bitacora de Sala de Computacion - PWA'; $Shortcut.IconLocation = '%SAFE_DIR%\static\imagenes\logo2.ico'; $Shortcut.Save()}"
    
    echo ✅ Acceso directo creado en escritorio
    echo.
    echo ========================================
    echo   MOVIMIENTO COMPLETADO
    echo ========================================
    echo.
    echo ✅ Aplicacion movida a: %SAFE_DIR%
    echo ✅ Acceso directo actualizado en escritorio
    echo ✅ Ahora puedes usar la aplicacion desde la nueva ubicacion
    echo.
    echo Presiona cualquier tecla para abrir la nueva ubicacion...
    pause >nul
    
    REM Abrir carpeta de destino
    explorer "%SAFE_DIR%"
    
    echo.
    echo ¿Deseas ejecutar la aplicacion ahora? (S/N)
    set /p "RUN_APP="
    if /i "%RUN_APP%"=="S" (
        echo Ejecutando aplicacion...
        cd /d "%SAFE_DIR%"
        start_bitacora.bat
    )
) else (
    echo.
    echo ✅ La aplicacion ya esta en una ubicacion segura
    echo ✅ No se requiere movimiento
    echo.
    echo Presiona cualquier tecla para continuar...
    pause >nul
)

REM Limpiar archivo temporal
if exist "exclude_list.txt" del "exclude_list.txt" >nul 2>&1

echo.
echo Proceso completado.
pause
