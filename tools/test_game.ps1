param([switch]$Reimport)
$ErrorActionPreference = 'Stop'
$workspace = Split-Path -Parent $PSScriptRoot
$buildDir = Join-Path $workspace '.build'
[System.IO.Directory]::CreateDirectory($buildDir) | Out-Null
if ($Reimport) {
    & python (Join-Path $PSScriptRoot 'build_characters.py')
    if ($LASTEXITCODE -ne 0) { throw 'Native resource generation failed.' }
    & (Join-Path $PSScriptRoot 'import_atlases.ps1') -Workspace $workspace
}
& python (Join-Path $PSScriptRoot 'check_project.py')
if ($LASTEXITCODE -ne 0) { throw 'Project resource validation failed.' }

$gmData = Join-Path $env:ProgramData 'GameMakerStudio2-LTS2026'
$runtimeConfig = Get-Content -LiteralPath (Join-Path $gmData 'runtime.json') -Raw | ConvertFrom-Json
$runtimeDir = ($runtimeConfig.($runtimeConfig.active) -split '&')[0]
$igor = Join-Path $runtimeDir 'bin\igor\windows\x64\Igor.exe'
$runner = Join-Path $runtimeDir 'windows\x64\Runner.exe'
$project = Join-Path $workspace 'MortalKombatRivals.yyp'
$compileLog = Join-Path $buildDir 'compile.log'
& $igor "--project=$project" "--runtimePath=$runtimeDir" "--cache=$buildDir\cache" `
    "--temp=$buildDir\temp" "--of=$buildDir\MortalKombatRivals.zip" `
    "--tf=$buildDir\MortalKombatRivals.exe" `
    "--user=$env:APPDATA\GameMakerStudio2-LTS2026\unknownUser_unknownUserID" -r=VM Windows Compile *> $compileLog
if ($LASTEXITCODE -ne 0) { Get-Content -LiteralPath $compileLog -Tail 50; throw 'GameMaker compilation failed.' }

$stdout = Join-Path $buildDir 'self-test-stdout.log'
$stderr = Join-Path $buildDir 'self-test-stderr.log'
$process = Start-Process -FilePath $runner -ArgumentList @('-game', "`"$buildDir\MortalKombatRivals.win`"", '--self-test') `
    -WorkingDirectory $workspace -WindowStyle Hidden -PassThru -RedirectStandardOutput $stdout -RedirectStandardError $stderr
if (!$process.WaitForExit(90000)) { $process.Kill(); throw 'Integration tests timed out.' }
$output = Get-Content -LiteralPath $stdout -Raw
if ($output -notmatch 'CHARACTER_SELF_TEST_OK: 66 checks' -or $output -match 'FAIL:|ERROR!!!|FATAL ERROR') {
    Write-Output $output
    Get-Content -LiteralPath $stderr
    throw 'Character integration tests failed.'
}
Write-Output 'GameMaker VM compilation passed. All 66 player, selector, boss AI, chain pose, range and gameplay integration checks passed.'
