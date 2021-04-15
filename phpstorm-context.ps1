# Get the ID and security principal of the current user account
$myWindowsID=[System.Security.Principal.WindowsIdentity]::GetCurrent()
$myWindowsPrincipal=new-object System.Security.Principal.WindowsPrincipal($myWindowsID)

# Get the security principal for the Administrator role
$adminRole=[System.Security.Principal.WindowsBuiltInRole]::Administrator

# Check to see if we are currently running "as Administrator"
if ($myWindowsPrincipal.IsInRole($adminRole))

{
    # We are running "as Administrator" - so change the title and background color to indicate this
    $Host.UI.RawUI.WindowTitle = $myInvocation.MyCommand.Definition + "(Elevated)"
    $Host.UI.RawUI.BackgroundColor = "DarkBlue"
    clear-host

}
else
{
    # We are not running "as Administrator" - so relaunch as administrator

    # Create a new process object that starts PowerShell
    $newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell";

    # Specify the current script path and name as a parameter
    $newProcess.Arguments = $myInvocation.MyCommand.Definition;

    # Indicate that the process should be elevated
    $newProcess.Verb = "runas";

    # Start the new process
    [System.Diagnostics.Process]::Start($newProcess);

    # Exit from the current, unelevated, process
    exit

}

# HKEY_LOCAL_MACHINE\SOFTWARE\Classes\Directory\background\Open in PhpStorm

$username = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name.Split("\")[1]

$phpStormPath = "C:\Users\$username\AppData\Local\JetBrains\Toolbox\apps\PhpStorm\ch-0"
$phpStormPath = $phpStormPath + "\" + (Get-ChildItem -Directory $phpStormPath | Where-Object Name -NotMatch "plugins" | Select-Object -exp Name)
$phpStormPath = $phpStormPath + "\bin\phpstorm64.exe"
$phpStormIconPath = "$phpStormPath,0"
$a = '"%1"'
$phpStormCommand = "$phpStormPath $a"
$b = '"%V"'
$phpStormBackgroundCommand = "$phpStormPath $b"

Write-Host "PhpStorm path found: " $phpStormPath
Write-Host "Do you want to proceed?"

$confirmation = Read-Host
if ($confirmation -NotMatch '[yY]') {
    Write-Host "Exit"
    exit
}

Write-Host "Continue"

$pathOne = "Registry::HKEY_CLASSES_ROOT\Directory\Background\Open in PhpStorm"
$pathOneExists = Test-Path $pathOne

$pathTwo = "Registry::HKEY_CLASSES_ROOT\Directory\Background\shell\Open in PhpStorm"
$pathTwoExists = Test-Path $pathTwo

$pathThree = "Registry::HKEY_CLASSES_ROOT\*\shell\Open in PhpStorm"
$pathThreeExists = Test-Path -LiteralPath $pathThree

$pathFour = "Registry::HKEY_CLASSES_ROOT\Directory\shell\Open in PhpStorm"
$pathFourExists = Test-Path $pathFour

$allExists = $pathOneExists -and $pathTwoExists -and $pathThreeExists -and $pathFourExists

if ($allExists) {
    Write-Host "Edit"

    Set-ItemProperty -Path $pathOne -Name Icon -Value $phpStormIconPath
    Set-ItemProperty -Path "$pathOne\command" -Name "(Default)" -Value $phpStormBackgroundCommand

    Set-ItemProperty -Path $pathTwo -Name Icon -Value $phpStormIconPath
    Set-ItemProperty -Path "$pathTwo\command" -Name "(Default)" -Value $phpStormBackgroundCommand

    Set-ItemProperty -LiteralPath $pathThree -Name Icon -Value $phpStormIconPath
    Set-ItemProperty -LiteralPath "$pathThree\command" -Name "(Default)" -Value $phpStormCommand

    Set-ItemProperty -Path $pathFour -Name Icon -Value $phpStormIconPath
    Set-ItemProperty -Path "$pathFour\command" -Name "(Default)" -Value $phpStormCommand
} else {
    Write-Host "Create"

    New-Item "$pathOne\command" -Force
    New-Item "$pathTwo\command" -Force
    New-Item "$pathThree\command" -Force
    New-Item "$pathFour\command" -Force

    New-ItemProperty -Path $pathOne -Name Icon -PropertyType String -Value $phpStormIconPath -Force
    New-ItemProperty -Path $pathOne -Name "(Default)" -PropertyType String -Value "Open in PhpStorm" -Force
    New-ItemProperty -Path "$pathOne\command" -Name "(Default)" -PropertyType String -Value $phpStormBackgroundCommand -Force

    New-ItemProperty -Path $pathTwo -Name Icon -PropertyType String -Value $phpStormIconPath -Force
    New-ItemProperty -Path $pathTwo -Name "(Default)" -PropertyType String -Value "Open in PhpStorm" -Force
    New-ItemProperty -Path "$pathTwo\command" -Name "(Default)" -PropertyType String -Value $phpStormBackgroundCommand -Force

    New-ItemProperty -LiteralPath $pathThree -Name Icon -PropertyType String -Value $phpStormIconPath -Force
    New-ItemProperty -LiteralPath $pathThree -Name "(Default)" -PropertyType String -Value "Open in PhpStorm" -Force
    New-ItemProperty -LiteralPath "$pathThree\command" -Name "(Default)" -PropertyType String -Value $phpStormCommand -Force

    New-ItemProperty -Path $pathFour -Name Icon -PropertyType String -Value $phpStormIconPath -Force
    New-ItemProperty -Path $pathFour -Name "(Default)" -PropertyType String -Value "Open in PhpStorm" -Force
    New-ItemProperty -Path "$pathFour\command" -Name "(Default)" -PropertyType String -Value $phpStormCommand -Force
}

Write-Host "Done"
Read-Host -Prompt "Press any key to continue"