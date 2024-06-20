##REMOVED NETWORK PATH DUE TO SECURIY REASONS
$installerNetworkPath = "XXXXXXXXX\system_update_X.XX.XX.XX.exe"
$installerPath = "C:\temp\systemupdate.exe"

# log file variables
$logFileName = "$env:COMPUTERNAME-$(Get-Date -Format 'yyyy-MM-dd__HH-mm-ss').txt"
$logFilePath = "XXXXXXXXX\system_update_X.XX.XX.XX.exe\$logFileName"

# Path to the most recent log file
$latestLogFile = ""

<#
 .Description
 Write-Log takes a message as an input and contructs a log entry
 by combining the timestamp and the message
#>
function Write-Log {
    param ([string]$message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "$timestamp - $message"
    Add-Content -Path $logFilePath -Value $logMessage
    Write-Output $logMessage
}

# Delete the existing log file if it exists
if (Test-Path $logFilePath) {
    Remove-Item -Path $logFilePath -Force
}

<#
 .Description
 Get-LenovoSystemUpdate checks if Lenovo System Update is already installed
#>
function Check-LenovoSystemUpdate {
    $programName = "Lenovo System Update"
    $key = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*"
    $keyWow64 = "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"

    try {
        $installed = Get-ItemProperty $key, $keyWow64 | Where-Object { $_.DisplayName -like "*$programName*" }
        return $null -ne $installed
    } catch {
        Write-Log "Failed to check if Lenovo System Update is installed: $_"
        return $false
    }
}

<#
 .Description
 Copy-Installer attempts to copy the installer from the networkPath provided
 at the start of the program. It writes whether or not it was successful in 
 the log file
#>
function Copy-Installer {
    Write-Log "Copying Lenovo System Update installer from network share..."
    try {
        Copy-Item -Path $installerNetworkPath -Destination $installerPath -ErrorAction Stop
        Write-Log "Installer copied successfully."
    } catch {
        Write-Log "Failed to copy installer: $_"
        return $false
    }
    return $true
}

# Function to install Lenovo System Update
<#
 .Description
Install-LenovoSystemUpdate attempts to install the Lenovo System Update application.
It writes to the log file whether or not it was successful
#>
function Install-LenovoSystemUpdate {
    Write-Log "Installing Lenovo System Update..."
    try {
        Start-Process -FilePath $installerPath -ArgumentList "/norestart /verysilent" -Wait -ErrorAction Stop
        Write-Log "Lenovo System Update installed successfully."
    } catch {
        Write-Log "Failed to install Lenovo System Update: $_"
        return $false
    }
    return $true
}

# Function to run Lenovo System Update
function Start-LenovoSystemUpdate {
    $systemUpdatePath = "C:\Program Files (x86)\Lenovo\System Update\tvsu.exe"
    
    if (Test-Path $systemUpdatePath) {
        Write-Log "Running Lenovo System Update..."
        try {
            $process = Start-Process -FilePath $systemUpdatePath -ArgumentList "/CM -searchAndDownloadAndInstall" -PassThru -ErrorAction Stop
            Write-Host "Waiting for 50 seconds for Tvsu to launch..."
            Start-Sleep -Seconds 50
            $processRunning = Get-Process -Name Tvsukernel -ErrorAction SilentlyContinue
            if ($processRunning) {
                Write-Log "Required Updates are Available"
                write-host "Required Updates are Available"
            } else {
                Write-Log "Lenovo System Update ran and did not find any required updates."
                write-host "Lenovo System Update ran and did not find any required updates."
            }
            return $process.ExitCode
        } catch {
            Write-Log "Failed to run Lenovo System Update: $_"
            return $null
        }
    } else {
        Write-Log "Lenovo System Update executable not found."
        return $null
    }
}

# Main() script logic
try {
    # Check if Lenovo System Update is installed
    if (-not (Check-LenovoSystemUpdate)) {
        # Copy and install Lenovo System Update
        if (Copy-Installer) {
            if (-not (Install-LenovoSystemUpdate)) {
                Write-Log "Skipping running Lenovo System Update due to installation failure."
                exit 1
            }
        } else {
            Write-Log "Skipping installation due to copy failure."
            exit 1
        }
    }

    # Run Lenovo System Update
    $exitCode = Start-LenovoSystemUpdate
    if ($null -eq $exitCode) {
        Write-Log "Lenovo System Update did not run as expected."
    }
} finally {
    # Clean up the installer file
    if (Test-Path $installerPath) {
        try {
            Remove-Item -Path $installerPath -Force -ErrorAction Stop
            Write-Log "Installer file removed successfully."
        } catch {
            Write-Log "Failed to remove installer file: $_"
        }
    }
}
