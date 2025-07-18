# Ask OS version
Write-Host "Which OS are you using? Type 10 for Windows 10, 11 for Windows 11:"
$osVersion = Read-Host

switch ($osVersion) {
    "10" { $compat = "Windows10" }
    "11" { $compat = "Windows11" }
    default {
        Write-Host "Invalid input. Assuming Windows 10." -ForegroundColor Yellow
        $compat = "Windows10"
    }
}

# Task name
$taskName = "TextInputHost_HighPriority"

# Check if task already exists
$exists = schtasks /Query /TN $taskName 2>$null

if ($LASTEXITCODE -eq 0) {
    Write-Host "Task '$taskName' already exists." -ForegroundColor Cyan
} else {
    $response = Read-Host "Task '$taskName' does not exist. Do you want to create it? (Y/N)"

    if ($response -match '^[Yy]$') {
        $xml = @"
<?xml version="1.0" encoding="UTF-16"?>
<Task version="1.3" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
  <RegistrationInfo>
    <Date>2025-07-18T18:00:00</Date>
    <Author>Zero</Author>
    <Description>Set TextInputHost.exe process to High priority at logon.</Description>
  </RegistrationInfo>
  <Triggers>
    <LogonTrigger>
      <Enabled>true</Enabled>
    </LogonTrigger>
  </Triggers>
  <Principals>
    <Principal id="Author">
      <RunLevel>HighestAvailable</RunLevel>
      <LogonType>InteractiveToken</LogonType>
    </Principal>
  </Principals>
  <Settings>
    <MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy>
    <DisallowStartIfOnBatteries>false</DisallowStartIfOnBatteries>
    <StopIfGoingOnBatteries>false</StopIfGoingOnBatteries>
    <AllowHardTerminate>true</AllowHardTerminate>
    <StartWhenAvailable>true</StartWhenAvailable>
    <RunOnlyIfNetworkAvailable>false</RunOnlyIfNetworkAvailable>
    <IdleSettings>
      <StopOnIdleEnd>false</StopOnIdleEnd>
      <RestartOnIdle>false</RestartOnIdle>
    </IdleSettings>
    <AllowStartOnDemand>true</AllowStartOnDemand>
    <Enabled>true</Enabled>
    <Hidden>true</Hidden>
    <RunOnlyIfIdle>false</RunOnlyIfIdle>
    <WakeToRun>false</WakeToRun>
    <ExecutionTimeLimit>PT30M</ExecutionTimeLimit>
    <Priority>4</Priority>
  </Settings>
  <Actions Context="Author">
    <Exec>
      <Command>powershell.exe</Command>
      <Arguments>-WindowStyle Hidden -Command "Start-Sleep -s 5; Get-Process TextInputHost -ErrorAction SilentlyContinue | ForEach-Object { \$_.PriorityClass = 'High' }"</Arguments>
    </Exec>
  </Actions>
</Task>
"@

        # Save temporary xml
        $tempXmlPath = "$env:TEMP\TextInputHost_HighPriority.xml"
        $xml | Out-File -FilePath $tempXmlPath -Encoding Unicode

        # Create task
        schtasks /create /tn $taskName /xml "$tempXmlPath" /f

        # Cleanup
        Remove-Item "$tempXmlPath" -Force

        Write-Host "Task '$taskName' successfully created." -ForegroundColor Green
    } else {
        Write-Host "Operation cancelled." -ForegroundColor Yellow
    }
}
