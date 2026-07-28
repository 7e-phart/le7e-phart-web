# Instructions pour générer l'APK Android

## Prérequis
- Flutter installé et configuré
- Android SDK installé
- Espace disque suffisant (au moins 5 Go libres)

## Configuration effectuée
L'application a été configurée pour être compatible avec Android :
- **Compile SDK**: 36
- **Target SDK**: 36
- **Min SDK**: Défini par Flutter
- **Java Version**: 17
- **Kotlin Version**: 2.2.20
- **Gradle Version**: 8.14
- **Android Gradle Plugin**: 8.11.1

## Générer l'APK

### Option 1: APK Debug (pour tests)
```bash
flutter build apk --debug --android-skip-build-dependency-validation
```

### Option 2: APK Release (pour distribution)
```bash
flutter build apk --release --android-skip-build-dependency-validation
```

### Option 3: App Bundle (pour Google Play)
```bash
flutter build appbundle --release --android-skip-build-dependency-validation
```

## Localisation de l'APK généré
Après compilation, l'APK se trouve dans :
```
build/app/outputs/flutter-apk/app-release.apk
```
ou pour debug :
```
build/app/outputs/flutter-apk/app-debug.apk
```

## Libérer de l'espace disque
Si le build échoue avec "Espace insuffisant sur le disque", vous pouvez :

1. **Nettoyer le cache Gradle** :
   ```bash
   cd android
   gradlew clean
   cd ..
   flutter clean
   ```

2. **Supprimer le cache Gradle manuellement** :
   - `C:\Users\foret\.gradle\caches\`

3. **Nettoyer le cache Flutter** :
   ```bash
   flutter clean
   ```

4. **Libérer de l'espace sur le disque C:**

## Partager l'APK
Une fois généré, l'APK peut être :
- Envoyé par email
- Hébergé sur un serveur web
- Partagé via Google Drive ou Dropbox
- Uploadé sur Google Play Console

## Signature de l'APK (pour distribution publique)
Pour publier sur Google Play, l'APK doit être signé. Contactez-moi pour configurer la signature si nécessaire.
