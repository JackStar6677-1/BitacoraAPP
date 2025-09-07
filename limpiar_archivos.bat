@echo off
title Limpieza de Archivos Temporales
color 0C

echo.
echo ========================================
echo   LIMPIEZA DE ARCHIVOS TEMPORALES
echo ========================================
echo.

REM Limpiar archivos de Python
echo Limpiando archivos de Python...
if exist "__pycache__" rmdir /s /q "__pycache__" >nul 2>&1
if exist "*.pyc" del /f /q "*.pyc" >nul 2>&1
if exist "*.pyo" del /f /q "*.pyo" >nul 2>&1
echo ✅ Archivos de Python limpiados

REM Limpiar archivos de PyInstaller
echo Limpiando archivos de PyInstaller...
if exist "build" rmdir /s /q "build" >nul 2>&1
if exist "dist" rmdir /s /q "dist" >nul 2>&1
if exist "*.spec" del /f /q "*.spec" >nul 2>&1
echo ✅ Archivos de PyInstaller limpiados

REM Limpiar archivos temporales
echo Limpiando archivos temporales...
if exist "*.tmp" del /f /q "*.tmp" >nul 2>&1
if exist "*.temp" del /f /q "*.temp" >nul 2>&1
if exist "*.log" del /f /q "*.log" >nul 2>&1
echo ✅ Archivos temporales limpiados

REM Limpiar archivos de respaldo
echo Limpiando archivos de respaldo...
if exist "bitacora_backup.csv" del /f /q "bitacora_backup.csv" >nul 2>&1
if exist "bitacora_backup.json" del /f /q "bitacora_backup.json" >nul 2>&1
echo ✅ Archivos de respaldo limpiados

echo.
echo ========================================
echo    LIMPIEZA COMPLETADA
echo ========================================
echo.
echo ✅ Todos los archivos temporales han sido eliminados
echo ✅ El proyecto esta listo para ser subido a Git
echo.

pause
