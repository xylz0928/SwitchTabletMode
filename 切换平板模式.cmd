@echo off
setlocal enabledelayedexpansion
:: ========================================================
:: 平板模式切换脚本
:: 本脚本为支持Windows平板模式的设备优化
:: 请勿在普通PC上运行此脚本
:: 如果你不清楚你的设备是否支持，请关闭本脚本
:: 功能：检测并切换Windows平板/PC模式
:: 需要管理员权限运行
:: ========================================================

:: 管理员权限检测（不自动提权）
:: 使用fltmc命令检测，兼容性更好
fltmc >nul 2>&1 || (
    echo.
    echo [错误] 请右键本脚本选择"以管理员身份运行"
    echo 将在5秒后自动退出...
    timeout /t 5 >nul
    exit /b
)

:check_device
:: 通过PowerShell判断是否为平板设备
for /f "tokens=*" %%i in ('powershell -Command "Add-Type -TypeDefinition 'using System; using System.Runtime.InteropServices; public class TabletCheck { [DllImport(\"user32.dll\")] public static extern int GetSystemMetrics(int nIndex); }'; $result = [TabletCheck]::GetSystemMetrics(86); Write-Host ($result -ne 0)"') do (
    set "result=%%i"
)

:: 判断设备是否为平板设备
if "%result%"=="True" (
    echo 当前设备是平板设备，继续执行脚本...
) else (
    echo 当前设备不是平板设备。
    echo.
    choice /c YN /m "警告: 该设备不是平板设备，继续执行可能导致意外行为。是否仍要继续执行平板模式切换? (Y=继续, N=退出)"
    
    if %errorlevel% neq 1 (
        echo 用户选择继续，脚本继续执行...
    ) else (
        echo 用户取消操作，脚本退出...
        timeout /t 2 >nul
        exit
    )
)

:: 设置注册表路径和键名
set "regPath=HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl"
set "valueName=ConvertibleSlateMode"

:: 检查当前值
reg query "%regPath%" /v "%valueName%" >nul 2>&1
if %errorlevel% equ 0 (
    for /f "tokens=3" %%a in ('reg query "%regPath%" /v "%valueName%" ^| findstr /i "%valueName%"') do (
        set currentValue=%%a
    )
) else (
    :: 如果键值不存在，创建它并设置为平板模式(0)
    reg add "%regPath%" /v "%valueName%" /t REG_DWORD /d 0 /f >nul
    set currentValue=0
    echo 检测到键值不存在，已初始化为平板模式 (ConvertibleSlateMode = 0)
    echo.
)

:: 显示当前模式，确保只输出一次
if "!currentValue!"=="0x1" (
    set "modeMessage=当前模式: PC模式 (ConvertibleSlateMode = 1)"
    set "newValue=0"
    set "newMode=平板模式"
) else (
    set "modeMessage=当前模式: 平板模式 (ConvertibleSlateMode = 0)"
    set "newValue=1"
    set "newMode=PC模式"
)

echo !modeMessage!

:: 询问用户是否切换
echo.
echo 是否要切换到 !newMode!? (Y=切换, N=不切换, C=取消并退出)
choice /c YNC /n /m "请选择"

set "userChoice=%errorlevel%"

if %userChoice% equ 3 (
    echo 操作已取消
    timeout /t 2 >nul
    exit
) else if %userChoice% equ 2 (
    echo 保持当前模式不变
    timeout /t 2 >nul
    exit
)

:: 执行切换
reg add "%regPath%" /v "%valueName%" /t REG_DWORD /d %newValue% /f >nul
echo 已切换到 !newMode! (ConvertibleSlateMode = %newValue%)

:: 询问是否需要重启Explorer
echo.
echo 注意：通常不需要重启Explorer即可生效
choice /c YN /t 3 /d N /m "是否要重启Explorer以确保更改生效? (3秒后默认N) "

if %errorlevel% equ 1 (
    echo 正在重启Windows Explorer...
    taskkill /f /im explorer.exe >nul
    start explorer.exe
    echo Explorer已重启
) else (
    echo 跳过重启Explorer
)

echo 操作完成，程序即将退出...
timeout /t 2 >nul
exit
