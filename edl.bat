@echo off
:: Batch script to run emmcdl commands with selected loader file and auto-detected COM port

:: Check if edl tool is available
where edl >nul 2>&1
if %errorlevel% neq 0 (
    echo edl tool not found in PATH.
    echo Please ensure edl is installed and available in the PATH.
    exit /b 1
)

:: Auto-detect COM port using edl --serial
echo Detecting COM port using edl --serial...
for /f "tokens=*" %%i in ('edl --serial 2^>nul') do (
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
call :run_command list_devices
call :run_command get_device_info
call :run_command read_partition_table
call :run_command erase_userdata
call :run_command erase_frp
call :run_command erase_config

echo All commands executed successfully.
exit /b 0

:run_command
:: Check if loader file is not selected or does not exist
if "%loader_path%"=="" (
    call :prompt_for_loader
    if "%loader_path%"=="" (
        echo No loader file selected. Exiting...
        exit /b 1
    )
)

:: Run specified command
echo Executing command: %1
call :%1
if %errorlevel% neq 0 (
    echo Failed to execute command %1.
    exit /b 1
)
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

:prompt_for_loader
echo.
echo Please select the loader file using the file dialog.
echo.
for /f "usebackq tokens=*" %%i in (`powershell -command "Add-Type -AssemblyName System.Windows.Forms; $FileDialog = New-Object System.Windows.Forms.OpenFileDialog; $FileDialog.Filter = 'Loader Files (*.elf)|*.elf|All Files (*.*)|*.*'; if ($FileDialog.ShowDialog() -eq 'OK') { $FileDialog.FileName }"`) do set "loader_path=%%i"
if "%loader_path%"=="" (
    echo No file selected.
    goto :prompt_for_loader
)
if not exist "%loader_path%" (
    echo The file "%loader_path%" does not exist.
    set "loader_path="
    goto :prompt_for_loader
)
exit /b 0
