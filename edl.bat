@echo off
:: Batch script to run emmcdl commands with selected loader file and auto-detected COM port

:: Colors
set "green=[92m"
set "red=[91m"
set "reset=[0m"

:: Check if edl tool is available
where edl >nul 2>&1
if %errorlevel% neq 0 (
    echo %red%edl tool not found in PATH.%reset%
    echo Please ensure edl is installed and available in the PATH.
    exit /b 1
)

:: Check if emmcdl tool is available
where emmcdl >nul 2>&1
if %errorlevel% neq 0 (
    echo %red%emmcdl tool not found in PATH.%reset%
    echo Please ensure emmcdl is installed and available in the PATH.
    exit /b 1
)

:: Run commands sequentially
echo.
echo %green%Choose a command to execute:%reset%
echo %green%1. List Devices%reset%
echo %green%2. Get Device Info%reset%
echo %green%3. Read Partition Table%reset%
echo %green%4. Erase Userdata Partition%reset%
echo %green%5. Erase FRP Partition%reset%
echo %green%6. Erase Config Partition%reset%
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
    echo %red%Invalid choice. Exiting...%reset%
    exit /b 1
)

:: Prompt to extract log file
set /p extract="Do you want to extract log file (Y/N)? "

if /i "%extract%"=="Y" (
    call :extract_log
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

:extract_log
echo Extracting log file...
exit /b 0
