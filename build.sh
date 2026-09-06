#!/bin/bash

# Script de build pour Vercel
# Installe Flutter si nécessaire et génère le fichier .env

echo "Installation de Flutter..."

# Télécharger et installer Flutter
if ! command -v flutter &> /dev/null; then
  echo "Flutter non trouvé, installation en cours..."
  git clone https://github.com/flutter/flutter.git -b stable --depth 1
  export PATH="$PATH:$PWD/flutter/bin"
  flutter precache
  flutter doctor
else
  echo "Flutter déjà installé"
fi

echo "Génération du fichier .env..."

# Créer le fichier .env avec les variables d'environnement
if [ ! -z "$IMGBB_API_KEY" ]; then
  echo "IMGBB_API_KEY=$IMGBB_API_KEY" > .env
  echo "Fichier .env généré avec succès"
else
  echo "Avertissement: IMGBB_API_KEY non défini, création d'un fichier .env vide"
  echo "IMGBB_API_KEY=" > .env
fi

echo "Installation des dépendances Flutter..."
flutter pub get

echo "Lancement du build Flutter optimisé..."

# Lancer le build Flutter avec optimisations
flutter build web --release --tree-shake-icons

echo "Build terminé"
