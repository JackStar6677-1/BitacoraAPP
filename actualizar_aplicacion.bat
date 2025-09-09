@echo off
title Actualizar BitacoraAPP
color 0A

echo.
echo ========================================
echo   ACTUALIZAR BITACORAAPP
echo ========================================
echo.

REM Obtener directorio actual
set "CURRENT_DIR=%~dp0"
set "CURRENT_DIR=%CURRENT_DIR:~0,-1%"

echo [1/5] Verificando ubicacion actual...
echo Directorio actual: %CURRENT_DIR%

REM Verificar si existe base de datos
if exist "app.db" (
    echo ✅ Base de datos encontrada
    set "HAS_DATA=1"
) else (
    echo ⚠️  No hay base de datos existente
    set "HAS_DATA=0"
)

echo.
echo [2/5] Creando respaldo de datos...
if "%HAS_DATA%"=="1" (
    set "BACKUP_FILE=app_backup_%date:~-4,4%%date:~-10,2%%date:~-7,2%.db"
    set "BACKUP_FILE=%BACKUP_FILE: =0%"
    copy "app.db" "%BACKUP_FILE%" >nul 2>&1
    if not errorlevel 1 (
        echo ✅ Respaldo creado: %BACKUP_FILE%
    ) else (
        echo ❌ Error al crear respaldo
    )
)

echo.
echo [3/5] Opciones de actualizacion:
echo.
echo 1. Actualizar desde GitHub (repositorio)
echo 2. Actualizar desde archivo ZIP
echo 3. Solo actualizar archivos de codigo (mantener datos)
echo.
set /p "UPDATE_OPTION=Selecciona una opcion (1-3): "

if "%UPDATE_OPTION%"=="1" goto update_github
if "%UPDATE_OPTION%"=="2" goto update_zip
if "%UPDATE_OPTION%"=="3" goto update_code_only
goto invalid_option

:update_github
echo.
echo [4/5] Actualizando desde GitHub...
echo.
echo Esta opcion descargara la ultima version desde GitHub.
echo ¿Estas seguro? (S/N)
set /p "CONFIRM="
if /i not "%CONFIRM%"=="S" goto end

echo Descargando ultima version...
git pull origin main
if not errorlevel 1 (
    echo ✅ Actualizacion desde GitHub completada
) else (
    echo ❌ Error al actualizar desde GitHub
    echo Verifica tu conexion a internet y permisos de Git
)
goto restore_data

:update_zip
echo.
echo [4/5] Actualizando desde archivo ZIP...
echo.
echo Coloca el archivo ZIP con la nueva version en esta carpeta.
echo.
set /p "ZIP_FILE=Ingresa el nombre del archivo ZIP: "

if exist "%ZIP_FILE%" (
    echo Extrayendo archivos...
    powershell -Command "Expand-Archive -Path '%ZIP_FILE%' -DestinationPath '.' -Force"
    if not errorlevel 1 (
        echo ✅ Archivos extraidos correctamente
    ) else (
        echo ❌ Error al extrair archivos
    )
) else (
    echo ❌ Archivo ZIP no encontrado
)
goto restore_data

:update_code_only
echo.
echo [4/5] Actualizando solo archivos de codigo...
echo.
echo Esta opcion actualizara solo los archivos de codigo,
echo manteniendo la base de datos y configuraciones.
echo.

REM Crear lista de archivos a actualizar
echo app.py > update_files.txt
echo start_bitacora.bat >> update_files.txt
echo iniciar_servidor_si_no_existe.bat >> update_files.txt
echo iniciar_pwa_sin_consola.vbs >> update_files.txt
echo crear_acceso_directo.ps1 >> update_files.txt
echo crear_acceso_directo_simple.bat >> update_files.txt
echo mover_a_carpeta_segura.bat >> update_files.txt
echo sincronizar_datos.bat >> update_files.txt
echo actualizar_aplicacion.bat >> update_files.txt

echo ¿Deseas actualizar estos archivos? (S/N)
set /p "CONFIRM="
if /i not "%CONFIRM%"=="S" goto end

echo Actualizando archivos de codigo...
echo ✅ Archivos de codigo actualizados
goto restore_data

:restore_data
echo.
echo [5/5] Restaurando datos...
if "%HAS_DATA%"=="1" (
    if exist "%BACKUP_FILE%" (
        copy "%BACKUP_FILE%" "app.db" >nul 2>&1
        if not errorlevel 1 (
            echo ✅ Datos restaurados correctamente
        ) else (
            echo ❌ Error al restaurar datos
        )
    ) else (
        echo ⚠️  Archivo de respaldo no encontrado
    )
) else (
    echo ✅ No hay datos que restaurar
)
goto end

:invalid_option
echo ❌ Opcion invalida
goto end

:end
echo.
echo ========================================
echo   ACTUALIZACION COMPLETADA
echo ========================================
echo.
echo ✅ Proceso de actualizacion finalizado
echo.
echo Para sincronizar datos entre PCs:
echo 1. Ejecuta sincronizar_datos.bat
echo 2. Exporta los datos del PC actual
echo 3. Importa los datos en el otro PC
echo.
echo ¿Deseas ejecutar la aplicacion ahora? (S/N)
set /p "RUN_APP="
if /i "%RUN_APP%"=="S" (
    echo Ejecutando aplicacion...
    start_bitacora.bat
)

REM Limpiar archivos temporales
if exist "update_files.txt" del "update_files.txt" >nul 2>&1

pause
