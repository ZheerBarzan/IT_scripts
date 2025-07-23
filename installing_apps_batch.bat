@echo off
title Software Package Installer
echo ========================================
echo   Installing Software Packages (Offline)
echo ========================================

REM Initialize variables
set "SCRIPT_DIR=%~dp0"
set "SOFTWARE_DIR=%SCRIPT_DIR%Software"
set "LOG_FILE=%SCRIPT_DIR%install_log.txt"

REM Initialize log file
echo Installation Log > "%LOG_FILE%"
echo Started on %DATE% at %TIME% >> "%LOG_FILE%"
echo. >> "%LOG_FILE%"

REM Check if Software folder exists
if not exist "%SOFTWARE_DIR%" (
    echo ERROR: "Software" folder not found in script directory.
    echo ERROR: "Software" folder not found. >> "%LOG_FILE%"
    pause
    exit /b 1
)

echo Starting installations...
echo.

REM Install applications with installation checks
call :CheckAndInstall "LockDown Browser" "LDBL-EXE\LockDownBrowserLabSetup-2-1-2-09.exe" "/quiet /norestart" "LockDown Browser" "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" "Respondus LockDown Browser"
call :CheckAndInstall "Packet Tracer" "packet.exe" "/S" "PacketTracer" "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" "Cisco Packet Tracer"
call :CheckAndInstall "Oracle 11g" "Oracle Database Express Edition 11g\OracleXE112_Win32\DISK1\setup.exe" "/S" "Oracle" "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" "Oracle"
call :CheckAndInstallMSI "Flowgorithm" "flowgorithm.msi" "Flowgorithm" "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" "Flowgorithm"
call :CheckAndInstall "Microsoft office 2016" "MSoffice\setup.exe" "/quiet /norestart" "Microsoft office 2016" "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" "Microsoft office 2016"
echo ✅ All installations completed. Check "%LOG_FILE%" for detailed results.
echo.
pause
exit /b 0

REM Function to check if software is installed and install if not
:CheckAndInstall
set "app_name=%~1"
set "installer_file=%~2"
set "install_args=%~3"
set "check_name=%~4"
set "reg_path=%~5"
set "display_name=%~6"
set "installer_path=%SOFTWARE_DIR%\%installer_file%"

REM Check if already installed
reg query "%reg_path%" /s /f "%display_name%" >nul 2>&1
if %errorlevel%==0 (
    echo   ✓ %app_name% is already installed, skipping...
    echo %app_name% already installed, skipped. >> "%LOG_FILE%"
    goto :eof
)

REM Check if installer exists
if not exist "%installer_path%" (
    echo   - %app_name% installer not found
    echo %app_name% installer not found at "%installer_path%". >> "%LOG_FILE%"
    goto :eof
)

REM Install the software
echo   Installing %app_name%...
echo Installing %app_name%... >> "%LOG_FILE%"
"%installer_path%" %install_args% >nul 2>>"%LOG_FILE%"
if %errorlevel%==0 (
    echo   ✓ %app_name% installed successfully
    echo %app_name% installed successfully. >> "%LOG_FILE%"
) else (
    echo   ✗ %app_name% installation failed (Error: %errorlevel%)
    echo %app_name% installation failed with error %errorlevel%. >> "%LOG_FILE%"
)
goto :eof

REM Function to check and install MSI packages
:CheckAndInstallMSI
set "app_name=%~1"
set "installer_file=%~2"
set "check_name=%~3"
set "reg_path=%~4"
set "display_name=%~5"
set "installer_path=%SOFTWARE_DIR%\%installer_file%"

REM Check if already installed
reg query "%reg_path%" /s /f "%display_name%" >nul 2>&1
if %errorlevel%==0 (
    echo   ✓ %app_name% is already installed, skipping...
    echo %app_name% already installed, skipped. >> "%LOG_FILE%"
    goto :eof
)

REM Check if installer exists
if not exist "%installer_path%" (
    echo   - %app_name% installer not found
    echo %app_name% installer not found at "%installer_path%". >> "%LOG_FILE%"
    goto :eof
)

REM Install the MSI package
echo   Installing %app_name%...
echo Installing %app_name%... >> "%LOG_FILE%"
msiexec /i "%installer_path%" /quiet /norestart ALLUSERS=1 REBOOT=ReallySuppress >nul 2>>"%LOG_FILE%"
if %errorlevel%==0 (
    echo   ✓ %app_name% installed successfully
    echo %app_name% installed successfully. >> "%LOG_FILE%"
) else (
    echo   ✗ %app_name% installation failed (Error: %errorlevel%)
    echo %app_name% installation failed with error %errorlevel%. >> "%LOG_FILE%"
)
goto :eof