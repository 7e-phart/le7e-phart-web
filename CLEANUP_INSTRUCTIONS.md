# Instructions pour nettoyer l'espace disque

## Fichiers à supprimer pour libérer de l'espace

### 1. Cache Gradle (2-5 Go)
**Chemin :** `C:\Users\foret\.gradle\caches\`
**Action :** Supprimer tout le dossier `caches`

### 2. Daemon Gradle (500 Mo - 1 Go)
**Chemin :** `C:\Users\foret\.gradle\daemon\`
**Action :** Supprimer tout le dossier `daemon`

### 3. Wrapper Gradle (100-200 Mo)
**Chemin :** `C:\Users\foret\.gradle\wrapper\`
**Action :** Supprimer tout le dossier `wrapper`

### 4. Cache Flutter (1-2 Go)
**Chemin :** `C:\Users\foret\.flutter\`
**Action :** Supprimer tout le dossier `.flutter`

### 5. Build du projet (500 Mo - 1 Go)
**Chemin :** `c:\Users\foret\CascadeProjects\le7e-phart\flutter_app\build\`
**Action :** Déjà nettoyé avec `flutter clean`

## Procédure de nettoyage

1. **Fermer tous les processus en cours :**
   - Fermer l'émulateur Android
   - Arrêter tous les processus `flutter` (Ctrl+C dans les terminaux)
   - Fermer Android Studio s'il est ouvert

2. **Supprimer manuellement les dossiers :**
   - Ouvrir l'Explorateur de fichiers
   - Naviguer vers `C:\Users\foret\.gradle\`
   - Supprimer les dossiers `caches`, `daemon`, et `wrapper`
   - Naviguer vers `C:\Users\foret\.flutter\`
   - Supprimer le dossier `.flutter`

3. **Nettoyer le projet :**
   ```bash
   cd c:\Users\foret\CascadeProjects\le7e-phart\flutter_app
   flutter clean
   ```

## Espace libéré estimé
- Total : 4-8 Go

## Note importante
Après ce nettoyage, le prochain build Flutter téléchargera à nouveau les dépendances nécessaires (environ 1-2 Go), mais ce sera une seule fois. Les builds suivants seront plus rapides.
