# Inventaire du PC pour le labo de modding.
# LECTURE SEULE : n'installe rien, ne modifie rien, n'envoie rien sur Internet.
# Usage : powershell -ExecutionPolicy Bypass -File tools\inventaire-pc.ps1 > inventaire.txt
# (Texte sans accents : Windows PowerShell 5.1 lit les .ps1 sans BOM en ANSI.)

$ErrorActionPreference = 'SilentlyContinue'

function Section($title) { Write-Output ""; Write-Output "==== $title ====" }

function Show-Tool($label, $command, $versionArgs) {
    $cmd = Get-Command $command -ErrorAction SilentlyContinue | Select-Object -First 1
    if (-not $cmd) { Write-Output ("  [--] {0,-12} absent" -f $label); return }
    $version = ''
    if ($versionArgs) {
        $version = (cmd /c "`"$($cmd.Source)`" $versionArgs 2>&1" | Select-Object -First 1)
    }
    Write-Output ("  [OK] {0,-12} {1}  ({2})" -f $label, $version, $cmd.Source)
}

Section "Systeme"
$os = Get-CimInstance Win32_OperatingSystem
$cpu = Get-CimInstance Win32_Processor | Select-Object -First 1
Write-Output ("  OS      : {0} (build {1})" -f $os.Caption, $os.BuildNumber)
Write-Output ("  CPU     : {0} ({1} coeurs / {2} threads)" -f $cpu.Name.Trim(), $cpu.NumberOfCores, $cpu.NumberOfLogicalProcessors)
Write-Output ("  RAM     : {0:N0} Go" -f ($os.TotalVisibleMemorySize / 1MB))
foreach ($gpu in Get-CimInstance Win32_VideoController) {
    Write-Output ("  GPU     : {0} (pilote {1})" -f $gpu.Name, $gpu.DriverVersion)
}
foreach ($disk in Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3") {
    Write-Output ("  Disque {0} {1:N0} Go libres / {2:N0} Go" -f $disk.DeviceID, ($disk.FreeSpace / 1GB), ($disk.Size / 1GB))
}

Section "Outils de developpement"
Show-Tool 'git'      'git'      '--version'
Show-Tool 'python'   'python'   '--version'
Show-Tool 'py'       'py'       '--version'
Show-Tool 'uv'       'uv'       '--version'
Show-Tool 'java'     'java'     '-version'
Show-Tool 'cmake'    'cmake'    '--version'
Show-Tool 'cargo'    'cargo'    '--version'
Show-Tool 'dotnet'   'dotnet'   '--version'
Show-Tool 'node'     'node'     '--version'
Show-Tool 'ffmpeg'   'ffmpeg'   '-version'
Show-Tool 'blender'  'blender'  '--version'
Show-Tool 'claude'   'claude'   '--version'
Show-Tool 'wsl'      'wsl'      $null

$vswhere = Join-Path ${env:ProgramFiles(x86)} 'Microsoft Visual Studio\Installer\vswhere.exe'
if (Test-Path $vswhere) {
    foreach ($vs in (& $vswhere -products * -format json | ConvertFrom-Json)) {
        $hasCpp = & $vswhere -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property instanceId
        Write-Output ("  [OK] VisualStudio {0} {1}  C++: {2}" -f $vs.displayName, $vs.installationVersion, $(if ($hasCpp) { 'oui' } else { 'non' }))
    }
} else { Write-Output "  [--] VisualStudio absent" }

$candidates = @(
    @{ Label = 'Ghidra';    Paths = @("$env:ProgramFiles\ghidra*", "$env:USERPROFILE\ghidra*", "C:\ghidra*", "C:\Tools\ghidra*") },
    @{ Label = 'RenderDoc'; Paths = @("$env:ProgramFiles\RenderDoc") },
    @{ Label = 'ILSpy';     Paths = @("$env:ProgramFiles\ILSpy*", "$env:USERPROFILE\.dotnet\tools\ilspycmd.exe") },
    @{ Label = 'x64dbg';    Paths = @("$env:ProgramFiles\x64dbg*", "C:\Tools\x64dbg*") },
    @{ Label = 'Blender';   Paths = @("$env:ProgramFiles\Blender Foundation\*") }
)
foreach ($c in $candidates) {
    $found = $c.Paths | ForEach-Object { Get-Item $_ -ErrorAction SilentlyContinue } | Select-Object -First 1
    if ($found) { Write-Output ("  [OK] {0,-12} {1}" -f $c.Label, $found.FullName) }
    else { Write-Output ("  [--] {0,-12} non trouve aux emplacements usuels" -f $c.Label) }
}

Section "Jeux Steam"
$steam = (Get-ItemProperty 'HKCU:\Software\Valve\Steam').SteamPath
if ($steam) {
    $libraries = @($steam)
    $vdf = Join-Path $steam 'steamapps\libraryfolders.vdf'
    if (Test-Path $vdf) {
        foreach ($line in Get-Content $vdf) {
            if ($line -match '"path"\s+"([^"]+)"') { $libraries += ($Matches[1] -replace '\\\\', '\') }
        }
    }
    foreach ($lib in ($libraries | Select-Object -Unique)) {
        foreach ($acf in Get-ChildItem (Join-Path $lib 'steamapps') -Filter 'appmanifest_*.acf') {
            $text = Get-Content $acf.FullName -Raw
            $name = if ($text -match '"name"\s+"([^"]+)"') { $Matches[1] } else { '?' }
            $build = if ($text -match '"buildid"\s+"([^"]+)"') { $Matches[1] } else { '?' }
            $dir = if ($text -match '"installdir"\s+"([^"]+)"') { $Matches[1] } else { '?' }
            Write-Output ("  {0}  (build {1})  {2}" -f $name, $build, (Join-Path $lib "steamapps\common\$dir"))
        }
    }
} else { Write-Output "  Steam non detecte" }

Section "Jeux Epic"
$epic = 'C:\ProgramData\Epic\EpicGamesLauncher\Data\Manifests'
if (Test-Path $epic) {
    foreach ($item in Get-ChildItem $epic -Filter '*.item') {
        $m = Get-Content $item.FullName -Raw | ConvertFrom-Json
        Write-Output ("  {0}  ({1})  {2}" -f $m.DisplayName, $m.AppVersionString, $m.InstallLocation)
    }
} else { Write-Output "  Epic non detecte" }

Section "Autres jeux et lanceurs (registre, lecture seule)"
$publishers = 'Activision|Blizzard|Electronic Arts|EA |Bethesda|Rockstar|Ubisoft|Mojang|Microsoft Studios|CD PROJEKT|FromSoftware|Bandai'
$keys = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*',
        'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*',
        'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*'
Get-ItemProperty $keys |
    Where-Object { $_.Publisher -match $publishers -or $_.DisplayName -match 'Battle\.net|EA app|Rockstar Games Launcher|Ubisoft Connect' } |
    Sort-Object DisplayName -Unique |
    ForEach-Object { Write-Output ("  {0}  [{1}]  {2}" -f $_.DisplayName, $_.Publisher, $_.InstallLocation) }

Section "Minecraft Java"
$mc = Join-Path $env:APPDATA '.minecraft'
if (Test-Path $mc) {
    Write-Output "  Dossier : $mc"
    $versions = Get-ChildItem (Join-Path $mc 'versions') -Directory | Select-Object -ExpandProperty Name
    Write-Output ("  Versions installees : {0}" -f ($versions -join ', '))
    if (Test-Path (Join-Path $mc 'mods')) { Write-Output "  Dossier mods present (Fabric/Forge probable)" }
} else { Write-Output "  .minecraft non trouve (launcher non installe, ou autre emplacement)" }

Write-Output ""
Write-Output "Fin de l'inventaire. Aucune modification n'a ete faite."
