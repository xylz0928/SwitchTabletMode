@echo off
setlocal enabledelayedexpansion
:: ========================================================
:: Tablet Mode Switch Script
:: This script is optimized for devices supporting Windows Tablet Mode
:: Do not run this script on regular PCs
:: If you are unsure if your device supports it, please exit the script
:: Function: Detect and switch between Windows tablet/PC mode
:: Administrator privileges are required to run this script
:: ========================================================

:: Admin privileges check (no auto-elevation)
:: Using fltmc command for better compatibility
fltmc >nul 2>&1 || (
    echo.
    echo [Error] Please right-click this script and select "Run as administrator"
    echo The script will automatically exit in 5 seconds...
    timeout /t 5 >nul
    exit /b
)

:check_device
:: Using PowerShell to check if the device is a tablet
for /f "tokens=*" %%i in ('powershell -Command "Add-Type -TypeDefinition 'using System; using System.Runtime.InteropServices; public class TabletCheck { [DllImport(\"user32.dll\")] public static extern int GetSystemMetrics(int nIndex); }'; $result = [TabletCheck]::GetSystemMetrics(86); Write-Host ($result -ne 0)"') do (
    set "result=%%i"
)

:: Check if the device is a tablet
if "%result%"=="True" (
    echo This device is a tablet. Continuing the script...
) else (
    echo This device is not a tablet.
    echo.
    choice /c YN /m "Warning: This device is not a tablet. Continuing may cause unexpected behavior. Do you still want to proceed with the tablet mode switch? (Y=Yes, N=Exit)"
    
    if %errorlevel% neq 1 (
        echo User chose to continue, the script will proceed...
    ) else (
        echo User cancelled the operation, the script will exit...
        timeout /t 2 >nul
        exit
    )
)

:: Set registry path and value name
set "regPath=HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl"
set "valueName=ConvertibleSlateMode"

:: Check the current value
reg query "%regPath%" /v "%valueName%" >nul 2>&1
if %errorlevel% equ 0 (
    for /f "tokens=3" %%a in ('reg query "%regPath%" /v "%valueName%" ^| findstr /i "%valueName%"') do (
        set currentValue=%%a
    )
) else (
    :: If the key does not exist, create it and set it to tablet mode (0)
    reg add "%regPath%" /v "%valueName%" /t REG_DWORD /d 0 /f >nul
    set currentValue=0
    echo Key does not exist, initialized to tablet mode (ConvertibleSlateMode = 0)
    echo.
)

:: Display the current mode, ensure it only shows once
if "!currentValue!"=="0x1" (
    set "modeMessage=Current mode: PC Mode (ConvertibleSlateMode = 1)"
    set "newValue=0"
    set "newMode=Tablet Mode"
) else (
    set "modeMessage=Current mode: Tablet Mode (ConvertibleSlateMode = 0)"
    set "newValue=1"
    set "newMode=PC Mode"
)

echo !modeMessage!

:: Ask the user if they want to switch
echo.
echo Do you want to switch to !newMode!? (Y=Yes, N=No, C=Cancel and Exit)
choice /c YNC /n /m "Please select"

set "userChoice=%errorlevel%"

if %userChoice% equ 3 (
    echo Operation cancelled
    timeout /t 2 >nul
    exit
) else if %userChoice% equ 2 (
    echo Keeping current mode
    timeout /t 2 >nul
    exit
)

:: Perform the mode switch
reg add "%regPath%" /v "%valueName%" /t REG_DWORD /d %newValue% /f >nul
echo Switched to !newMode! (ConvertibleSlateMode = %newValue%)

:: Ask if Explorer should be restarted
echo.
echo Note: Usually, restarting Explorer is not required for the changes to take effect
choice /c YN /t 3 /d N /m "Do you want to restart Explorer to ensure the changes take effect? (3 seconds default to N)"

if %errorlevel% equ 1 (
    echo Restarting Windows Explorer...
    taskkill /f /im explorer.exe >nul
    start explorer.exe
    echo Explorer restarted
) else (
    echo Skipping Explorer restart
)

echo Operation complete, the script will exit shortly...
timeout /t 2 >nul
exit
