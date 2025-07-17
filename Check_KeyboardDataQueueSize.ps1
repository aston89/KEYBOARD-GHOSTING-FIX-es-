# PowerShell script to check and configure KeyboardDataQueueSize

$regPath = "HKLM:\SYSTEM\CurrentControlSet\Services\kbdclass\Parameters"
$regName = "KeyboardDataQueueSize"

Write-Host "`n=== KeyboardDataQueueSize Checker ===`n"

# Check if the key exists
if (Get-ItemProperty -Path $regPath -Name $regName -ErrorAction SilentlyContinue) {
    $currentValue = (Get-ItemProperty -Path $regPath -Name $regName).$regName
    Write-Host "Current 'KeyboardDataQueueSize' value: $currentValue"
} else {
    Write-Host "'KeyboardDataQueueSize' does not exist in the registry."
    $addKey = Read-Host "Do you want to add it? (Y/N)"
    if ($addKey -eq "Y" -or $addKey -eq "y") {
        $pollingRate = Read-Host "Enter your keyboard polling rate in Hz (e.g., 125, 500, 1000)"
        switch ($pollingRate) {
            "125" { $suggestedValue = 32 }
            "500" { $suggestedValue = 64 }
            "1000" { $suggestedValue = 128 }
            default { $suggestedValue = 64 }
        }
        Write-Host "Suggested buffer size for $pollingRate Hz is: $suggestedValue"
        $chosenValue = Read-Host "Enter buffer size to set (or press Enter to use suggested: $suggestedValue)"
        if ([string]::IsNullOrWhiteSpace($chosenValue)) {
            $chosenValue = $suggestedValue
        }
        Set-ItemProperty -Path $regPath -Name $regName -Value ([int]$chosenValue) -Type DWord
        Write-Host "Registry key added with value: $chosenValue"
    }
}
