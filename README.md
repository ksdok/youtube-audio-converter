# YouTube Audio Converter

Un script Bash professionnel pour extraire l'audio de vidéos YouTube et les convertir en fichiers audio (MP3 par défaut) avec la meilleure qualité possible.

## 🚀 Fonctionnalités

- **Multi-source** : Conversion d'une seule URL, de plusieurs URLs ou d'un fichier texte.
- **Mode Playlist** : Support complet des playlists YouTube et YouTube Music (`--playlist`).
- **Anti-Doublons** : Système d'archivage pour éviter de retélécharger des vidéos déjà traitées (`--archive`).
- **Qualité Maximale** : Extraction automatique de la meilleure qualité audio disponible (qualité 0).
- **Flexibilité** : Dossier de sortie et format audio configurables.
- **Robuste** : Vérification automatique des dépendances (`yt-dlp`, `ffmpeg`) et gestion des erreurs.

## 🛠️ Prérequis

Le script nécessite les outils suivants :

1. **yt-dlp** (fortement recommandé) ou **youtube-dl**.
2. **ffmpeg** (indispensable pour la conversion audio).

### Installation rapide

#### macOS (via Homebrew)
```bash
brew install yt-dlp ffmpeg
```

#### Ubuntu/Debian
```bash
sudo apt update && sudo apt install yt-dlp ffmpeg
```

#### Fedora
```bash
sudo dnf install yt-dlp ffmpeg
```

#### Via pip
```bash
pip install yt-dlp
```

> **Note** : `ffmpeg` doit être installé comme binaire système. Le paquet Python `ffmpeg-python` ne suffit pas.

## 📖 Utilisation

### 1. Téléchargement simple (vidéos uniques)
Pour une ou plusieurs vidéos :
```bash
./youtube_to_mp3.sh "https://www.youtube.com/watch?v=ID1" "https://www.youtube.com/watch?v=ID2"
```

### 2. Utilisation d'un fichier d'URLs
Créez un fichier `urls.txt` avec une URL par ligne, puis :
```bash
./youtube_to_mp3.sh urls.txt
```

### 3. Téléchargement d'une Playlist complète
Par défaut, le script ne télécharge que la première vidéo d'une playlist pour éviter les téléchargements massifs accidentels. Utilisez l'option `--playlist` pour traiter toute la liste :
```bash
./youtube_to_mp3.sh --playlist "https://www.youtube.com/playlist?list=ID_PLAYLIST"
```

### 4. Éviter les doublons avec une archive
Pour ne pas retélécharger des vidéos déjà convertiées lors de sessions précédentes :
```bash
./youtube_to_mp3.sh --archive archive.txt urls.txt
```
*Le script créera `archive.txt` et y enregistrera l'ID de chaque vidéo traitée.*

### 5. Personnalisation du dossier et du format
```bash
# Sortie dans un dossier spécifique et format WAV
./youtube_to_mp3.sh -o "./ma_musique" -f wav "https://www.youtube.com/watch?v=ID"
```

## ⚙️ Options CLI

| Option | Description | Valeur par défaut |
| :--- | :--- | :--- |
| `-h, --help` | Affiche l'aide | - |
| `-o, --output` | Dossier de sortie des fichiers audio | `./mp3` |
| `-f, --format` | Format audio (`mp3`, `m4a`, `wav`, etc.) | `mp3` |
| `--playlist` | Autorise le téléchargement complet d'une playlist | Désactivé |
| `--archive FILE` | Fichier pour suivre les vidéos déjà téléchargées | Aucun |

## 📄 Format du fichier d'URLs

Le script accepte des fichiers texte simples. Les lignes vides et les commentaires commençant par `#` sont ignorés.

```text
# Mes classiques
https://www.youtube.com/watch?v=abc12345
https://www.youtube.com/watch?v=def67890

# À traiter plus tard
# https://www.youtube.com/watch?v=ghi11122
```

## 📦 Sortie et Nommage

Les fichiers sont enregistrés sous la forme : `Titre de la Vidéo [ID_YouTube].mp3`.
L'inclusion de l'ID permet d'éviter d'écraser des fichiers ayant le même titre.

## ⚠️ Remarques et Dépannage

### Problèmes de permissions
Si le script refuse de se lancer, rendez-le exécutable :
```bash
chmod +x youtube_to_mp3.sh
```

### Erreurs de téléchargement
- **URL invalide** : Vérifiez que l'URL est bien une adresse YouTube valide.
- **Contenu restreint** : Certaines vidéos (âge, région) peuvent bloquer le téléchargement.
- **Mise à jour de yt-dlp** : YouTube change fréquemment ses algorithmes. Si le téléchargement échoue, mettez à jour `yt-dlp` :
  - `pip install -U yt-dlp` ou `brew upgrade yt-dlp`.

### Droits d'auteur
L'utilisation de ce script doit se faire dans le respect des conditions d'utilisation de YouTube et des droits de propriété intellectuelle.

## ⚖️ Licence

Ce projet est distribué sous licence **MIT**. Voir le fichier `LICENSE` pour plus de détails.
