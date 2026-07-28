# Instructions pour déployer l'application Web

## Fichiers générés

L'application web a été compilée avec succès dans le dossier :
```
build\web
```

Ce dossier contient tous les fichiers nécessaires pour héberger l'application sur un serveur web.

## Options de déploiement (gratuites)

### Option 1: GitHub Pages (Recommandé - Gratuit)

**Avantages :**
- 100% gratuit
- Hébergement automatique via GitHub
- HTTPS automatique
- Domaine personnalisé possible

**Étapes :**

1. **Créer un dépôt GitHub**
   - Allez sur [GitHub](https://github.com) et créez un nouveau dépôt
   - Nommez-le par exemple `le7e-phart-web`

2. **Initialiser Git et pousser le code**
   ```bash
   cd c:\Users\foret\CascadeProjects\le7e-phart-web
   git init
   git add .
   git commit -m "Initial commit"
   git branch -M main
   git remote add origin https://github.com/VOTRE_USERNAME/le7e-phart-web.git
   git push -u origin main
   ```

3. **Activer GitHub Pages**
   - Allez dans les settings du dépôt GitHub
   - Cliquez sur "Pages" dans le menu de gauche
   - Sous "Source", sélectionnez "Deploy from a branch"
   - Sélectionnez "main" et "/ (root)"
   - Cliquez sur "Save"

4. **Attendre le déploiement**
   - GitHub va déployer votre application en quelques minutes
   - L'URL sera : `https://VOTRE_USERNAME.github.io/le7e-phart-web/`

### Option 2: Netlify (Gratuit)

**Avantages :**
- Déploiement automatique via Git
- HTTPS automatique
- Domaine personnalisé gratuit
- Formulaires et fonctions serverless

**Étapes :**

1. **Créer un compte Netlify**
   - Allez sur [Netlify](https://www.netlify.com) et créez un compte gratuit

2. **Connecter votre dépôt GitHub**
   - Dans Netlify, cliquez sur "New site from Git"
   - Connectez votre compte GitHub
   - Sélectionnez votre dépôt `le7e-phart-web`

3. **Configurer le build**
   - Build command: `flutter build web`
   - Publish directory: `build/web`
   - Cliquez sur "Deploy site"

4. **Votre site sera disponible**
   - Netlify vous donnera une URL comme `https://votre-site.netlify.app`

### Option 3: Vercel (Gratuit)

**Avantages :**
- Déploiement automatique via Git
- HTTPS automatique
- Performance optimisée
- Intégration facile avec Next.js (si vous voulez migrer plus tard)

**Étapes :**

1. **Créer un compte Vercel**
   - Allez sur [Vercel](https://vercel.com) et créez un compte gratuit

2. **Importer votre projet**
   - Cliquez sur "New Project"
   - Connectez votre compte GitHub
   - Sélectionnez votre dépôt `le7e-phart-web`

3. **Configurer le projet**
   - Framework Preset: Other
   - Build Command: `flutter build web`
   - Output Directory: `build/web`
   - Cliquez sur "Deploy"

4. **Votre site sera disponible**
   - Vercel vous donnera une URL comme `https://votre-site.vercel.app`

### Option 4: Firebase Hosting (Gratuit)

**Avantages :**
- Intégré avec Firebase (que vous utilisez déjà)
- HTTPS automatique
- Performance globale via CDN
- Facile à déployer avec Firebase CLI

**Étapes :**

1. **Installer Firebase CLI**
   ```bash
   npm install -g firebase-tools
   ```

2. **Initialiser Firebase Hosting**
   ```bash
   cd c:\Users\foret\CascadeProjects\le7e-phart-web
   firebase login
   firebase init
   ```
   - Sélectionnez "Hosting"
   - Sélectionnez votre projet Firebase existant
   - Pour "What do you want to use as your public directory?", entrez `build/web`
   - Pour "Configure as a single-page app?", répondez "Yes"

3. **Déployer**
   ```bash
   firebase deploy
   ```

4. **Votre site sera disponible**
   - Firebase vous donnera une URL comme `https://votre-projet.web.app`

## Option 5: Hébergement traditionnel (Payant)

Si vous avez déjà un hébergement.web (OVH, Ionos, etc.) :

1. **Télécharger les fichiers**
   - Copiez tout le contenu du dossier `build\web`
   - Compressez-le en ZIP

2. **Uploader via FTP**
   - Connectez-vous à votre hébergement via FTP
   - Uploadez les fichiers dans le dossier `public_html` ou `www`

3. **Configurer le domaine**
   - Pointez votre domaine vers votre hébergement

## Test local avant déploiement

Pour tester l'application web localement :

```bash
cd c:\Users\foret\CascadeProjects\le7e-phart-web
flutter run -d chrome
```

Ou utilisez un serveur local simple :

```bash
cd build\web
python -m http.server 8000
```

Puis ouvrez `http://localhost:8000` dans votre navigateur.

## Mises à jour

Pour mettre à jour l'application après des modifications :

1. **Recompiler**
   ```bash
   flutter build web
   ```

2. **Déployer**
   - GitHub Pages : Faites un `git push`
   - Netlify/Vercel : Déploiement automatique après push
   - Firebase : `firebase deploy`

## Configuration Firebase Web

Pour que Firebase fonctionne sur le web, vous devez :

1. **Configurer Firebase pour le web**
   - Dans la console Firebase, allez dans "Project Settings"
   - Cliquez sur "Add app" → "Web"
   - Copiez la configuration Firebase

2. **Mettre à jour firebase_options.dart**
   - Le fichier `lib/firebase_options.dart` doit contenir la configuration web
   - Si nécessaire, régénérez-le avec :
     ```bash
     flutterfire configure
     ```

## Recommandation

**Pour un déploiement simple et gratuit**, je recommande **GitHub Pages** :
- C'est gratuit
- Facile à configurer
- Hébergement fiable
- HTTPS automatique
- Pas besoin de compte supplémentaire si vous avez déjà GitHub

## Support

- [Documentation Flutter Web](https://flutter.dev/docs/platform-integration/web)
- [GitHub Pages Documentation](https://docs.github.com/en/pages)
- [Netlify Documentation](https://docs.netlify.com/)
- [Vercel Documentation](https://vercel.com/docs)
