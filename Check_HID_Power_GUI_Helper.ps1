Write-Host "Scanning for HID mouse and keyboard devices..." -ForegroundColor Cyan

# Riconosci mouse/tastiere anche se non perfettamente nominati
$devices = Get-PnpDevice -PresentOnly | Where-Object {
    $_.Class -eq 'HIDClass' -and (
        $_.FriendlyName -match "mouse" -or
        $_.FriendlyName -match "keyboard" -or
        $_.FriendlyName -match "input" -or
        $_.FriendlyName -match "touch" -or
        $_.FriendlyName -match "pointer"
    )
}

if (-not $devices) {
    Write-Host "No matching HID input devices found." -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit
}

# Mostra i dispositivi trovati
$index = 1
foreach ($device in $devices) {
    Write-Host ""
    Write-Host "[$index] Device: $($device.FriendlyName)" -ForegroundColor Yellow
    Write-Host "    ↳ Instance ID: $($device.InstanceId)"
    $index++
}

Write-Host ""
Write-Host "Select the number of the device you want to inspect in Device Manager."
$selection = Read-Host "Enter number (or press Enter to skip)"

if ($selection -match '^\d+$' -and [int]$selection -ge 1 -and [int]$selection -le $devices.Count) {
    $selectedDevice = $devices[[int]$selection - 1]
    Write-Host "`nOpening Device Manager..." -ForegroundColor Green
    Start-Process "devmgmt.msc"

    Write-Host "`nWhen Device Manager opens, do the following:" -ForegroundColor Cyan
    Write-Host "1. Expand: Human Interface Devices"
    Write-Host "2. Right-click on: $($selectedDevice.FriendlyName)"
    Write-Host "3. Click: Properties"
    Write-Host "4. Go to the tab: Power Management"
    Write-Host "5. Uncheck: 'Allow the computer to turn off this device to save power'" -ForegroundColor Yellow
} else {
    Write-Host "`nNo selection made. Exiting." -ForegroundColor Gray
}

Read-Host "`nPress Enter to exit"
