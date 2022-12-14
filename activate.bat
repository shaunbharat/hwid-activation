@echo off

goto :CheckActivationStatus

:PrintMenuText
    cls
    title HWID Activation Script
    mode 150, 30
    echo:
    echo:
    echo:                                                   HWID Activation Script
    echo:                                                   **********************
    echo:              
    echo:    Credits
    echo:    -----------------
    echo:       The source behind the activation script can be found at: https://github.com/massgravel/Microsoft-Activation-Scripts
    echo:
    echo:       This script makes the process of HWID activation easier, and uses that activation script behind the scenes.
    echo:       This script can be found at: https://github.com/shaunbharat/HWID-activation
    echo:
    echo:    Brief Description
    echo:    -----------------
    echo:       This script will activate your copy of Windows using a HWID activation method, and upgrade it to Windows 10 Pro.
    echo:       This method is permanent and you will running a legitimate copy of Windows, granted by Microsoft itself.
    echo:
    echo:    Instructions
    echo:    -----------------
exit /b 0

:ConfirmActivationStatus
    cscript C:\Windows\System32\slmgr.vbs /dlv | findstr "Professional" && cscript C:\Windows\System32\slmgr.vbs /dlv | findstr "Licensed"
exit /b %errorlevel%

:CheckActivationStatus
    call :ConfirmActivationStatus
    if %errorlevel% equ 0 (
        call :PrintMenuText
        echo:       Your copy of Windows is already activated to Windows 10 Pro! You can now close this window and safely delete this script.
        echo:
        echo:
        pause
        exit
    )
    if %errorlevel% equ 1 (
        goto :CheckForAdmin
    )
exit /b 0

:CheckForAdmin
    net session >nul 2>&1
    if %errorlevel% equ 0 goto :StartScript
    if %errorlevel% neq 0 goto :AskForAdmin
exit /b 0

:AskForAdmin
    powershell Start-Process %0 -Verb runAs && exit
    call :PrintMenuText
    echo:       This script requires administrator privileges to run. Please run it again as an administrator.
    echo:
    echo:
    pause
    exit
exit /b 0

:ConfirmGenericKeyInstalled
    reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SoftwareProtectionPlatform" /v BackupProductKeyDefault | findstr "VK7JG-NPHTM-C97JM-9MPGT-3V66T"
exit /b %errorlevel%

:StartScript
    :: Check if task exists in task scheduler (old method)
    ::schtasks /query /tn "hwid_activation"
    :: set errlevel=%errorlevel%
    :: if errlevel equ "0" goto :ActivateWindows
    :: if errlevel equ "1" goto :InstallGenericKey

    :: Check if the generic Windows 10 Pro product key has already been installed
    call :ConfirmGenericKeyInstalled
    if %errorlevel% equ 0 goto :ActivateWindows
    if %errorlevel% equ 1 goto :InstallGenericKey
exit /b 0

:InstallGenericKey
    :: The task doesn't exist, so the script is being run for the first time.

    call :PrintMenuText
    echo:       A generic Windows 10 Pro will now be installed, and your computer will need to be restarted.
    echo:       Your internet will cut off briefly, then your computer will restart. After the restart, login and await further instructions.
    echo:
    echo:       If you are okay with this process taking place now, press enter to continue.
    echo:       Otherwise, close the command prompt window now, and run the script when you are ready.
    echo:
    echo:
    pause

    :: Disable all network adapters, install the generic Windows 10 Pro product key, then reconnect to the internet.
    powershell -command "Disable-NetAdapter * -Confirm:$false"
    ::slmgr.vbs /ipk VK7JG-NPHTM-C97JM-9MPGT-3V66T
    cscript C:\Windows\System32\slmgr.vbs /ipk VK7JG-NPHTM-C97JM-9MPGT-3V66T | findstr "VK7JG-NPHTM-C97JM-9MPGT-3V66T successfully"
    if %errorlevel% equ 0 (
        call :PrintMenuText
        echo:       The generic Windows 10 Pro product key has been successfully installed! Your computer will now restart.
        echo:
        echo:
    )
    if %errorlevel% equ 1 (
        call :PrintMenuText
        echo:       Could not install the generic Windows 10 Pro product key. Please manually install it by going to the settings.
        echo "       On Windows 10: Settings > Update & Security > Activation > Change product key"
        echo "       On Windows 11: Settings > System > Activation > Change product key"
        echo:
        echo:
        pause
        exit
    )
    powershell -command "Enable-NetAdapter * -Confirm:$false"
    
    call :ConfirmGenericKeyInstalled
    if %errorlevel% equ 0 (
        schtasks /create /tn hwid_activation /tr %0 /sc onlogon /rl highest /f && shutdown /r /t 0
        call :PrintMenuText
        echo:       Could not restart the computer. Please restart it manually.
        echo:
        echo:
        pause
    )
    if %errorlevel% equ 1 (
        call :PrintMenuText
        echo:       Could not install the generic Windows 10 Pro product key. Please manually install it by going to the settings.
        echo "       On Windows 10: Settings > Update & Security > Activation > Change product key"
        echo "       On Windows 11: Settings > System > Activation > Change product key"
        echo:
        echo:
        pause
        exit
exit /b 0

:ActivateWindows
    :: The task exists, so the script is being run after restart, which means the activation script has already been run
    :: and the generic Windows 10 Pro product key has already been installed.
    :: The next step is to run the script from https://github.com/massgravel/Microsoft-Activation-Scripts

    schtasks /delete /tn hwid_activation /f

    call :PrintMenuText
    echo:       Please wait while your copy of Windows is activated to the Windows 10 Pro.
    echo:
    echo:
    
    :: Run activation script (old method)
    :: powershell -Command "irm https://massgrave.dev/get | iex"
    :: powershell -command "$activationScript = New-TemporaryFile; Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/massgravel/Microsoft-Activation-Scripts/master/MAS/Separate-Files-Version/HWID-KMS38_Activation/HWID_Activation.cmd' -OutFile $activationScript; Start-Process -FilePath $activationScript -ArgumentList /HWID -Wait; Remove-Item -LiteralPath $activationScript"
    
    powershell -command "& ([ScriptBlock]::Create((irm https://massgrave.dev/get))) /HWID"

    :: Check if the activation was successful
    call :ConfirmActivationStatus
    if %errorlevel% equ 0 (
        call :PrintMenuText
        echo:       Congratulations, your copy of Windows has been activated to Windows 10 Pro! You can now close this window and safely delete this script.
        echo:
        echo:
        pause
        exit
    )
    if %errorlevel% equ 1 (
        call :PrintMenuText
        echo:       Could not activate your copy of Windows. Please try restarting your computer and running this script again.
        echo:
        echo:       If you are still having issues, please refer to the instructions for the activation script at:
        echo:       https://github.com/massgravel/Microsoft-Activation-Scripts or https://massgrave.dev/
        echo:
        echo:
        pause
        exit
    )
exit /b 0

:: todo: add "/z" to schtasks create command and remove line 142 that explicitly deletes the task
