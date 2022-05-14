Param([Parameter(Mandatory=$false)] [Switch]$RebootSkip)
$host.ui.RawUI.WindowTitle = "cloudopenstream"
Start-Transcript -Path "$PSScriptRoot\Log.txt"
function Elevated {
    $id = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $p = New-Object System.Security.Principal.WindowsPrincipal($id)
    if ($p.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator))
   { Write-Output $true }      
    else
   { Write-Output $false }   
 }

 if (-not(Elevated))
 { throw "Please run this script as a built-in Administrator" 
   Stop-Transcript
   Pause
}

function Write-HostCenter { param($Message) Write-Host ("{0}{1}" -f (' ' * (([Math]::Max(0, $Host.UI.RawUI.BufferSize.Width / 2) - [Math]::Floor($Message.Length / 2)))), $Message) }

Clear-Host

Write-HostCenter 'Starting up...'
Write-HostCenter 'Hello there, the script is ready!' -ForegroundColor Green
Write-Host ""

if(!$RebootSkip) {
    Write-Host "Your machine will restart at least once during this setup." -ForegroundColor Red
    Write-Host ""
    Write-Host "Step 1 - Installing required software" -ForegroundColor Yellow
    & $PSScriptRoot\Steps\step1.ps1 -Main
} else {
if(Get-ScheduledTask | Where-Object {$_.TaskName -like "Continue" }) {
  Unregister-ScheduledTask -TaskName "Continue" -Confirm:$false
}
Write-Host "Welcome back, let's continue with step two."
}
	
    Write-Host ""
    Write-Host "Step 2 - Applying fixes" -ForegroundColor Yellow
    & $PSScriptRoot\Steps\step2.ps1

    Write-Host ""
    Write-Host "Step 3 - Installing extra applications" -ForegroundColor Yellow
    & $PSScriptRoot\Steps\step3.ps1
    	
	Write-Host ""
	$ip = (Invoke-WebRequest ifconfig.me/ip).Content
	Write-Host "Your IP address is $ip" -ForegroundColor Red
	Write-Host "If you liked the script, please star it on GitHub!" -ForegroundColor Green
	
    $restart = (Read-Host "Depending on the situation, you may see a black screen without a restart. Restart now? (y/n)").ToLower();
    if($restart -eq "y") {
    Restart-Computer -Force 
}
