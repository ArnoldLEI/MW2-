param(
    [string]$GamePath='D:\SteamLibrary\steamapps\common\Call of Duty Modern Warfare 2',
    [string]$PythonPath=''
)
$ErrorActionPreference='Stop'
if (Get-Process iw4sp -ErrorAction SilentlyContinue) { throw 'Close MW2 first.' }
$taskPrepare=Join-Path $PSScriptRoot 'prepare_payload.py'
if ($PythonPath) {
    & $PythonPath $taskPrepare --game $GamePath
} elseif (Get-Command py -ErrorAction SilentlyContinue) {
    & py -3 $taskPrepare --game $GamePath
} elseif (Get-Command python -ErrorAction SilentlyContinue) {
    & python $taskPrepare --game $GamePath
} else {
    throw 'Python 3 is required. Install Python or use -PythonPath with its full path.'
}
if ($LASTEXITCODE -ne 0) { throw 'Delta preparation failed; game files have not been changed.' }
& (Join-Path $PSScriptRoot '管理漢化.ps1') -Mode Install -GamePath $GamePath
