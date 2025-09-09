@echo off
title Sincronizar Datos BitacoraAPP
color 0A

echo.
echo ========================================
echo   SINCRONIZAR DATOS BITACORAAPP
echo ========================================
echo.

REM Obtener directorio actual
set "CURRENT_DIR=%~dp0"
set "CURRENT_DIR=%CURRENT_DIR:~0,-1%"

echo [1/4] Verificando ubicacion de datos...
echo Directorio actual: %CURRENT_DIR%

REM Verificar si existe base de datos
if exist "app.db" (
    echo ✅ Base de datos encontrada: app.db
    set "DB_EXISTS=1"
) else (
    echo ⚠️  Base de datos no encontrada
    set "DB_EXISTS=0"
)

echo.
echo [2/4] Opciones de sincronizacion:
echo.
echo 1. Exportar datos (crear archivo de respaldo)
echo 2. Importar datos (restaurar desde archivo)
echo 3. Sincronizar con otro PC (red local)
echo 4. Crear respaldo completo
echo.
set /p "OPTION=Selecciona una opcion (1-4): "

if "%OPTION%"=="1" goto export_data
if "%OPTION%"=="2" goto import_data
if "%OPTION%"=="3" goto sync_network
if "%OPTION%"=="4" goto backup_complete
goto invalid_option

:export_data
echo.
echo [3/4] Exportando datos...
set "BACKUP_FILE=bitacora_backup_%date:~-4,4%%date:~-10,2%%date:~-7,2%_%time:~0,2%%time:~3,2%%time:~6,2%.db"
set "BACKUP_FILE=%BACKUP_FILE: =0%"

if exist "app.db" (
    copy "app.db" "%BACKUP_FILE%" >nul 2>&1
    if not errorlevel 1 (
        echo ✅ Datos exportados a: %BACKUP_FILE%
    ) else (
        echo ❌ Error al exportar datos
    )
) else (
    echo ❌ No hay datos para exportar
)
goto end

:import_data
echo.
echo [3/4] Importando datos...
echo.
echo Archivos de respaldo disponibles:
dir *.db /b 2>nul
echo.
set /p "BACKUP_FILE=Ingresa el nombre del archivo de respaldo: "

if exist "%BACKUP_FILE%" (
    copy "%BACKUP_FILE%" "app.db" >nul 2>&1
    if not errorlevel 1 (
        echo ✅ Datos importados correctamente
    ) else (
        echo ❌ Error al importar datos
    )
) else (
    echo ❌ Archivo de respaldo no encontrado
)
goto end

:sync_network
echo.
echo [3/4] Sincronizacion en red local...
echo.
echo Esta funcion permite sincronizar datos con otro PC en la red local.
echo.
set /p "PC_IP=Ingresa la IP del otro PC: "
set /p "PC_PATH=Ingresa la ruta completa en el otro PC (ej: C:\BitacoraAPP): "

echo.
echo Opciones:
echo 1. Enviar datos a otro PC
echo 2. Recibir datos de otro PC
set /p "SYNC_OPTION=Selecciona opcion (1-2): "

if "%SYNC_OPTION%"=="1" (
    echo Enviando datos a %PC_IP%...
    copy "app.db" "\\%PC_IP%\%PC_PATH%\app.db" >nul 2>&1
    if not errorlevel 1 (
        echo ✅ Datos enviados correctamente
    ) else (
        echo ❌ Error al enviar datos. Verifica la conexion y permisos.
    )
) else if "%SYNC_OPTION%"=="2" (
    echo Recibiendo datos de %PC_IP%...
    copy "\\%PC_IP%\%PC_PATH%\app.db" "app.db" >nul 2>&1
    if not errorlevel 1 (
        echo ✅ Datos recibidos correctamente
    ) else (
        echo ❌ Error al recibir datos. Verifica la conexion y permisos.
    )
) else (
    echo ❌ Opcion invalida
)
goto end

:backup_complete
echo.
echo [3/4] Creando respaldo completo...
set "BACKUP_DIR=Respaldo_BitacoraAPP_%date:~-4,4%%date:~-10,2%%date:~-7,2%"
set "BACKUP_DIR=%BACKUP_DIR: =0%"

if not exist "%BACKUP_DIR%" mkdir "%BACKUP_DIR%"

REM Copiar archivos importantes
copy "app.db" "%BACKUP_DIR%\" >nul 2>&1
copy "config_inicio.json" "%BACKUP_DIR%\" >nul 2>&1
copy "bitacora_backup.json" "%BACKUP_DIR%\" >nul 2>&1
copy "bitacora_backup.csv" "%BACKUP_DIR%\" >nul 2>&1

echo ✅ Respaldo completo creado en: %BACKUP_DIR%
goto end

:invalid_option
echo ❌ Opcion invalida
goto end

:end
echo.
echo [4/4] Proceso completado
echo.
echo ========================================
echo   SINCRONIZACION COMPLETADA
echo ========================================
echo.
echo Para actualizar la aplicacion en otro PC:
echo 1. Ejecuta este script en el PC actual
echo 2. Exporta los datos (opcion 1)
echo 3. Copia el archivo de respaldo al otro PC
echo 4. Ejecuta este script en el otro PC
echo 5. Importa los datos (opcion 2)
echo.
pause
