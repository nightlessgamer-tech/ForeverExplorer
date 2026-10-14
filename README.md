# Forever Explorer

Addon d'aide au leveling pour **WoW Forever**, client `1.60.1.70374` / interface `16001`.

## Mise à jour sous Windows

1. Ferme WoW.
2. Ouvre PowerShell.
3. Copie-colle ces lignes (adapte le chemin si ton dossier de jeu est différent) :

```powershell
$updater = Join-Path $env:TEMP "Update-ForeverExplorer.ps1"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/nightlessgamer-tech/ForeverExplorer/main/updater/Update-ForeverExplorer.ps1" -OutFile $updater
powershell -ExecutionPolicy Bypass -File $updater -AddonPath "C:\Program Files (x86)\World of Warcraft\_classic_beta_\Interface\AddOns\ForeverExplorer"
```

Le script sauvegarde les fichiers de l'addon qu'il remplace dans un dossier voisin daté. Il ne touche pas aux SavedVariables du jeu : ta progression reste gérée par WoW.

## Structure

- `release/` : version de l'addon et manifeste de fichiers
- `updater/` : outil Windows pour télécharger la version publiée
- `.github/workflows/` : validation basique du paquet lors des modifications

## Important

Cet outil télécharge uniquement les fichiers publiés dans ce dépôt. Il ne découvre pas automatiquement de nouvelles quêtes ni des changements du serveur : les données doivent être vérifiées puis publiées ici. Une tâche planifiée Windows pourra vérifier les mises à jour régulièrement.

Le guide est orienté Alliance. Les étapes au-delà du niveau 30 sont indicatives et doivent être confirmées en jeu sur WoW Forever. Compatibilité ciblée : interface `16001`; les API du serveur peuvent différer du client officiel.
