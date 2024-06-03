@echo off
:: Batch script to run emmcdl commands with selected loader file and auto-detected COM port

:: Check if edl tool is available
where edl >nul 2>&1
if %errorlevel% neq 0 (
    echo edl tool not found in PATH.
    echo Please ensure edl is installed and available in the PATH.
    exit /b 1
)

:: Check if emmcdl tool is available
where emmcdl >nul 2>&1
if %errorlevel% neq 0 (
    echo emmcdl tool not found in PATH.
    echo Please ensure emmcdl is installed and available in the PATH.
    exit /b 1
)

:: Run commands sequentially
echo.
echo Choose a command to execute:
echo 1. List Devices
echo 2. Get Device Info
echo 3. Read Partition Table
echo 4. Erase Userdata Partition
echo 5. Erase FRP Partition
echo 6. Erase Config Partition
echo.

set /p choice="Enter your choice: "

if "%choice%"=="1" (
    call :list_devices
) else if "%choice%"=="2" (
    call :get_device_info
) else if "%choice%"=="3" (
    call :read_partition_table
) else if "%choice%"=="4" (
    call :erase_userdata
) else if "%choice%"=="5" (
    call :erase_frp
) else if "%choice%"=="6" (
    call :erase_config
) else (
    echo Invalid choice. Exiting...
    exit /b 1
)

echo All commands executed successfully.
exit /b 0

:list_devices
echo Listing all connected devices...
emmcdl -l
exit /b 0

:get_device_info
echo Getting device information...
emmcdl -p %com_port% -info
exit /b 0

:read_partition_table
echo Reading partition table...
emmcdl -p %com_port% -f "%loader_path%" -gpt
exit /b 0

:erase_userdata
echo Erasing userdata partition...
emmcdl -p %com_port% -f "%loader_path%" -e userdata
exit /b 0

:erase_frp
echo Erasing FRP partition...
emmcdl -p %com_port% -f "%loader_path%" -e frp
exit /b 0

:erase_config
echo Erasing config partition...
emmcdl -p %com_port% -f "%loader_path%" -e config
exit /b 0
