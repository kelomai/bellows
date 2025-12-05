#Requires -RunAsAdministrator

<#
.SYNOPSIS
    Windows 11 Debloat Script for Clean Dev/Corporate Templates
.DESCRIPTION
    Removes bloatware, OneDrive, telemetry, and consumer features.
    Prepares Windows 11 for development use or sysprep templates.

    What it removes:
    - Bloatware apps (Bing, Xbox, Solitaire, Teams, Clipchamp, etc.)
    - OneDrive (complete removal including Explorer integration)
    - Telemetry and data collection
    - Consumer features (auto app installs, suggestions, tips)
    - Cortana and web search in Start Menu
    - Unnecessary services (Xbox, retail demo, telemetry)

    Settings applied to default user profile for sysprep compatibility.
.EXAMPLE
    .\Debloat-Windows.ps1
.NOTES
    Author: 🧙‍♂️ Kelomai (https://kelomai.io)
    License: MIT

    Run as Administrator
    Reboot after running, then run Windows Update

    Remote execution:
    irm https://raw.githubusercontent.com/kelomai/bellows/main/win11-setup/Debloat-Windows.ps1 | iex
#>

# Suppress all non-critical errors from displaying
$ErrorActionPreference = 'SilentlyContinue'
$Error.Clear()

Write-Host "╔═════════════════════════════════════════════╗" -ForegroundColor DarkGray
Write-Host "║        Welcome 👋 to 🧙‍♂️ Kelomai 🚀          ║" -ForegroundColor DarkGray
Write-Host "║           https://kelomai.io                ║" -ForegroundColor DarkGray
Write-Host "╠═════════════════════════════════════════════╣" -ForegroundColor DarkGray
Write-Host "║       Windows 11 Debloat Script 🧹          ║" -ForegroundColor DarkGray
Write-Host "╚═════════════════════════════════════════════╝" -ForegroundColor DarkGray
Write-Host ""

# ============================================================================
# SECTION 1: Remove Bloatware Apps
# ============================================================================
Write-Host "🗑️  [1/10] Removing bloatware apps..." -ForegroundColor Yellow

$bloatware = @(
	"Microsoft.BingNews"
	"Microsoft.BingWeather"
	"Microsoft.BingFinance"
	"Microsoft.BingSports"
	"Microsoft.GetHelp"
	"Microsoft.Getstarted"
	"Microsoft.Messaging"
	"Microsoft.Microsoft3DViewer"
	"Microsoft.MicrosoftOfficeHub"
	"Microsoft.MicrosoftSolitaireCollection"
	"Microsoft.MicrosoftStickyNotes"
	"Microsoft.MixedReality.Portal"
	"Microsoft.Office.OneNote"
	"Microsoft.Office.Sway"
	"Microsoft.OneConnect"
	"Microsoft.People"
	"Microsoft.Print3D"
	"Microsoft.SkypeApp"
	"Microsoft.StorePurchaseApp"
	"Microsoft.Todos"
	"Microsoft.Wallet"
	"Microsoft.Whiteboard"
	"Microsoft.WindowsAlarms"
	"Microsoft.WindowsCamera"
	"microsoft.windowscommunicationsapps"
	"Microsoft.WindowsFeedbackHub"
	"Microsoft.WindowsMaps"
	"Microsoft.WindowsSoundRecorder"
	"Microsoft.GamingApp"
	"Microsoft.GamingServices"
	"Microsoft.Xbox.TCUI"
	"Microsoft.XboxApp"
	"Microsoft.XboxGameOverlay"
	"Microsoft.XboxGamingOverlay"
	"Microsoft.XboxIdentityProvider"
	"Microsoft.XboxSpeechToTextOverlay"
	"Microsoft.YourPhone"
	"Microsoft.ZuneMusic"
	"Microsoft.ZuneVideo"
	"MicrosoftTeams"
	"Microsoft.Teams"
	"Microsoft.OutlookForWindows"
	"Clipchamp.Clipchamp"
	"*ActiproSoftwareLLC*"
	"*AdobeSystemsIncorporated.AdobePhotoshopExpress*"
	"*Duolingo-LearnLanguagesforFree*"
	"*EclipseManager*"
	"*Facebook*"
	"*Instagram*"
	"*king.com.CandyCrushSaga*"
	"*king.com.CandyCrushSodaSaga*"
	"*PandoraMediaInc*"
	"*SpotifyAB.SpotifyMusic*"
	"*TikTok*"
	"*Twitter*"
	"*LinkedIn*"
	"7EE7776C.LinkedInforWindows"
	"*LinkedInforWindows*"
	"LinkedIn.LinkedIn"
	"*Wunderlist*"
	"*Flipboard*"
	"*Disney*"
	"*Netflix*"
	"*MinecraftUWP*"
	"*CyberLink*"
	"*Dolby*"
	"*DrawboardPDF*"
	"*March-of-Empires*"
	"*Plex*"
	"*Solitaire*"
	"*BubbleWitch*"
	"*Phototastic*"
	"*Shazam*"
)

foreach ($app in $bloatware) {
	Write-Host "  Removing: $app" -ForegroundColor Gray
	Get-AppxPackage -Name $app -AllUsers -ErrorAction SilentlyContinue | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
	Get-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue | Where-Object DisplayName -like $app | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
}

Write-Host "  ✓ Bloatware removed" -ForegroundColor Green
Write-Host ""

# ============================================================================
# SECTION 2: Remove OneDrive Completely
# ============================================================================
Write-Host "☁️  [2/10] Removing OneDrive..." -ForegroundColor Yellow

# Kill OneDrive process
Write-Host "  Stopping OneDrive process..." -ForegroundColor Gray
$null = taskkill.exe /F /IM "OneDrive.exe" 2>&1
Start-Sleep -Seconds 2

# Uninstall OneDrive
Write-Host "  Uninstalling OneDrive..." -ForegroundColor Gray
if (Test-Path "$env:SystemRoot\System32\OneDriveSetup.exe") {
	Start-Process "$env:SystemRoot\System32\OneDriveSetup.exe" -ArgumentList "/uninstall" -Wait -NoNewWindow
}
if (Test-Path "$env:SystemRoot\SysWOW64\OneDriveSetup.exe") {
	Start-Process "$env:SystemRoot\SysWOW64\OneDriveSetup.exe" -ArgumentList "/uninstall" -Wait -NoNewWindow
}
Start-Sleep -Seconds 2

# Remove OneDrive leftovers (some files may be locked, ignore errors)
Write-Host "  Removing OneDrive leftovers..." -ForegroundColor Gray
try { if (Test-Path "$env:LOCALAPPDATA\Microsoft\OneDrive") { Remove-Item -Recurse -Force "$env:LOCALAPPDATA\Microsoft\OneDrive" -ErrorAction Stop } } catch {}
try { if (Test-Path "$env:PROGRAMDATA\Microsoft OneDrive") { Remove-Item -Recurse -Force "$env:PROGRAMDATA\Microsoft OneDrive" -ErrorAction Stop } } catch {}
try { if (Test-Path "$env:USERPROFILE\OneDrive") { Remove-Item -Recurse -Force "$env:USERPROFILE\OneDrive" -ErrorAction Stop } } catch {}
try { if (Test-Path "C:\OneDriveTemp") { Remove-Item -Recurse -Force "C:\OneDriveTemp" -ErrorAction Stop } } catch {}

# Remove OneDrive from Explorer sidebar
Write-Host "  Removing OneDrive from Explorer..." -ForegroundColor Gray
if (!(Get-PSDrive -Name "HKCR" -ErrorAction SilentlyContinue)) {
	New-PSDrive -PSProvider "Registry" -Root "HKEY_CLASSES_ROOT" -Name "HKCR" -ErrorAction SilentlyContinue | Out-Null
}
if (Test-Path "HKCR:\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}") { Remove-Item -Path "HKCR:\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" -Recurse -Force }
if (Test-Path "HKCR:\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}") { Remove-Item -Path "HKCR:\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" -Recurse -Force }

# Disable OneDrive via Group Policy
if (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive")) {
	New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive" -Force | Out-Null
}
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive" -Name "DisableFileSyncNGSC" -Type DWord -Value 1

# Reset shell folders to local paths (fixes "location not available" after OneDrive removal)
Write-Host "  Resetting shell folder paths to local..." -ForegroundColor Gray
$userProfile = $env:USERPROFILE
$shellFolders = @{
	"Desktop" = "$userProfile\Desktop"
	"Personal" = "$userProfile\Documents"
	"My Pictures" = "$userProfile\Pictures"
	"My Video" = "$userProfile\Videos"
	"My Music" = "$userProfile\Music"
	"{F42EE2D3-909F-4907-8871-4C22FC0BF756}" = "$userProfile\Documents"  # Documents GUID
	"{0DDD015D-B06C-45D5-8C4C-F59713854639}" = "$userProfile\Pictures"   # Pictures GUID
}

foreach ($folder in $shellFolders.GetEnumerator()) {
	$localPath = $folder.Value
	# Create local folder if it doesn't exist
	if (!(Test-Path $localPath)) {
		New-Item -ItemType Directory -Path $localPath -Force | Out-Null
	}
	# Update User Shell Folders registry
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name $folder.Key -Value $localPath -ErrorAction SilentlyContinue
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" -Name $folder.Key -Value $localPath -ErrorAction SilentlyContinue
}

Write-Host "  ✓ OneDrive removed" -ForegroundColor Green
Write-Host ""

# ============================================================================
# SECTION 3: Disable Telemetry and Data Collection
# ============================================================================
Write-Host "🔒 [3/10] Disabling telemetry and data collection..." -ForegroundColor Yellow

# Disable telemetry
Write-Host "  Disabling telemetry..." -ForegroundColor Gray
if (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection")) {
	New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Force | Out-Null
}
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 0
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 0 -ErrorAction SilentlyContinue

# Disable activity history
Write-Host "  Disabling activity history..." -ForegroundColor Gray
if (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System")) {
	New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Force | Out-Null
}
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "EnableActivityFeed" -Type DWord -Value 0
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "PublishUserActivities" -Type DWord -Value 0
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "UploadUserActivities" -Type DWord -Value 0

# Disable app diagnostics
Write-Host "  Disabling app diagnostics..." -ForegroundColor Gray
if (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack")) {
	New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack" -Force | Out-Null
}
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack" -Name "ShowedToastAtLevel" -Type DWord -Value 1

# Disable feedback
Write-Host "  Disabling feedback..." -ForegroundColor Gray
if (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Siuf\Rules")) {
	New-Item -Path "HKCU:\SOFTWARE\Microsoft\Siuf\Rules" -Force | Out-Null
}
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Siuf\Rules" -Name "NumberOfSIUFInPeriod" -Type DWord -Value 0
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "DoNotShowFeedbackNotifications" -Type DWord -Value 1 -ErrorAction SilentlyContinue

# Disable advertising ID
Write-Host "  Disabling advertising ID..." -ForegroundColor Gray
if (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo")) {
	New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" -Force | Out-Null
}
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" -Name "Enabled" -Type DWord -Value 0

# Disable location tracking
Write-Host "  Disabling location tracking..." -ForegroundColor Gray
if (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location")) {
	New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" -Force | Out-Null
}
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" -Name "Value" -Type String -Value "Deny"

Write-Host "  ✓ Telemetry disabled" -ForegroundColor Green
Write-Host ""

# ============================================================================
# SECTION 4: Disable Windows Consumer Features
# ============================================================================
Write-Host "🛒 [4/10] Disabling consumer features..." -ForegroundColor Yellow

# Disable consumer features (prevents automatic app installs)
Write-Host "  Disabling automatic app installs..." -ForegroundColor Gray
if (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent")) {
	New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Force | Out-Null
}
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name "DisableWindowsConsumerFeatures" -Type DWord -Value 1
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name "DisableSoftLanding" -Type DWord -Value 1
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name "DisableWindowsSpotlightFeatures" -Type DWord -Value 1

# Disable suggestions and tips
Write-Host "  Disabling suggestions and tips..." -ForegroundColor Gray
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "ContentDeliveryAllowed" -Type DWord -Value 0 -ErrorAction SilentlyContinue
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "OemPreInstalledAppsEnabled" -Type DWord -Value 0 -ErrorAction SilentlyContinue
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "PreInstalledAppsEnabled" -Type DWord -Value 0 -ErrorAction SilentlyContinue
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "PreInstalledAppsEverEnabled" -Type DWord -Value 0 -ErrorAction SilentlyContinue
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SilentInstalledAppsEnabled" -Type DWord -Value 0 -ErrorAction SilentlyContinue
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338387Enabled" -Type DWord -Value 0 -ErrorAction SilentlyContinue
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338388Enabled" -Type DWord -Value 0 -ErrorAction SilentlyContinue
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338389Enabled" -Type DWord -Value 0 -ErrorAction SilentlyContinue
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-353698Enabled" -Type DWord -Value 0 -ErrorAction SilentlyContinue
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SystemPaneSuggestionsEnabled" -Type DWord -Value 0 -ErrorAction SilentlyContinue

# Disable Start Menu suggestions
Write-Host "  Disabling Start Menu suggestions..." -ForegroundColor Gray
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_IrisRecommendations" -Type DWord -Value 0 -ErrorAction SilentlyContinue
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_AccountNotifications" -Type DWord -Value 0 -ErrorAction SilentlyContinue

Write-Host "  ✓ Consumer features disabled" -ForegroundColor Green
Write-Host ""

# ============================================================================
# SECTION 5: Disable Cortana and Web Search
# ============================================================================
Write-Host "🔍 [5/10] Disabling Cortana and web search..." -ForegroundColor Yellow

# Disable Cortana
Write-Host "  Disabling Cortana..." -ForegroundColor Gray
if (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search")) {
	New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Force | Out-Null
}
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "AllowCortana" -Type DWord -Value 0
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "DisableWebSearch" -Type DWord -Value 1
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "ConnectedSearchUseWeb" -Type DWord -Value 0

# Disable web search in Start Menu
Write-Host "  Disabling web search in Start Menu..." -ForegroundColor Gray
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "BingSearchEnabled" -Type DWord -Value 0 -ErrorAction SilentlyContinue
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "CortanaConsent" -Type DWord -Value 0 -ErrorAction SilentlyContinue

Write-Host "  ✓ Cortana and web search disabled" -ForegroundColor Green
Write-Host ""

# ============================================================================
# SECTION 6: Disable Unnecessary Services
# ============================================================================
Write-Host "⚙️  [6/10] Disabling unnecessary services..." -ForegroundColor Yellow

$services = @(
	"DiagTrack"                 # Connected User Experiences and Telemetry
	"dmwappushservice"          # WAP Push Message Routing Service
	"RetailDemo"                # Retail Demo Service
	"XblAuthManager"            # Xbox Live Auth Manager
	"XblGameSave"               # Xbox Live Game Save
	"XboxGipSvc"                # Xbox Accessory Management Service
	"XboxNetApiSvc"             # Xbox Live Networking Service
)

foreach ($service in $services) {
	if (Get-Service -Name $service -ErrorAction SilentlyContinue) {
		Write-Host "  Disabling: $service" -ForegroundColor Gray
		Stop-Service $service -Force -ErrorAction SilentlyContinue
		Set-Service $service -StartupType Disabled -ErrorAction SilentlyContinue
	}
}

Write-Host "  ✓ Services disabled" -ForegroundColor Green
Write-Host ""

# ============================================================================
# SECTION 7: Additional Privacy and Performance Tweaks
# ============================================================================
Write-Host "🔧 [7/10] Applying additional tweaks..." -ForegroundColor Yellow

# Disable GameDVR
Write-Host "  Disabling Game DVR..." -ForegroundColor Gray
if (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR")) {
	New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" -Force | Out-Null
}
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" -Name "AllowGameDVR" -Type DWord -Value 0

# Enable Dark Mode
Write-Host "  Enabling Dark Mode..." -ForegroundColor Gray
$themePath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize"
Set-ItemProperty -Path $themePath -Name "AppsUseLightTheme" -Type DWord -Value 0
Set-ItemProperty -Path $themePath -Name "SystemUsesLightTheme" -Type DWord -Value 0

# Enable Remote Desktop
Write-Host "  Enabling Remote Desktop..." -ForegroundColor Gray
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Type DWord -Value 0
# Disable NLA requirement
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" -Name "UserAuthentication" -Type DWord -Value 0
# Enable firewall rule for RDP
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"
# Add Administrators to Remote Desktop Users
Add-LocalGroupMember -Group "Remote Desktop Users" -Member "Administrators" -ErrorAction SilentlyContinue

# Disable unnecessary scheduled tasks
Write-Host "  Disabling unnecessary scheduled tasks..." -ForegroundColor Gray
$tasks = @(
	"\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser"
	"\Microsoft\Windows\Application Experience\ProgramDataUpdater"
	"\Microsoft\Windows\Autochk\Proxy"
	"\Microsoft\Windows\Customer Experience Improvement Program\Consolidator"
	"\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip"
	"\Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector"
	"\Microsoft\Windows\Feedback\Siuf\DmClient"
	"\Microsoft\Windows\Feedback\Siuf\DmClientOnScenarioDownload"
	"\Microsoft\Windows\Windows Error Reporting\QueueReporting"
)

foreach ($task in $tasks) {
	try {
		$taskName = ($task -split '\\')[-1]
		$null = Get-ScheduledTask -TaskName $taskName -ErrorAction Stop
		Disable-ScheduledTask -TaskName $task -ErrorAction SilentlyContinue | Out-Null
	} catch {}
}

# Disable Windows Spotlight
Write-Host "  Disabling Windows Spotlight..." -ForegroundColor Gray
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "RotatingLockScreenEnabled" -Type DWord -Value 0 -ErrorAction SilentlyContinue
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "RotatingLockScreenOverlayEnabled" -Type DWord -Value 0 -ErrorAction SilentlyContinue
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338387Enabled" -Type DWord -Value 0 -ErrorAction SilentlyContinue

Write-Host "  ✓ Additional tweaks applied" -ForegroundColor Green
Write-Host ""

# ============================================================================
# SECTION 8: Apply Settings to Default User Profile (for Sysprep)
# ============================================================================
Write-Host "👥 [8/10] Applying settings to default user profile..." -ForegroundColor Yellow

# Load the default user registry hive
$defaultUserHive = "C:\Users\Default\NTUSER.DAT"
$tempKey = "HKU\DefaultUser"

Write-Host "  Loading default user hive..." -ForegroundColor Gray
reg load $tempKey $defaultUserHive 2>$null

if ($?) {
	# Apply all HKCU settings to the default user profile
	Write-Host "  Applying privacy settings to default profile..." -ForegroundColor Gray

	# Diagnostics
	if (!(Test-Path "Registry::$tempKey\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack")) {
		New-Item -Path "Registry::$tempKey\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack" -Force | Out-Null
	}
	Set-ItemProperty -Path "Registry::$tempKey\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack" -Name "ShowedToastAtLevel" -Type DWord -Value 1 -ErrorAction SilentlyContinue

	# Feedback
	if (!(Test-Path "Registry::$tempKey\SOFTWARE\Microsoft\Siuf\Rules")) {
		New-Item -Path "Registry::$tempKey\SOFTWARE\Microsoft\Siuf\Rules" -Force | Out-Null
	}
	Set-ItemProperty -Path "Registry::$tempKey\SOFTWARE\Microsoft\Siuf\Rules" -Name "NumberOfSIUFInPeriod" -Type DWord -Value 0 -ErrorAction SilentlyContinue

	# Advertising ID
	if (!(Test-Path "Registry::$tempKey\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo")) {
		New-Item -Path "Registry::$tempKey\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" -Force | Out-Null
	}
	Set-ItemProperty -Path "Registry::$tempKey\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" -Name "Enabled" -Type DWord -Value 0 -ErrorAction SilentlyContinue

	# Content Delivery Manager (suggestions, tips, auto-installs)
	Write-Host "  Applying content delivery settings to default profile..." -ForegroundColor Gray
	$cdmPath = "Registry::$tempKey\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
	if (!(Test-Path $cdmPath)) {
		New-Item -Path $cdmPath -Force | Out-Null
	}
	Set-ItemProperty -Path $cdmPath -Name "ContentDeliveryAllowed" -Type DWord -Value 0 -ErrorAction SilentlyContinue
	Set-ItemProperty -Path $cdmPath -Name "OemPreInstalledAppsEnabled" -Type DWord -Value 0 -ErrorAction SilentlyContinue
	Set-ItemProperty -Path $cdmPath -Name "PreInstalledAppsEnabled" -Type DWord -Value 0 -ErrorAction SilentlyContinue
	Set-ItemProperty -Path $cdmPath -Name "PreInstalledAppsEverEnabled" -Type DWord -Value 0 -ErrorAction SilentlyContinue
	Set-ItemProperty -Path $cdmPath -Name "SilentInstalledAppsEnabled" -Type DWord -Value 0 -ErrorAction SilentlyContinue
	Set-ItemProperty -Path $cdmPath -Name "SubscribedContent-338387Enabled" -Type DWord -Value 0 -ErrorAction SilentlyContinue
	Set-ItemProperty -Path $cdmPath -Name "SubscribedContent-338388Enabled" -Type DWord -Value 0 -ErrorAction SilentlyContinue
	Set-ItemProperty -Path $cdmPath -Name "SubscribedContent-338389Enabled" -Type DWord -Value 0 -ErrorAction SilentlyContinue
	Set-ItemProperty -Path $cdmPath -Name "SubscribedContent-353698Enabled" -Type DWord -Value 0 -ErrorAction SilentlyContinue
	Set-ItemProperty -Path $cdmPath -Name "SystemPaneSuggestionsEnabled" -Type DWord -Value 0 -ErrorAction SilentlyContinue
	Set-ItemProperty -Path $cdmPath -Name "RotatingLockScreenEnabled" -Type DWord -Value 0 -ErrorAction SilentlyContinue
	Set-ItemProperty -Path $cdmPath -Name "RotatingLockScreenOverlayEnabled" -Type DWord -Value 0 -ErrorAction SilentlyContinue

	# Start Menu suggestions
	Write-Host "  Applying Start Menu settings to default profile..." -ForegroundColor Gray
	$explorerPath = "Registry::$tempKey\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
	if (!(Test-Path $explorerPath)) {
		New-Item -Path $explorerPath -Force | Out-Null
	}
	Set-ItemProperty -Path $explorerPath -Name "Start_IrisRecommendations" -Type DWord -Value 0 -ErrorAction SilentlyContinue
	Set-ItemProperty -Path $explorerPath -Name "Start_AccountNotifications" -Type DWord -Value 0 -ErrorAction SilentlyContinue

	# Search settings
	Write-Host "  Applying search settings to default profile..." -ForegroundColor Gray
	$searchPath = "Registry::$tempKey\SOFTWARE\Microsoft\Windows\CurrentVersion\Search"
	if (!(Test-Path $searchPath)) {
		New-Item -Path $searchPath -Force | Out-Null
	}
	Set-ItemProperty -Path $searchPath -Name "BingSearchEnabled" -Type DWord -Value 0 -ErrorAction SilentlyContinue
	Set-ItemProperty -Path $searchPath -Name "CortanaConsent" -Type DWord -Value 0 -ErrorAction SilentlyContinue

	# Unload the hive
	Write-Host "  Unloading default user hive..." -ForegroundColor Gray
	[gc]::Collect()
	Start-Sleep -Seconds 2
	reg unload $tempKey 2>$null

	Write-Host "  ✓ Default user profile configured" -ForegroundColor Green
} else {
	Write-Host "  ⚠ Could not load default user hive - skipping" -ForegroundColor Yellow
}
Write-Host ""

# ============================================================================
# SECTION 9: Remove Promoted App Shortcuts
# ============================================================================
Write-Host "🔗 [9/10] Removing promoted app shortcuts..." -ForegroundColor Yellow

# Remove LinkedIn and other promoted app shortcuts from Start Menu and Desktop
$shortcutLocations = @(
	"$env:ProgramData\Microsoft\Windows\Start Menu\Programs",
	"$env:APPDATA\Microsoft\Windows\Start Menu\Programs",
	"$env:PUBLIC\Desktop",
	"$env:USERPROFILE\Desktop",
	"$env:ALLUSERSPROFILE\Microsoft\Windows\Start Menu\Programs",
	"C:\Users\Default\AppData\Roaming\Microsoft\Windows\Start Menu\Programs"
)

$promotedApps = @("*LinkedIn*", "*TikTok*", "*Instagram*", "*Facebook*", "*Spotify*", "*Disney*", "*Netflix*", "*Prime Video*", "*Hulu*")

foreach ($location in $shortcutLocations) {
	if (Test-Path $location) {
		foreach ($app in $promotedApps) {
			# Remove .lnk shortcuts
			Get-ChildItem -Path $location -Filter "*.lnk" -Recurse -ErrorAction SilentlyContinue | Where-Object { $_.Name -like $app } | ForEach-Object {
				Write-Host "  Removing: $($_.Name)" -ForegroundColor Gray
				Remove-Item -Path $_.FullName -Force -ErrorAction SilentlyContinue
			}
			# Remove .url web shortcuts
			Get-ChildItem -Path $location -Filter "*.url" -Recurse -ErrorAction SilentlyContinue | Where-Object { $_.Name -like $app } | ForEach-Object {
				Write-Host "  Removing: $($_.Name)" -ForegroundColor Gray
				Remove-Item -Path $_.FullName -Force -ErrorAction SilentlyContinue
			}
		}
	}
}

# Also remove any LinkedIn folders
$linkedInFolders = @(
	"$env:LOCALAPPDATA\LinkedIn",
	"$env:APPDATA\LinkedIn",
	"$env:ProgramData\LinkedIn"
)
foreach ($folder in $linkedInFolders) {
	if (Test-Path $folder) {
		Write-Host "  Removing LinkedIn folder: $folder" -ForegroundColor Gray
		Remove-Item -Path $folder -Recurse -Force -ErrorAction SilentlyContinue
	}
}

# Clear Start Menu cache to force refresh
Write-Host "  Clearing Start Menu cache..." -ForegroundColor Gray
$startCache = "$env:LOCALAPPDATA\Packages\Microsoft.Windows.StartMenuExperienceHost_cw5n1h2txyewy\TempState"
if (Test-Path $startCache) {
	Remove-Item -Path "$startCache\*" -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Host "  ✓ Promoted app shortcuts removed" -ForegroundColor Green
Write-Host ""

# ============================================================================
# SECTION 10: Clean up Taskbar
# ============================================================================
Write-Host "📌 [10/10] Cleaning up taskbar..." -ForegroundColor Yellow

# Remove Store from taskbar
Write-Host "  Unpinning Microsoft Store from taskbar..." -ForegroundColor Gray
try {
	$shell = New-Object -ComObject Shell.Application
	$apps = $shell.NameSpace("shell:::{4234d49b-0245-4df3-b780-3893943456e1}").Items()
	$store = $apps | Where-Object { $_.Path -like "*WindowsStore*" }
	if ($store) { $store.InvokeVerb("taskbarunpin") }
} catch {}

# Remove Outlook from taskbar
Write-Host "  Unpinning Outlook from taskbar..." -ForegroundColor Gray
try {
	$outlook = $apps | Where-Object { $_.Path -like "*Outlook*" }
	if ($outlook) { $outlook.InvokeVerb("taskbarunpin") }
} catch {}

# Disable Chat/Teams icon on taskbar
Write-Host "  Disabling Chat icon on taskbar..." -ForegroundColor Gray
$taskbarPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
Set-ItemProperty -Path $taskbarPath -Name "TaskbarMn" -Type DWord -Value 0 -ErrorAction SilentlyContinue

# Disable Widgets/Weather on taskbar
Write-Host "  Disabling Widgets (weather/news)..." -ForegroundColor Gray
Set-ItemProperty -Path $taskbarPath -Name "TaskbarDa" -Type DWord -Value 0 -ErrorAction SilentlyContinue
# Also disable via policy
if (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Dsh")) {
	New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Dsh" -Force | Out-Null
}
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Dsh" -Name "AllowNewsAndInterests" -Type DWord -Value 0 -ErrorAction SilentlyContinue

# Disable Search box on taskbar (show icon only)
Write-Host "  Setting search to icon only..." -ForegroundColor Gray
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -Type DWord -Value 1 -ErrorAction SilentlyContinue

# Restart Explorer to apply taskbar changes
Write-Host "  Restarting Explorer to apply changes..." -ForegroundColor Gray
Stop-Process -Name explorer -Force
Start-Sleep -Seconds 2

Write-Host "  ✓ Taskbar cleaned up" -ForegroundColor Green
Write-Host ""

# ============================================================================
# Complete
# ============================================================================
Write-Host ""
Write-Host "╔═════════════════════════════════════════════════════════╗" -ForegroundColor DarkGray
Write-Host "║     ✅ Debloat complete!                                ║" -ForegroundColor DarkGray
Write-Host "╠═════════════════════════════════════════════════════════╣" -ForegroundColor DarkGray
Write-Host "║  Next steps:                                            ║" -ForegroundColor DarkGray
Write-Host "║    1. Reboot Windows                                    ║" -ForegroundColor DarkGray
Write-Host "║    2. Run Windows Update one more time                  ║" -ForegroundColor DarkGray
Write-Host "║    3. Run your workstation setup script                 ║" -ForegroundColor DarkGray
Write-Host "╠═════════════════════════════════════════════════════════╣" -ForegroundColor DarkGray
Write-Host "║       Thank you 🤝 for using 🧙‍♂️ Kelomai 🚀              ║" -ForegroundColor DarkGray
Write-Host "║              https://kelomai.io                         ║" -ForegroundColor DarkGray
Write-Host "╚═════════════════════════════════════════════════════════╝" -ForegroundColor DarkGray
Write-Host ""

