# Script de PowerShell para crear acceso directo
param(
    [string]$AppPath = $PSScriptRoot,
    [string]$DesktopPath = [Environment]::GetFolderPath("Desktop")
)

try {
    $WshShell = New-Object -comObject WScript.Shell
    $ShortcutPath = Join-Path $DesktopPath "Bitacora de Sala de Computacion.lnk"
    
    # Crear el acceso directo
    $Shortcut = $WshShell.CreateShortcut($ShortcutPath)
    $Shortcut.TargetPath = Join-Path $AppPath "start_bitacora.bat"
    $Shortcut.WorkingDirectory = $AppPath
    $Shortcut.Description = "Iniciar Bitacora de Sala de Computacion"
    
    # Verificar si existe el icono
    $IconPath = Join-Path $AppPath "static\imagenes\logo2.ico"
    if (Test-Path $IconPath) {
        $Shortcut.IconLocation = $IconPath
    }
    
    $Shortcut.Save()
    
    if (Test-Path $ShortcutPath) {
        Write-Host "✅ Acceso directo creado exitosamente en: $ShortcutPath" -ForegroundColor Green
        return $true
    } else {
        Write-Host "❌ Error: No se pudo crear el acceso directo" -ForegroundColor Red
        return $false
    }
} catch {
    Write-Host "❌ Error creando acceso directo: $($_.Exception.Message)" -ForegroundColor Red
    return $false
}
