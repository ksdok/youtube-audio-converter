# YouTube Audio Converter

Un script Bash pour extraire le son de vidéos YouTube et les convertir en fichiers audio, MP3 par défaut, avec la meilleure qualité disponible.

## Fonctionnalités

- Extraction audio de vidéos YouTube
- Conversion en MP3 par défaut avec la meilleure qualité disponible
- Prise en charge de plusieurs URLs en entrée
- Gestion des fichiers d'URLs
- Nommage automatique des fichiers avec le titre de la vidéo
- Affichage de la progression et du résumé

## Prérequis

Le script nécessite les outils suivants :

1. **yt-dlp** ou **youtube-dl** (yt-dlp est recommandé pour de meilleures performances)
2. **ffmpeg** pour la conversion audio

### Installation des dépendances

#### macOS
```bash
# Avec Homebrew
brew install yt-dlp ffmpeg
```

#### Ubuntu/Debian
```bash
sudo apt update
sudo apt install yt-dlp ffmpeg
```

#### Fedora
```bash
sudo dnf install yt-dlp ffmpeg
```

#### Via pip
```bash
pip install yt-dlp
```

> Note : `ffmpeg` doit être installé séparément via Homebrew, apt, dnf ou un binaire système. Le paquet Python `ffmpeg-python` n'installe pas l'exécutable `ffmpeg` requis par ce script.

## Utilisation

### Utilisation avec un fichier d'URLs
```bash
./youtube_to_mp3.sh urls.txt
```

### Utilisation avec des URLs directement
```bash
./youtube_to_mp3.sh "https://www.youtube.com/watch?v=example1" "https://www.youtube.com/watch?v=example2"
```

### Options supplémentaires
```bash
# Spécifier un dossier de sortie
./youtube_to_mp3.sh -o /chemin/vers/dossier urls.txt

# Spécifier un format audio pris en charge par yt-dlp/ffmpeg
./youtube_to_mp3.sh -f mp3 urls.txt

# Afficher l'aide
./youtube_to_mp3.sh -h
```

## Format du fichier d'URLs

Créez un fichier texte avec une URL YouTube par ligne :

```
https://www.youtube.com/watch?v=example1
https://www.youtube.com/watch?v=example2
# Ceci est un commentaire et sera ignoré
https://www.youtube.com/watch?v=example3
```

## Sortie

Les fichiers audio seront générés dans le dossier `./mp3` par défaut, ou dans le dossier spécifié avec l'option `-o`.

Les fichiers sont nommés automatiquement avec le titre de la vidéo et son identifiant YouTube pour éviter les collisions, par exemple `Titre de la vidéo [abc123].mp3`.

## Remarques importantes

1. **Droits d'auteur** : Assurez-vous de respecter les droits d'auteur et les conditions d'utilisation de YouTube.
2. **Qualité** : Le script utilise la meilleure qualité audio disponible (qualité 0).
3. **Formats** : Le script peut produire d'autres formats audio avec l'option `-f/--format`, par exemple `-f m4a` ou `-f wav`, selon les formats pris en charge par `yt-dlp` et `ffmpeg`.

## Dépannage

### Erreurs de dépendances
Si vous voyez des erreurs concernant des dépendances manquantes, assurez-vous d'avoir installé yt-dlp (ou youtube-dl) et ffmpeg comme indiqué dans la section "Installation des dépendances".

### Problèmes de permissions
Si vous rencontrez des problèmes de permissions, assurez-vous que le script est exécutable :
```bash
chmod +x youtube_to_mp3.sh
```

### Problèmes de téléchargement
- Vérifiez que les URLs sont valides
- Certaines vidéos peuvent avoir des restrictions de téléchargement
- Assurez-vous d'avoir une connexion Internet stable