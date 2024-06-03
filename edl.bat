@echo off
:: Batch script to run emmcdl commands with selected loader file and auto-detected COM port

:: Initialize loader file path variable
set "loader_path="

:run_command
:: Check if loader file is not selected or does not exist
if "%loader_path%"=="" (
    call :prompt_for_loader
    if "%loader_path%"=="" goto :run_command
)

:: Check if edl tool is available
where edl >nul 2>&1
if %errorlevel% neq 0 (
    echo edl tool not found in PATH.
    echo Please ensure edl is installed and available in the PATH.
    exit /b 1
)

:: Auto-detect COM port using edl --serial
echo Detecting COM port using edl --serial...
edl --serial > detect_com_port.txt
if %errorlevel% neq 0 (
    echo Failed to auto-detect COM port with edl.
    exit /b 1
)

:: Extract COM port from the output
for /f "tokens=*" %%i in (detect_com_port.txt) do (
    set "com_port=%%i"
    goto found_com_port
)

:found_com_port
if "%com_port%"=="" (
    echo No COM port detected.
    exit /b 1
)

echo Detected COM port: %com_port%

:: Check if emmcdl tool is available
where emmcdl >nul 2>&1
if %errorlevel% neq 0 (
    echo emmcdl tool not found in PATH.
    echo Please ensure emmcdl is installed and available in the PATH.
    exit /b 1
)

:: Run commands sequentially
call :list_devices
call :get_device_info
call :read_partition_table
call :erase_userdata
call :erase_frp
call :erase_config

echo All commands executed successfully.
exit /b 0

:list_devices
echo Listing all connected devices...
emmcdl -l
if %errorlevel% neq 0 (
    echo Failed to list devices with emmcdl.
    exit /b 1
)
exit /b 0

:get_device_info
echo Getting device information...
emmcdl -p %com_port% -info
if %errorlevel% neq 0 (
    echo Failed to get device information from port %com_port%.
    exit /b 1
)
exit /b 0

:read_partition_table
echo Reading partition table...
emmcdl -p %com_port% -f "%loader_path%" -gpt
if %errorlevel% neq 0 (
    echo Failed to read partition table with loader file %loader_path%.
    exit /b 1
)
exit /b 0

:erase_userdata
echo Erasing userdata partition...
emmcdl -p %com_port% -f "%loader_path%" -e userdata
if %errorlevel% neq 0 (
    echo Failed to erase userdata partition with loader file %loader_path%.
    exit /b 1
)
exit /b 0

:erase_frp
echo Erasing FRP partition...
emmcdl -p %com_port% -f "%loader_path%" -e frp
if %errorlevel% neq 0 (
    echo Failed to erase FRP partition with loader file %loader_path%.
    exit /b 1
)
exit /b 0

:erase_config
echo Erasing config partition...
emmcdl -p %com_port% -f "%loader_path%" -e config
if %errorlevel% neq 0 (
    echo Failed to erase config partition with loader file %loader_path%.
    exit /b 1
)
exit /b 0
