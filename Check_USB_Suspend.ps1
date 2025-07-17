# Check_USB_Suspend_GUI_Helper.ps1

function Get-ActivePowerPlan {
    $output = powercfg /getactivescheme
    if ($output -match 'GUID:\s*([a-fA-F0-9-]+)') {
        return $matches[1]
    }
    return $null
}

function Show-USBSettingStatus {
    param([string]$guid)

    Write-Host "`n🔍 Checking registry status for USB suspend setting..."
    $regPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Power\User\PowerSchemes\$guid\7516b95f-f776-4464-8c53-06167f40cc99\2a737441-1930-4402-8d77-b2bebba308a3"

    $acVal = (Get-ItemProperty -Path $regPath -Name "ACSettingIndex" -ErrorAction SilentlyContinue).ACSettingIndex
    $dcVal = (Get-ItemProperty -Path $regPath -Name "DCSettingIndex" -ErrorAction SilentlyContinue).DCSettingIndex

    if ($acVal -eq $null -and $dcVal -eq $null) {
        Write-Host "⚠ USB suspend setting not explicitly configured in registry (might be hidden or untouched)."
    } else {
        Write-Host " USB suspend AC: $acVal / DC: $dcVal"
        if ($acVal -eq 0 -and $dcVal -eq 0) {
            Write-Host " Suspend is DISABLED for both AC and DC power."
        } else {
            Write-Host " Suspend is ENABLED or partially active."
        }
    }
}

function Ask-ToRevealSetting {
    param([string]$guid)

    Write-Host "`n Do you want to make USB Suspend setting visible?"
    Write-Host "1. Yes, for current power plan only"
    Write-Host "2. Yes, for all power plans"
    Write-Host "3. No"
    $choice = Read-Host "Select option (1/2/3)"
    switch ($choice) {
        "1" {
            powercfg -attributes SUB_USB USBSELECTIVESETTING -ATTRIB_HIDE 0 -scheme $guid
            Write-Host " USB suspend setting revealed for current plan."
        }
        "2" {
            powercfg /list | ForEach-Object {
                if ($_ -match 'GUID:\s*([a-fA-F0-9-]+)') {
                    powercfg -attributes SUB_USB USBSELECTIVESETTING -ATTRIB_HIDE 0 -scheme $matches[1]
                }
            }
            Write-Host " USB suspend setting revealed for all plans."
        }
        default {
            Write-Host " No changes made to visibility."
        }
    }
}

# Main
Write-Host "🔍 Checking active power plan..."
$guid = Get-ActivePowerPlan
if (!$guid) {
    Write-Host "❌ Failed to retrieve active power plan."
    Read-Host "Press Enter to exit"
    exit
}
Write-Host " Active power plan GUID: $guid"

Ask-ToRevealSetting -guid $guid
Show-USBSettingStatus -guid $guid

Write-Host "`n Opening Power Options GUI for manual review..."
Start-Process "control.exe" "powercfg.cpl,,1"


Read-Host "`nPress Enter to exit"
