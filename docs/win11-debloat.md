# Windows 11 Debloat

Remove bloatware, disable telemetry, and optimize Windows 11 for development.

## Quick Start

```powershell
irm https://raw.githubusercontent.com/kelomai/bellows/main/win11-setup/Debloat-Windows.ps1 | iex
```

### Run with Options

```powershell
# Download first for inspection
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/kelomai/bellows/main/win11-setup/Debloat-Windows.ps1" -OutFile "Debloat-Windows.ps1"

# Preview changes
.\Debloat-Windows.ps1 -DryRun

# Run with full debloat
.\Debloat-Windows.ps1
```

## What Gets Removed

### Bloatware Apps

The script removes pre-installed apps that most users don't need:

| App | Description |
|-----|-------------|
| **Xbox Apps** | Xbox, Xbox Game Bar, Xbox Identity Provider |
| **Bing Apps** | Bing News, Weather, Sports |
| **Games** | Candy Crush, Solitaire Collection |
| **Microsoft Apps** | Mixed Reality Portal, 3D Viewer, 3D Builder |
| **Social** | People, Your Phone |
| **Entertainment** | Groove Music, Movies & TV |
| **Others** | Tips, Get Help, Feedback Hub |

### Telemetry Disabled

| Setting | Description |
|---------|-------------|
| **Diagnostic Data** | Set to minimum required |
| **Advertising ID** | Disabled |
| **Activity History** | Disabled |
| **Location Tracking** | Disabled for apps |
| **Inking & Typing** | Personalization disabled |

### Services Optimized

| Service | Action |
|---------|--------|
| **Connected User Experiences** | Disabled |
| **WAP Push Message Routing** | Disabled |
| **dmwappushservice** | Disabled |
| **Diagnostic Tracking** | Disabled |

## What's Preserved

The script is careful to preserve:

- **Windows Defender** - Security remains enabled
- **Windows Update** - Updates continue to work
- **Windows Store** - Can still install apps
- **Core System Apps** - Calculator, Photos, Settings
- **Developer Tools** - PowerShell, CMD, WSL

## Privacy Improvements

### Registry Changes

```powershell
# Disable advertising ID
HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo
DisabledByGroupPolicy = 1

# Disable telemetry
HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection
AllowTelemetry = 0

# Disable Cortana
HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search
AllowCortana = 0
```

### Scheduled Tasks Disabled

| Task | Description |
|------|-------------|
| **Microsoft Compatibility Appraiser** | Telemetry collection |
| **Consolidator** | Telemetry upload |
| **UsbCeip** | USB telemetry |
| **KernelCeipTask** | Kernel telemetry |

## Performance Improvements

### Visual Effects

- Adjusted for best performance
- Smooth fonts preserved
- Animations reduced

### Startup Apps

- Review and disable unnecessary startup apps
- Use Task Manager > Startup tab

### Background Apps

- Most background apps disabled
- Essential services preserved

## Reversing Changes

### Re-enable Apps

```powershell
# Example: Re-enable Xbox
Get-AppxPackage -Name *Xbox* -AllUsers | ForEach-Object {
    Add-AppxPackage -Register "$($_.InstallLocation)\AppxManifest.xml" -DisableDevelopmentMode
}
```

### Re-enable Telemetry

```powershell
# Enable telemetry
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Value 3
```

### Re-enable Services

```powershell
# Enable a service
Set-Service -Name "DiagTrack" -StartupType Automatic
Start-Service -Name "DiagTrack"
```

## Recommendations

### Before Running

1. **Create a restore point** - Settings > System > About > System Protection
2. **Back up important data**
3. **Run with -DryRun first** to preview changes

### After Running

1. **Restart your computer**
2. **Check Windows Update** still works
3. **Verify critical apps** still function

## Known Issues

### Some games may not work

If Xbox services are removed, some Microsoft Store games may not launch.

**Fix:** Reinstall Xbox services:
```powershell
Get-AppxPackage -Name *Xbox* | ForEach-Object {
    Add-AppxPackage -Register "$($_.InstallLocation)\AppxManifest.xml"
}
```

### Cortana search may be limited

With Cortana disabled, search uses Windows Search only.

### Some Settings pages may be empty

If associated apps are removed, their Settings pages may be blank.

## Script Details

### Exit Codes

| Code | Description |
|------|-------------|
| 0 | Success |
| 1 | Error (requires admin) |

### Logging

The script logs actions to:
```
$env:USERPROFILE\debloat-windows.log
```

## Related Documentation

- [Windows Dev Workstation](win11-dev-workstation.md) - Developer setup
- [Windows Client Workstation](win11-client-workstation.md) - Business user setup
- [Main Documentation](README.md) - All scripts overview
