@echo off
setlocal enabledelayedexpansion

:: --- VERIFICACIÓN DE ADMINISTRADOR ---
:check_Permissions
echo Verificando privilegios de administrador...
net session >nul 2>&1
if %errorLevel% == 0 (
    echo [OK] Ejecutando con permisos de administrador.
) else (
    echo [ERROR] Este script requiere permisos de administrador.
    echo Intentando elevar privilegios...
    powershell -Command "Start-Process '%~f0' -Verb runAs"
    exit /b
)

:: --- CONFIGURACIÓN DE RUTAS ---
:: %~dp0 es la variable que indica la carpeta donde reside el script
set "DirectorioActual=%~dp0"
cd /d "%DirectorioActual%"

cls
echo ======================================================
echo        RELEVAMIENTO DE AUDITORIA DE SEGURIDAD
echo ======================================================
set /p empresa="Nombre de la Empresa: "

:: Crear carpeta organizada en el mismo directorio del script
set "NombreCarpeta=Auditoria_%empresa%_Resultados"
if not exist "%NombreCarpeta%" mkdir "%NombreCarpeta%"

set "archivo_final=%NombreCarpeta%\Reporte_%empresa%.txt"

:: --- INICIO DE EJECUCIÓN ---
echo Generando reporte... No cierres esta ventana.
echo ====================================================== > "%archivo_final%"
echo REPORTE DE AUDITORIA PARA: %empresa% >> "%archivo_final%"
echo Fecha: %date% | Hora: %time% >> "%archivo_final%"
echo Ejecutado desde: %DirectorioActual% >> "%archivo_final%"
echo ====================================================== >> "%archivo_final%"

echo [+] Recopilando Info del Sistema...
echo [SYSTEMINFO] >> "%archivo_final%"
systeminfo >> "%archivo_final%"

echo [+] Configuración de Red...
echo [IPCONFIG] >> "%archivo_final%"
ipconfig /all >> "%archivo_final%"

echo [+] Conexiones Activas...
echo [NETSTAT] >> "%archivo_final%"
netstat -ano >> "%archivo_final%"

echo [+] Procesos en Ejecución...
echo [TASKLIST] >> "%archivo_final%"
tasklist >> "%archivo_final%"

echo [+] Identidad y Usuarios...
echo [WHOAMI] >> "%archivo_final%"
whoami >> "%archivo_final%"
echo [NET USERS] >> "%archivo_final%"
net user >> "%archivo_final%"
echo [ADMINS LOCALES] >> "%archivo_final%"
net localgroup administrators >> "%archivo_final%"

echo [+] Políticas de Auditoría...
echo [AUDITPOL] >> "%archivo_final%"
auditpol /get /category:* >> "%archivo_final%"

echo [+] Registros de Seguridad (Eventos)...
echo [WEVTUTIL] >> "%archivo_final%"
wevtutil qe Security /c:15 /f:text >> "%archivo_final%"

echo [+] Buscando archivos con posibles claves...
echo [FINDSTR] >> "%archivo_final%"
findstr /si password *.txt >> "%archivo_final%"

echo [+] Tareas Programadas...
echo [SCHTASKS] >> "%archivo_final%"
schtasks /query /fo LIST /v >> "%archivo_final%"

echo [+] Drivers y Actualizaciones...
echo [DRIVERQUERY] >> "%archivo_final%"
driverquery /v >> "%archivo_final%"
echo [HOTFIXES] >> "%archivo_final%"
wmic qfe list >> "%archivo_final%"

echo ====================================================== >> "%archivo_final%"
echo FIN DEL REPORTE >> "%archivo_final%"

echo.
echo Proceso completado con exito.
echo El archivo se encuentra en: %DirectorioActual%%NombreCarpeta%
pause