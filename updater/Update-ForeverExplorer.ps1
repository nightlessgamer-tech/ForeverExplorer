param(
    [Parameter(Mandatory = $true)]
    [string]$AddonPath
)

$ErrorActionPreference = "Stop"
$repo = "nightlessgamer-tech/ForeverExplorer"
$branch = "main"
$rawBase = "https://raw.githubusercontent.com/$repo/$branch/release"

if (-not (Test-Path -LiteralPath $AddonPath -PathType Container)) {
    throw "Dossier addon introuvable : $AddonPath"
}

$manifestUrl = "$rawBase/manifest.json"
Write-Host "Lecture du manifeste : $manifestUrl"
$manifest = Invoke-RestMethod -Uri $manifestUrl -UseBasicParsing
if (-not $manifest.version -or -not $manifest.files) {
    throw "Manifeste invalide : version ou liste de fichiers manquante."
}

$stamp = Get-Date -Format "yyyyMMdd-HHmmss"
$backupPath = "$AddonPath-backup-$stamp"
New-Item -ItemType Directory -Path $backupPath | Out-Null
Write-Host "Sauvegarde des fichiers existants vers : $backupPath"

foreach ($relative in $manifest.files) {
    $safeRelative = $relative -replace '/', '\'
    $destination = Join-Path $AddonPath $safeRelative
    if (Test-Path -LiteralPath $destination -PathType Leaf) {
        $backupFile = Join-Path $backupPath $safeRelative
        $backupDir = Split-Path -Parent $backupFile
        if (-not (Test-Path -LiteralPath $backupDir)) {
            New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
        }
        Copy-Item -LiteralPath $destination -Destination $backupFile -Force
    }
}

foreach ($relative in $manifest.files) {
    $urlPath = $relative -replace '\', '/'
    $url = "$rawBase/$urlPath"
    $destination = Join-Path $AddonPath ($relative -replace '/', '\')
    $directory = Split-Path -Parent $destination
    if (-not (Test-Path -LiteralPath $directory)) {
        New-Item -ItemType Directory -Path $directory -Force | Out-Null
    }
    $temporary = "$destination.download"
    Write-Host "Téléchargement : $relative"
    Invoke-WebRequest -Uri $url -OutFile $temporary -UseBasicParsing
    if ((Get-Item -LiteralPath $temporary).Length -eq 0) {
        Remove-Item -LiteralPath $temporary -Force
        throw "Fichier vide reçu : $relative"
    }
    Move-Item -LiteralPath $temporary -Destination $destination -Force
}

Write-Host ""
Write-Host "Forever Explorer $($manifest.version) installé."
Write-Host "Sauvegarde disponible ici : $backupPath"
Write-Host "Relance WoW et vérifie /fe. La progression SavedVariables n'a pas été modifiée."
