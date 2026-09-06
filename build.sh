#!/bin/bash

# Script de build pour Vercel
# Génère le fichier .env à partir des variables d'environnement Vercel

echo "Génération du fichier .env..."

# Créer le fichier .env avec les variables d'environnement
if [ ! -z "$IMGBB_API_KEY" ]; then
  echo "IMGBB_API_KEY=$IMGBB_API_KEY" > .env
  echo "Fichier .env généré avec succès"
else
  echo "Avertissement: IMGBB_API_KEY non défini, création d'un fichier .env vide"
  echo "IMGBB_API_KEY=" > .env
fi

echo "Lancement du build Flutter..."

# Lancer le build Flutter
flutter build web

echo "Build terminé"
