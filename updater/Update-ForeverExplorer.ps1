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

# Download all files to staging first; don't replace anything unless all downloads succeed.
$stamp = Get-Date -Format "yyyyMMdd-HHmmss"
$stagingPath = Join-Path $env:TEMP "ForeverExplorer-update-$stamp"
New-Item -ItemType Directory -Path $stagingPath -Force | Out-Null

try {
    foreach ($relative in $manifest.files) {
        $urlPath = $relative.Replace('\', '/')
        $url = "$rawBase/$urlPath"
        $stagedFile = Join-Path $stagingPath ($relative.Replace('/', '\'))
        $stagedDir = Split-Path -Parent $stagedFile
        if (-not (Test-Path -LiteralPath $stagedDir)) {
            New-Item -ItemType Directory -Path $stagedDir -Force | Out-Null
        }
        Write-Host "Téléchargement : $relative"
        Invoke-WebRequest -Uri $url -OutFile $stagedFile -UseBasicParsing
        if (-not (Test-Path -LiteralPath $stagedFile -PathType Leaf) -or (Get-Item -LiteralPath $stagedFile).Length -eq 0) {
            throw "Fichier vide ou absent : $relative"
        }
    }

    $backupPath = "$AddonPath-backup-$stamp"
    New-Item -ItemType Directory -Path $backupPath -Force | Out-Null
    Write-Host "Sauvegarde des fichiers existants vers : $backupPath"

    foreach ($relative in $manifest.files) {
        $localRelative = $relative.Replace('/', '\')
        $destination = Join-Path $AddonPath $localRelative
        if (Test-Path -LiteralPath $destination -PathType Leaf) {
            $backupFile = Join-Path $backupPath $localRelative
            $backupDir = Split-Path -Parent $backupFile
            if (-not (Test-Path -LiteralPath $backupDir)) {
                New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
            }
            Copy-Item -LiteralPath $destination -Destination $backupFile -Force
        }
    }

    foreach ($relative in $manifest.files) {
        $localRelative = $relative.Replace('/', '\')
        $source = Join-Path $stagingPath $localRelative
        $destination = Join-Path $AddonPath $localRelative
        $directory = Split-Path -Parent $destination
        if (-not (Test-Path -LiteralPath $directory)) {
            New-Item -ItemType Directory -Path $directory -Force | Out-Null
        }
        Copy-Item -LiteralPath $source -Destination $destination -Force
    }

    Write-Host ""
    Write-Host "Forever Explorer $($manifest.version) installé."
    Write-Host "Sauvegarde disponible ici : $backupPath"
    Write-Host "Relance WoW et vérifie /fe. Les SavedVariables n'ont pas été modifiées."
}
finally {
    if (Test-Path -LiteralPath $stagingPath) {
        Remove-Item -LiteralPath $stagingPath -Recurse -Force
    }
}
