<#
.SYNOPSIS
Connects one Android device to adb over Wi-Fi, and pairs it first when necessary.

.DESCRIPTION
Order of work:
  1. Find adb.
  2. Pair, if -PairAddress and -PairCode are given.
  3. Stop here if a wireless device is already connected.
  4. Connect: -ConnectAddress, else mDNS discovery, else ask (terminal only).
  5. Pair and connect again if the connection fails because the PC is not paired (terminal only).
  6. Make sure that exactly one device is connected.
  7. Warn when a Godot editor_settings file points to a different Android SDK.

Exit codes:
  0  One device is connected.
  2  adb was not found.
  3  The connect address is necessary (-ConnectAddress).
  4  Pairing is necessary (-PairAddress and -PairCode).
  5  The connection failed for a different reason.
  6  The pairing failed.
  7  More than one device is connected.

.PARAMETER ConnectAddress
IP address and port from the main Wireless debugging screen, for example 192.168.1.42:41567.

.PARAMETER PairAddress
IP address and port from the "Pair device with pairing code" dialog, for example 192.168.1.42:37123.

.PARAMETER PairCode
The 6-digit Wi-Fi pairing code from the same dialog.

.PARAMETER NoPrompt
Never ask for a value. Stop with exit code 3 or 4 instead. Agents use this switch.

.EXAMPLE
.\connect-android.ps1
.EXAMPLE
.\connect-android.ps1 -NoPrompt -ConnectAddress 192.168.1.42:41567
.EXAMPLE
.\connect-android.ps1 -NoPrompt -PairAddress 192.168.1.42:37123 -PairCode 123456 -ConnectAddress 192.168.1.42:41567
#>
[CmdletBinding()]
param(
    [string]$ConnectAddress = "",
    [string]$PairAddress = "",
    [string]$PairCode = "",
    [switch]$NoPrompt
)

$ErrorActionPreference = "Stop"
$AddressPattern = '^\d{1,3}(\.\d{1,3}){3}:\d{1,5}$'

function Stop-Script([int]$Code, [string]$Message) {
    Write-Output "ERROR ($Code): $Message"
    exit $Code
}

function Find-Adb {
    $onPath = Get-Command adb -ErrorAction SilentlyContinue
    if ($onPath) { return $onPath.Source }
    $roots = @($env:ANDROID_HOME, $env:ANDROID_SDK_ROOT, (Join-Path $env:LOCALAPPDATA "Android\Sdk"))
    foreach ($root in $roots) {
        if (-not $root) { continue }
        $candidate = Join-Path $root "platform-tools\adb.exe"
        if (Test-Path $candidate) { return $candidate }
    }
    return $null
}

function Invoke-Adb {
    # adb writes some results to stderr, so collect both streams as text.
    $previous = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    $out = & $script:Adb @args 2>&1 | ForEach-Object { "$_" }
    $ErrorActionPreference = $previous
    return ($out -join "`n")
}

## Returns one object per device line of "adb devices": Serial, State, Wireless, Line.
function Get-Devices {
    $lines = (Invoke-Adb devices -l) -split "`n" | Select-Object -Skip 1 | Where-Object { $_.Trim() -ne "" -and $_ -notmatch '^\*' }
    foreach ($line in $lines) {
        $parts = $line.Trim() -split '\s+'
        [pscustomobject]@{
            Serial   = $parts[0]
            State    = $parts[1]
            Wireless = ($parts[0] -match ':\d+$' -or $parts[0] -match '_adb-tls-connect')
            Line     = $line.Trim()
        }
    }
}

function Get-WirelessDevice {
    return @(Get-Devices | Where-Object { $_.Wireless -and $_.State -eq "device" })
}

## Returns the connect addresses that mDNS discovery reports.
function Get-MdnsAddresses {
    for ($try = 0; $try -lt 3; $try++) {
        $found = @((Invoke-Adb mdns services) -split "`n" |
            Where-Object { $_ -match '_adb-tls-connect\._tcp' } |
            ForEach-Object { ($_.Trim() -split '\s+')[-1] } |
            Where-Object { $_ -match $AddressPattern })
        if ($found.Count -gt 0) { return $found }
        Start-Sleep -Seconds 1
    }
    return @()
}

## Connects to one address. Returns "ok", "auth" (not paired) or "failed", and prints the adb text.
function Connect-Address([string]$Address) {
    $text = Invoke-Adb connect $Address
    Write-Output "adb connect ${Address}: $text" | Out-Host
    if ($text -match '(?i)authenticat') { return "auth" }
    Start-Sleep -Milliseconds 500
    $state = Get-Devices | Where-Object { $_.Serial -eq $Address } | Select-Object -First 1
    if ($state -and $state.State -eq "device") { return "ok" }
    return "failed"
}

function Invoke-Pair([string]$Address, [string]$Code) {
    if ($Address -notmatch $AddressPattern) { Stop-Script 6 "The pairing address '$Address' is not in the form IP:port." }
    if ($Code -notmatch '^\d{6}$') { Stop-Script 6 "The pairing code must have 6 digits." }
    $text = Invoke-Adb pair $Address $Code
    Write-Output "adb pair ${Address}: $text"
    if ($text -notmatch '(?i)successfully paired') {
        Stop-Script 6 "The pairing failed. Open the pairing dialog again and use the new port and code."
    }
}

