Set WshShell = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")

' Obtener la ruta del directorio actual
currentDir = fso.GetParentFolderName(WScript.ScriptFullName)

' Cambiar al directorio de la aplicación
WshShell.CurrentDirectory = currentDir

' Ejecutar el script de inicio sin mostrar ventana de consola
WshShell.Run "iniciar_servidor_si_no_existe.bat", 0, False

' Esperar un momento para que el servidor inicie
WScript.Sleep 5000

' Abrir navegador automáticamente
WshShell.Run "http://localhost:5000", 1, False
