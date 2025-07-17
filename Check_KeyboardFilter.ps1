# Check_KeyboardFilter.ps1

Write-Host "Scanning system for KeyboardFilter components..." -ForegroundColor Cyan

# Flags
$foundRegistry = $false
$foundService = $false
$foundDevice = $false
$deviceDisabled = $false

# Check Registry Key
$regPath = "HKLM:\SYSTEM\CurrentControlSet\Services\KeyboardFilter"
if (Test-Path $regPath) {
    Write-Host " Registry key found: $regPath" -ForegroundColor Green
    $foundRegistry = $true
} else {
    Write-Host " Registry key not found." -ForegroundColor Yellow
}

# Check Windows Services
$service = Get-Service -Name "KeyboardFilter" -ErrorAction SilentlyContinue
if ($service) {
    Write-Host " Service found: KeyboardFilter (Status: $($service.Status))" -ForegroundColor Green
    $foundService = $true
} else {
    Write-Host " Service not found in services list." -ForegroundColor Yellow
}

# Check Device Manager and Registry flag
$deviceList = Get-PnpDevice -FriendlyName "*Keyboard Filter*" -ErrorAction SilentlyContinue
if ($deviceList) {
    foreach ($dev in $deviceList) {
        $foundDevice = $true
        $devId = $dev.InstanceId
        $regPathDev = "HKLM:\SYSTEM\CurrentControlSet\Enum\$devId"
        $configFlags = 0
        if (Test-Path $regPathDev) {
            $configFlags = (Get-ItemProperty -Path $regPathDev -Name "ConfigFlags" -ErrorAction SilentlyContinue).ConfigFlags
        }
        if ($configFlags -band 1) {
            Write-Host " Device '$($dev.FriendlyName)' is DISABLED at registry level (ConfigFlags=1)." -ForegroundColor Yellow
            $deviceDisabled = $true
        } else {
            Write-Host " Device '$($dev.FriendlyName)' is ENABLED." -ForegroundColor Green
        }
    }
} else {
    Write-Host " No Keyboard Filter device found." -ForegroundColor Yellow
}

# Registry Removal Prompt
if ($foundRegistry) {
    $removeReg = Read-Host "Do you want to REMOVE the registry key for KeyboardFilter? (y/n)"
    if ($removeReg -eq "y") {
        Remove-Item -Path $regPath -Recurse -Force
        Write-Host " Registry key removed." -ForegroundColor Green
    }
}

# Service Removal Prompt
if ($foundService) {
    $removeSvc = Read-Host "Do you want to DISABLE the KeyboardFilter service? (y/n)"
    if ($removeSvc -eq "y") {
        Set-ItemProperty -Path $regPath -Name "Start" -Value 4
        Write-Host " Service set to 'disabled' in registry (Start=4)." -ForegroundColor Green
    }
}

# Device Enable/Disable Prompt
if ($foundDevice) {
    if ($deviceDisabled) {
        $enDev = Read-Host "Device is currently DISABLED at registry level. Do you want to ENABLE it? (y/n)"
        if ($enDev -eq "y") {
            foreach ($dev in $deviceList) {
                $devId = $dev.InstanceId
                $regPathDev = "HKLM:\SYSTEM\CurrentControlSet\Enum\$devId"
                $configFlags = (Get-ItemProperty -Path $regPathDev -Name "ConfigFlags" -ErrorAction SilentlyContinue).ConfigFlags
                $newFlags = $configFlags -band (-bnot 1)  # Remove bit 1
                Set-ItemProperty -Path $regPathDev -Name "ConfigFlags" -Value $newFlags
                Write-Host " Device '$($dev.FriendlyName)' ENABLED by clearing ConfigFlags bit." -ForegroundColor Green
            }
        }
    } else {
        $disDev = Read-Host "Device is currently ENABLED. Do you want to DISABLE it at registry level? (y/n)"
        if ($disDev -eq "y") {
            foreach ($dev in $deviceList) {
                $devId = $dev.InstanceId
                $regPathDev = "HKLM:\SYSTEM\CurrentControlSet\Enum\$devId"
                $configFlags = (Get-ItemProperty -Path $regPathDev -Name "ConfigFlags" -ErrorAction SilentlyContinue).ConfigFlags
                $newFlags = $configFlags -bor 1  # Set bit 1
                Set-ItemProperty -Path $regPathDev -Name "ConfigFlags" -Value $newFlags
                Write-Host " Device '$($dev.FriendlyName)' DISABLED by setting ConfigFlags bit." -ForegroundColor Yellow
            }
        }
    }
}

Write-Host "`n Done." -ForegroundColor Cyan

Read-Host -Prompt "Press Enter to exit"