function Read-Value([string]$Prompt) {
    if ($NoPrompt) { return "" }
    try { return (Read-Host $Prompt).Trim() } catch { return "" }
}

function Read-Pairing {
    Write-Output "This PC is not paired with the device."
    Write-Output "On the device, open Wireless debugging > Pair device with pairing code."
    $address = Read-Value "Pairing IP address and port"
    $code = Read-Value "Wi-Fi pairing code"
    if (-not $address -or -not $code) {
        Stop-Script 4 "Pairing is necessary. Give -PairAddress and -PairCode from the pairing dialog."
    }
    Invoke-Pair $address $code
}

## Warns when a Godot editor_settings file has an Android SDK path different from the adb SDK.
function Test-GodotSdkPath {
    $sdk = Split-Path (Split-Path $script:Adb -Parent) -Parent
    $folders = @(Join-Path $env:APPDATA "Godot")
    try {
        $steam = (Get-ItemProperty "HKCU:\Software\Valve\Steam" -ErrorAction Stop).SteamPath
        if ($steam) { $folders += (Join-Path $steam "steamapps\common\Godot Engine\editor_data") }
    } catch { }
    $files = @($folders | Where-Object { Test-Path $_ } | ForEach-Object { Get-ChildItem $_ -Filter "editor_settings-*.tres" })
    if ($files.Count -eq 0) { return }
    $normal = { param($p) $p.Replace('\\', '\').Replace('/', '\').TrimEnd('\').ToLowerInvariant() }
    $want = & $normal $sdk
    $bad = 0
    foreach ($file in $files) {
        $match = Select-String -Path $file.FullName -Pattern '^export/android/android_sdk_path = "(.*)"$' | Select-Object -First 1
        $value = if ($match) { $match.Matches[0].Groups[1].Value } else { "" }
        if (-not $value) {
            Write-Output "WARNING: $($file.FullName) has no Android SDK path. Set Editor Settings > Export > Android > Android SDK Path to $sdk."
            $bad++
        } elseif ((& $normal $value) -ne $want) {
            Write-Output "WARNING: $($file.FullName) uses the Android SDK $value, but adb is in $sdk."
            $bad++
        }
    }
    if ($bad -eq 0) { Write-Output "Godot: all $($files.Count) editor_settings files use the Android SDK $sdk." }
}

# 1. Find adb.
$script:Adb = Find-Adb
if (-not $script:Adb) {
    Stop-Script 2 "adb was not found. Install Android SDK Platform-Tools, or put adb on PATH, or set ANDROID_HOME."
}
Write-Output "adb: $script:Adb"
Invoke-Adb start-server | Out-Null

if ($ConnectAddress -and $ConnectAddress -notmatch $AddressPattern) {
    Stop-Script 3 "The connect address '$ConnectAddress' is not in the form IP:port."
}

# 2. Pair first when the pairing values are given.
if ($PairAddress -or $PairCode) {
    if (-not ($PairAddress -and $PairCode)) { Stop-Script 4 "Give both -PairAddress and -PairCode." }
    Invoke-Pair $PairAddress $PairCode
}

# 3 and 4. Use a connected device, or connect one.
$connected = @(Get-WirelessDevice)
if ($connected.Count -eq 0) {
    $result = "failed"
    if ($ConnectAddress) {
        $result = Connect-Address $ConnectAddress
    } else {
        foreach ($address in (Get-MdnsAddresses)) {
            $result = Connect-Address $address
            if ($result -eq "ok") { break }
        }
        if ($result -ne "ok") {
            Write-Output "mDNS discovery did not connect a device."
            $ConnectAddress = Read-Value "Connect IP address and port (main Wireless debugging screen)"
            if (-not $ConnectAddress) {
                Stop-Script 3 "The connect address is necessary. Give -ConnectAddress from the main Wireless debugging screen."
            }
            if ($ConnectAddress -notmatch $AddressPattern) {
                Stop-Script 3 "The connect address '$ConnectAddress' is not in the form IP:port."
            }
            $result = Connect-Address $ConnectAddress
        }
    }

    # 5. Pair and connect again when the PC is not paired.
    if ($result -eq "auth") {
        Read-Pairing
        $result = Connect-Address $ConnectAddress
    }
    if ($result -eq "auth") {
        Stop-Script 4 "Pairing is necessary. Give -PairAddress and -PairCode from the pairing dialog."
    }
    if ($result -ne "ok") {
        Stop-Script 5 "The connection failed. Make sure that Wireless debugging is on, that the device and the PC use the same Wi-Fi network, and that the connect port is current."
    }
}

# 6. Make sure that exactly one device is connected.
$devices = @(Get-Devices | Where-Object { $_.State -eq "device" })
if ($devices.Count -gt 1) {
    $devices | ForEach-Object { Write-Output "  $($_.Line)" }
    Stop-Script 7 "More than one device is connected. Disconnect the devices that you do not use, for example with 'adb disconnect <serial>'."
}

# 7. Check the Godot editor settings.
Test-GodotSdkPath

Write-Output "DEVICE: $($devices[0].Line)"
Write-Output "ANDROID WIRELESS DEBUG OK"
exit 0
