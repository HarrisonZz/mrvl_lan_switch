@echo off
setlocal enabledelayedexpansion

set LOCAL_PATH=%CD%
set PATCH_TOOL_PATH=%LOCAL_PATH%/flash_patch_tool
set JTAG_TOOL_PATH=%LOCAL_PATH%/spi_flash_v3.05.0003_ENGINEERING_VERSION
echo ------------------------------------------
set /p MAC_ADDRESS=Please scan MAC Address : 
echo MAC Address is %MAC_ADDRESS%
echo ==========================================
set FW_FILENAME=88Q6113_flash_%MAC_ADDRESS%.bin
set RESULT=
set FORMATED_MAC_ADDRESS=

:: Define the ESC variable as the ASCII escape character
for /f %%a in ('echo prompt $E ^| cmd') do set "ESC=%%a"
:: Define color codes
set "RED=%ESC%[91m"
set "GREEN=%ESC%[92m"
set "RESET=%ESC%[0m"

:: Main Process
cd "%PATCH_TOOL_PATH%"

::cd "%JTAG_TOOL_PATH%"
::call :update_MAC_Addr %MAC_ADDRESS%
::call :check_MAC_Addr "mac_address.bin"
::EXIT /B 0
::set FW_FILENAME=88Q6113_flash_003064000075.bin
::fwupdate.bat !FW_FILENAME! > fwupdate.log
::EXIT /B 0

:: Call the macro with a parameter
call :update_MAC_Addr %MAC_ADDRESS%
call :check_FW
echo Upload FW to SPI Flash
call fwupdate.bat %FW_FILENAME% > fwupdate.log
call :find_String "fwupdate.log > nul" "update Firmware"
if !RESULT! equ 0 (
    goto :EOF
)
spi_flash.exe -address=0x1000c -size=6 -read -out=.\mac_address.bin
if %errorlevel% equ 0 (
   call :check_MAC_Addr "mac_address.bin"
)
endlocal
pause
goto :EOF


:: Function for check the specify content exist in XXX.log or not
:find_String
findstr /C:"Marvell JTAG SPI Flash Programmer finished successfully." %~1
if %errorlevel% equ 0 (
    echo %GREEN%Successed in %~2.%RESET%
    set RESULT=1
) else (
    echo %RED%Failed to %~2.%RESET%
    set RESULT=0
)
goto :EOF

:: Function for update the firmware in SPI Flash via JTAG interface
set /A count=0

:check_FW
cd "%JTAG_TOOL_PATH%"
spi_flash.exe -showSPI > showSPI.log
call :find_String "showSPI.log > nul" "detect JTAG Tool"
if !RESULT! equ 0 (
    if !count! lss 2 (
        set /A count+=1
        goto :check_FW
    ) else (
        EXIT /B 1
    )
)
spi_flash.exe -erase -address=0x0000 -size=0x20ffff > erase.log
call :find_String "erase.log > nul" "erase SPI Flash"
if !RESULT! equ 0 (
    EXIT /B 0
)
goto :EOF

:: Function for check the MAC address which was programmed in firmware
:check_MAC_Addr
:: Generate certutil dump and store in a temporary file
certutil -f -encodeHex %~1 out.hex

set FORMATED_MAC_ADDRESS=!FORMATED_MAC_ADDRESS::= !


echo !FORMATED_MAC_ADDRESS!
:: Remove spaces and convert to uppercase

:: Compare extracted MAC address with the defined MAC address
findstr /I /R /C:"!FORMATED_MAC_ADDRESS!" out.hex > nul
if %ERRORLEVEL% EQU 0 (
    echo %GREEN%MAC Address matches: !FORMATED_MAC_ADDRESS! %RESET%
) else (
    echo %RED%MAC Address does not match: !FORMATED_MAC_ADDRESS! %RESET%
)
goto :EOF

:: Function for update the MAC address in firmware 
:update_MAC_Addr
set hexstr=" "
if "%~1" == "" goto :NO_FILE
for /L %%i in (0,2,11) do (
    set PART=!MAC_ADDRESS:~%%i,2!
    if defined FORMATED_MAC_ADDRESS (
        if %%i==10 (
            if !PART!==00 (
                set PART=ff
            ) else (
                set /a PART=0x!PART!
                set /a PART-=1
                call :dec2hex !PART!
                set PART=!return!
            )
        )
        set FORMATED_MAC_ADDRESS=!FORMATED_MAC_ADDRESS!:!PART!
    ) else (
        set FORMATED_MAC_ADDRESS=!PART!
    )
)
echo Update MAC Address to !FORMATED_MAC_ADDRESS!
patch_image.exe -fwimage=88Q6113_flash_adlink.bin -aesgen=2 -devicenum=0xf -macaddress=!FORMATED_MAC_ADDRESS! -show
copy /b "%PATCH_TOOL_PATH%\88Q6113_flash_adlink.bin" "%JTAG_TOOL_PATH%\%FW_FILENAME%"
goto :EOF

:NO_FILE
echo "ERROR:No firmware filename given!"
set ERRLEV=9
pause


:dec2hex
set code=0123456789abcdef
set /a num=%1
set var=%num%
set str=
:again
set /a tra=%var%%%16
call,set tra=%%code:~%tra%,1%%
::echo tra=%tra%
set /a var/=16
::echo var=%var%
set str=%tra%%str%
if %var% geq 10 goto again
::echo %var%%str%
if %var% neq 0 (set hexstr=%var%%str%) else (set hexstr=%str%)
::echo hexstr=%hexstr%
if 0x!hexstr! lss 0x10 (
    set hexstr=0!hexstr!
)
set return=!hexstr!
::echo return=%return%
goto:eof