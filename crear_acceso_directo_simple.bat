@echo off
REM Script alternativo para crear acceso directo sin PowerShell
set "APP_PATH=%~dp0"
set "APP_PATH=%APP_PATH:~0,-1%"
set "DESKTOP_PATH=%USERPROFILE%\Desktop"
set "SHORTCUT_PATH=%DESKTOP_PATH%\Bitacora de Sala de Computacion.lnk"

echo Creando acceso directo en escritorio...

REM Crear archivo VBS temporal para crear el acceso directo
echo Set WshShell = CreateObject("WScript.Shell") > temp_shortcut.vbs
echo Set Shortcut = WshShell.CreateShortcut("%SHORTCUT_PATH%") >> temp_shortcut.vbs
echo Shortcut.TargetPath = "%APP_PATH%\start_bitacora.bat" >> temp_shortcut.vbs
echo Shortcut.WorkingDirectory = "%APP_PATH%" >> temp_shortcut.vbs
echo Shortcut.Description = "Iniciar Bitacora de Sala de Computacion" >> temp_shortcut.vbs
echo if fso.FileExists("%APP_PATH%\static\imagenes\logo2.ico") then >> temp_shortcut.vbs
echo   Shortcut.IconLocation = "%APP_PATH%\static\imagenes\logo2.ico" >> temp_shortcut.vbs
echo end if >> temp_shortcut.vbs
echo Shortcut.Save >> temp_shortcut.vbs

REM Ejecutar el script VBS
cscript //nologo temp_shortcut.vbs

REM Limpiar archivo temporal
del temp_shortcut.vbs

REM Verificar si se creó
if exist "%SHORTCUT_PATH%" (
    echo ✅ Acceso directo creado exitosamente
) else (
    echo ❌ Error creando acceso directo
)
