@echo off
:: Batch script to run emmcdl commands in a specified order with auto-detected COM port

:: Function to prompt for loader file using PowerShell
:prompt_for_loader
echo.
echo Please select the loader file using the file dialog.
echo.
for /f "usebackq tokens=*" %%i in (`powershell -command "Add-Type -AssemblyName System.Windows.Forms; $FileDialog = New-Object System.Windows.Forms.OpenFileDialog; $FileDialog.Filter = 'Loader Files (*.elf)|*.elf|All Files (*.*)|*.*'; if ($FileDialog.ShowDialog() -eq 'OK') { $FileDialog.FileName }"`) do set "loader_path=%%i"
if "%loader_path%"=="" (
    echo No file selected.
    goto prompt_for_loader
)
if not exist "%loader_path%" (
    echo The file "%loader_path%" does not exist.
    goto prompt_for_loader
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

:: Step 1: List all connected devices
echo Step 1: Listing all connected devices...
emmcdl -l
if %errorlevel% neq 0 (
    echo Failed to list devices with emmcdl.
    exit /b 1
)

:: Step 2: Get device information
echo Step 2: Getting device information...
emmcdl -p %com_port% -info
if %errorlevel% neq 0 (
    echo Failed to get device information from port %com_port%.
    exit /b 1
)

:: Step 3: Prompt for the loader file path
echo Step 3: Prompting for loader file path...
call :prompt_for_loader

:: Step 4: Read Partition
echo Step 4: Reading partition table...
emmcdl -p %com_port% -f "%loader_path%" -gpt
if %errorlevel% neq 0 (
    echo Failed to read partition table with loader file %loader_path%.
    exit /b 1
)

:: Step 5: Erase Userdata partition
echo Step 5: Erasing userdata partition...
emmcdl -p %com_port% -f "%loader_path%" -e userdata
if %errorlevel% neq 0 (
    echo Failed to erase userdata partition with loader file %loader_path%.
    exit /b 1
)

:: Step 6: Erase FRP partition
echo Step 6: Erasing frp partition...
emmcdl -p %com_port% -f "%loader_path%" -e frp
if %errorlevel% neq 0 (
    echo Failed to erase frp partition with loader file %loader_path%.
    exit /b 1
)

:: Step 7: Erase Config partition
echo Step 7: Erasing config partition...
emmcdl -p %com_port% -f "%loader_path%" -e config
if %errorlevel% neq 0 (
    echo Failed to erase config partition with loader file %loader_path%.
    exit /b 1
)

echo All commands executed successfully.
exit /b 0
