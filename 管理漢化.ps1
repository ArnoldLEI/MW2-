param(
    [ValidateSet('Install','Restore')][string]$Mode='Install',
    [string]$GamePath='D:\SteamLibrary\steamapps\common\Call of Duty Modern Warfare 2'
)
$ErrorActionPreference='Stop'
if (Get-Process iw4sp -ErrorAction SilentlyContinue) { throw 'Close MW2 first.' }
$taskManifest=Get-Content (Join-Path $PSScriptRoot 'manifest.json') -Raw -Encoding UTF8 | ConvertFrom-Json
$taskGame=(Resolve-Path -LiteralPath $GamePath).Path
if (-not (Test-Path -LiteralPath (Join-Path $taskGame 'iw4sp.exe'))) { throw 'MW2 not found.' }
$taskBackupDir=Join-Path $taskGame 'Codex_MW2_zhTW_Backup'
$taskStatePath=Join-Path $taskBackupDir 'native-state.json'
function Get-TaskHash([string]$Path) { (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant() }
function Save-TaskState($State) { $State | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $taskStatePath -Encoding UTF8 }
function Set-TaskLanguage([string]$Value) {
    $taskConfigPath=Join-Path $taskGame 'players\config.cfg'
    if (Test-Path -LiteralPath $taskConfigPath) {
        $taskConfig=[System.IO.File]::ReadAllText($taskConfigPath)
        if ($taskConfig -match '(?m)^seta loc_language "[0-9]+"') {
            $taskConfig=[regex]::Replace($taskConfig,'(?m)^seta loc_language "[0-9]+"',('seta loc_language "'+$Value+'"'))
            [System.IO.File]::WriteAllText($taskConfigPath,$taskConfig,[System.Text.UTF8Encoding]::new($false))
        }
    }
}
if ($Mode -eq 'Install') {
    # Validate every source and payload before changing the installation.
    foreach ($taskFile in $taskManifest.files) {
        $taskTarget=Join-Path $taskGame $taskFile.path
        $taskPayload=Join-Path $PSScriptRoot ('payload/'+$taskFile.path)
        if ((Get-TaskHash $taskPayload) -ne $taskFile.patch_sha256) { throw "Payload mismatch: $($taskFile.path)" }
        $taskHash=Get-TaskHash $taskTarget
        if ($taskHash -ne $taskFile.original_sha256 -and $taskHash -ne $taskFile.patch_sha256) { throw "Unsupported game file: $($taskFile.path)" }
        $taskBackup=Join-Path $taskBackupDir $taskFile.path
        if ((Test-Path -LiteralPath $taskBackup) -and (Get-TaskHash $taskBackup) -ne $taskFile.original_sha256) { throw "Backup mismatch: $($taskFile.path)" }
        if ($taskHash -eq $taskFile.patch_sha256 -and -not (Test-Path -LiteralPath $taskBackup)) { throw "Original backup missing: $($taskFile.path)" }
    }
    $taskJunction=Join-Path $taskGame 'zone\taiwanese'
    $taskEnglish=Join-Path $taskGame 'zone\english'
    if (Test-Path -LiteralPath $taskJunction) {
        $taskItem=Get-Item -LiteralPath $taskJunction
        if ($taskItem.LinkType -ne 'Junction' -or [string]$taskItem.Target -ne $taskEnglish) { throw 'Existing Taiwanese resource directory is not owned by this patch.' }
    }
    $taskOriginalLanguage='0'
    $taskCfgPath=Join-Path $taskGame 'players\config.cfg'
    if (Test-Path -LiteralPath $taskCfgPath) {
        $taskMatch=[regex]::Match([System.IO.File]::ReadAllText($taskCfgPath),'(?m)^seta loc_language "([0-9]+)"')
        if ($taskMatch.Success) { $taskOriginalLanguage=$taskMatch.Groups[1].Value }
    }
    New-Item -ItemType Directory -Path $taskBackupDir -Force | Out-Null
    if (Test-Path -LiteralPath $taskStatePath) {
        $taskState=Get-Content -LiteralPath $taskStatePath -Raw -Encoding UTF8 | ConvertFrom-Json
    } else {
        $taskState=[pscustomobject]@{ original_language=$taskOriginalLanguage; created_links=@(); created_junction=$false; installed=$false }
        Save-TaskState $taskState
    }
    foreach ($taskFile in $taskManifest.files) {
        $taskTarget=Join-Path $taskGame $taskFile.path
        $taskBackup=Join-Path $taskBackupDir $taskFile.path
        if (-not (Test-Path -LiteralPath $taskBackup)) {
            New-Item -ItemType Directory -Path (Split-Path $taskBackup -Parent) -Force | Out-Null
            Copy-Item -LiteralPath $taskTarget -Destination $taskBackup
        }
        if ((Get-TaskHash $taskBackup) -ne $taskFile.original_sha256) { throw 'Backup verification failed.' }
    }
    foreach ($taskIwd in $taskManifest.localized_iwds) {
        $taskOriginal=Join-Path $taskGame ('main/'+$taskIwd.source)
        $taskAlias=Join-Path $taskGame ('main/'+$taskIwd.alias)
        if ((Get-Item -LiteralPath $taskOriginal).Length -ne $taskIwd.bytes) { throw 'Original language IWD size differs.' }
        if (Test-Path -LiteralPath $taskAlias) {
            $taskAliasItem=Get-Item -LiteralPath $taskAlias
            if ($taskAliasItem.LinkType -ne 'HardLink' -or (Get-TaskHash $taskAlias) -ne (Get-TaskHash $taskOriginal)) { throw 'Existing Taiwanese IWD differs.' }
        } else {
            New-Item -ItemType HardLink -Path $taskAlias -Target $taskOriginal | Out-Null
            $taskState.created_links=@($taskState.created_links)+@('main/'+$taskIwd.alias)
            Save-TaskState $taskState
        }
    }
    if (-not (Test-Path -LiteralPath $taskJunction)) {
        New-Item -ItemType Junction -Path $taskJunction -Target $taskEnglish | Out-Null
        $taskState.created_junction=$true
        Save-TaskState $taskState
    }
    foreach ($taskFile in $taskManifest.files) {
        $taskTarget=Join-Path $taskGame $taskFile.path
        Copy-Item -LiteralPath (Join-Path $PSScriptRoot ('payload/'+$taskFile.path)) -Destination $taskTarget -Force
        if ((Get-TaskHash $taskTarget) -ne $taskFile.patch_sha256) { throw 'Install verification failed.' }
    }
    Set-TaskLanguage '9'
    $taskState.installed=$true;Save-TaskState $taskState
    Write-Output 'Traditional Chinese campaign patch installed. Original files verified and backed up.'
} else {
    if (-not (Test-Path -LiteralPath $taskStatePath)) { throw 'Native locale ownership record missing.' }
    $taskState=Get-Content -LiteralPath $taskStatePath -Raw -Encoding UTF8 | ConvertFrom-Json
    foreach ($taskFile in $taskManifest.files) {
        $taskHash=Get-TaskHash (Join-Path $taskGame $taskFile.path)
        if ($taskHash -ne $taskFile.original_sha256 -and $taskHash -ne $taskFile.patch_sha256) { throw 'Game file changed by another update; restoration stopped.' }
        if ((Get-TaskHash (Join-Path $taskBackupDir $taskFile.path)) -ne $taskFile.original_sha256) { throw 'Backup hash mismatch.' }
    }
    # Each link path is restricted to the known game directory; never recurse.
    foreach ($taskRelative in $taskState.created_links) {
        if ($taskRelative -notmatch '^main/localized_taiwanese_iw0[0-4]\.iwd$') { throw 'Unexpected link ownership entry.' }
        $taskAlias=Join-Path $taskGame $taskRelative
        if (Test-Path -LiteralPath $taskAlias) {
            $taskItem=Get-Item -LiteralPath $taskAlias
            if ($taskItem.LinkType -ne 'HardLink') { throw 'Resource alias is no longer a hard link.' }
            $taskSource=Join-Path $taskGame ($taskRelative -replace 'localized_taiwanese_','localized_english_')
            if ((Get-TaskHash $taskAlias) -ne (Get-TaskHash $taskSource)) { throw 'Resource alias differs from original.' }
        }
    }
    $taskJunction=Join-Path $taskGame 'zone\taiwanese'
    if ($taskState.created_junction -and (Test-Path -LiteralPath $taskJunction)) {
        $taskItem=Get-Item -LiteralPath $taskJunction
        if ($taskItem.LinkType -ne 'Junction' -or [string]$taskItem.Target -ne (Join-Path $taskGame 'zone\english')) { throw 'Junction target changed; restoration stopped.' }
    }
    foreach ($taskFile in $taskManifest.files) {
        $taskTarget=Join-Path $taskGame $taskFile.path
        Copy-Item -LiteralPath (Join-Path $taskBackupDir $taskFile.path) -Destination $taskTarget -Force
        if ((Get-TaskHash $taskTarget) -ne $taskFile.original_sha256) { throw 'Restore verification failed.' }
    }
    Set-TaskLanguage ([string]$taskState.original_language)
    foreach ($taskRelative in $taskState.created_links) {
        $taskAlias=Join-Path $taskGame $taskRelative
        if (Test-Path -LiteralPath $taskAlias) { Remove-Item -LiteralPath $taskAlias -Force }
    }
    if ($taskState.created_junction -and (Test-Path -LiteralPath $taskJunction)) { [System.IO.Directory]::Delete($taskJunction) }
    $taskState.installed=$false;$taskState.created_links=@();$taskState.created_junction=$false;Save-TaskState $taskState
    Write-Output 'Original files and language restored. Save files preserved.'
}
