#!/bin/bash

# Script de build pour Vercel
# Génère le fichier .env à partir des variables d'environnement Vercel

echo "Génération du fichier .env..."

# Créer le fichier .env avec les variables d'environnement
echo "IMGBB_API_KEY=$IMGBB_API_KEY" > .env

echo "Fichier .env généré avec succès"
echo "Lancement du build Flutter..."

# Lancer le build Flutter
flutter build web

echo "Build terminé"
