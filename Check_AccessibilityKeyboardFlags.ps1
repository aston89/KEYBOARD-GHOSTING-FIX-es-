# AccessibilityFlagsCheck.ps1

$accPath = "HKCU:\Control Panel\Accessibility\Keyboard Response"

Write-Host "Checking Accessibility Keyboard Response settings..." -ForegroundColor Cyan

if (Test-Path $accPath) {
    $props = Get-ItemProperty -Path $accPath
    $keysToCheck = @(
        "AutoRepeatDelay",
        "AutoRepeatRate",
        "BounceTime",
        "DelayBeforeAcceptance",
        "Flags",
        "Last BounceKey Setting",
        "Last Valid Delay",
        "Last Valid Repeat"
    )

    foreach ($key in $keysToCheck) {
        if ($props.PSObject.Properties.Name -contains $key) {
            Write-Host "$key = $($props.$key)"
        } else {
            Write-Host "$key not set."
        }
    }

    $disableAll = Read-Host "`nDo you want to DISABLE (reset to 0) ALL Accessibility Keyboard Response settings? (y/n)"
    if ($disableAll -eq "y") {
        foreach ($key in $keysToCheck) {
            if ($props.PSObject.Properties.Name -contains $key) {
                Set-ItemProperty -Path $accPath -Name $key -Value 0
            }
        }
        Write-Host "All Accessibility Keyboard Response settings have been reset to 0." -ForegroundColor Green
    } else {
        Write-Host "No changes made." -ForegroundColor Yellow
    }
} else {
    Write-Host "Accessibility Keyboard Response registry key NOT found." -ForegroundColor Red
}

Read-Host -Prompt "Press Enter to exit"
