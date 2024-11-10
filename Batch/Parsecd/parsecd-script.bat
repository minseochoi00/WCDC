@echo off
:: ==============================================================
:: This script is not affiliated with parsec.app.
:: For help and support, visit: https://github.com/chrismin13/parsec-download-script/
:: ==============================================================

:: Setting up secure environment variables
set TEMP_DIR="%temp%\ParsecPortable"
set ZIP_FILE="%TEMP_DIR%\parsec.zip"
set CONFIG_FILE="%TEMP_DIR%\config.txt"
set VBS_SCRIPT="%temp%\_.vbs"
set PARSEC_URL="https://builds.parsecgaming.com/package/parsec-flat-windows.zip"
set CONFIG_URL="https://raw.githubusercontent.com/chrismin13/parsec-download-script/main/config.txt"
set HASH="d41eefca073205c54103a4d432d113ae12dc438ad808c86cc00fee67e8837945"  :: Replace with the actual expected hash value of the downloaded file

:: Step 1: Clean up any previous installations
if exist %TEMP_DIR% (
    echo Removing existing temporary folder...
    rmdir /s /q %TEMP_DIR%
)
mkdir %TEMP_DIR%

:: Step 2: Download the Parsec ZIP file
echo Downloading Parsec package...
curl %PARSEC_URL% -o %ZIP_FILE% --ssl-no-revoke -f

:: Step 3: Verify the integrity of the ZIP file (SHA-256 hash check)
echo Verifying downloaded file integrity...
certutil -hashfile %ZIP_FILE% SHA256 | find /i "%HASH%" >nul
if %errorlevel% neq 0 (
    echo File integrity check failed. The file may be corrupted or tampered with.
    exit /b 1
)

:: Step 4: Extract the downloaded ZIP file
echo Extracting Parsec package...
Call :UnZipFile %TEMP_DIR% %ZIP_FILE%

:: Step 5: Clean up the downloaded ZIP file
echo Removing ZIP file...
del %ZIP_FILE%

:: Step 6: Download the configuration file securely
echo Downloading configuration file...
curl %CONFIG_URL% -o %CONFIG_FILE% --ssl-no-revoke -f

:: Step 7: Start the Parsec application
echo Starting Parsec...
start /d %TEMP_DIR% parsecd.exe

:: End of script
exit /b

:UnZipFile <ExtractTo> <newzipfile>
:: Function to unzip files using VBScript
if exist %VBS_SCRIPT% del /f /q %VBS_SCRIPT%
>%VBS_SCRIPT% echo Set fso = CreateObject("Scripting.FileSystemObject")
>>%VBS_SCRIPT% echo If NOT fso.FolderExists(%1) Then
>>%VBS_SCRIPT% echo fso.CreateFolder(%1)
>>%VBS_SCRIPT% echo End If
>>%VBS_SCRIPT% echo set objShell = CreateObject("Shell.Application")
>>%VBS_SCRIPT% echo set FilesInZip=objShell.NameSpace(%2).items
>>%VBS_SCRIPT% echo objShell.NameSpace(%1).CopyHere(FilesInZip)
>>%VBS_SCRIPT% echo Set fso = Nothing
>>%VBS_SCRIPT% echo Set objShell = Nothing
cscript //nologo %VBS_SCRIPT%
if exist %VBS_SCRIPT% del /f /q %VBS_SCRIPT%
