@echo off

:: BatchGotAdmin
:-------------------------------------
REM  --> Check for permissions
    IF "%PROCESSOR_ARCHITECTURE%" EQU "amd64" (
>nul 2>&1 "%SYSTEMROOT%\SysWOW64\cacls.exe" "%SYSTEMROOT%\SysWOW64\config\system"
) ELSE (
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
)

REM --> If error flag set, we do not have admin.
if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    set params= %*
    echo UAC.ShellExecute "cmd.exe", "/c ""%~s0"" %params:"=""%", "", "runas", 1 >> "%temp%\getadmin.vbs"

    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    pushd "%CD%"
    CD /D "%~dp0"
:--------------------------------------    
     echo Starting WINDOWS DEFENDER DISABLE BY ALI SORATHIYA ...

@echo off

call :main %*
goto :eof

:main
    setlocal EnableDelayedExpansion

    rem Check if Windows Defender is running.
    tasklist /fi "imageName eq "MsMpEng.exe"" | find /i "MsMpEng.exe" > nul 2> nul
    if %errorLevel% equ 0 (
        rem Windows Defender is running.
        echo Windows Defender is running.

        rem Performable operations while Windows Defender is running.
        rem Disable Windows Defender drivers.
        echo Disabling Windows Defender drivers...
        set "drivers="%SystemRoot%\System32\drivers\WdBoot.sys";"%SystemRoot%\System32\drivers\WdFilter.sys";"%SystemRoot%\System32\drivers\WdNisDrv.sys""
        set "drivers=!drivers:""="!"

        set "wasDriverDisabled=false"
        for %%d in (!drivers!) do (
            if exist "%%~d" (
                echo Disabling Windows Defender driver "%%~d"...
                call :disableFile "%%~d"
                set "wasDriverDisabled=true"
            )
        )

        rem Disable Windows Defender objects.
        echo Disabling Windows Defender objects...
        call :importRegistry "Disable Windows Defender objects.reg"

        rem Require restart to unload Windows Defender drivers and objects.
        echo.
        echo Restart required.
    ) else (
        rem Windows Defender is not running.
        echo Windows Defender is not running.

        rem Performable operations while Windows Defender is not running.
        rem Disable Windows Defender features.
        echo Disabling Windows Defender features...
        call :importRegistry "Disable Windows Defender features.reg"
        rem Disable Windows Defender services.
        echo Disabling Windows Defender services...
        call :importRegistry "Disable Windows Defender services.reg"

        rem Disable Windows Defender files.
        echo Disabling Windows Defender files...
        ren "%ProgramFiles%\Windows Defender" "Windows Defender.bak"
        ren "%ProgramFiles(x86)%\Windows Defender" "Windows Defender.bak"
        ren "%ProgramData%\Microsoft\Windows Defender" "Windows Defender.bak"
    )

    endlocal
    goto :eof

:ownFile
    setlocal
    set "filePath=%~1"
    set "user=%~2"
    takeown /f "%filePath%" /a
    icacls "%filePath%" /grant "%user%:F"
    endlocal
    goto :eof

:disableFile
    setlocal
    set "filePath=%~1"
    call :ownFile "%filePath%" "Administrators"
    ren "%filePath%" "%~nx1.bak"
    endlocal
    goto :eof

:importRegistry
    setlocal
    set "filePath=%~1"
    call OwnRegistryKeys.bat "%filePath%"
    @echo off
    regedit /s "%filePath%"
    endlocal
    goto :eof


