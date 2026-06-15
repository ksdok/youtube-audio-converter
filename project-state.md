# Project State — YouTube Audio Converter

Dernière mise à jour : 2026-06-15

## État actuel

Le projet contient un script Bash `youtube_to_mp3.sh` permettant d'extraire l'audio de vidéos YouTube avec `yt-dlp` ou `youtube-dl`, puis de convertir le résultat avec `ffmpeg`.

Fonctionnalités déjà disponibles :

- Conversion d'une ou plusieurs URLs YouTube en audio.
- Lecture d'un fichier d'URLs.
- Format de sortie configurable avec `-f/--format`.
- Dossier de sortie configurable avec `-o/--output`.
- Vérification des dépendances `yt-dlp`/`youtube-dl` et `ffmpeg`.
- Résumé des succès/échecs.
- Exclusion Git des fichiers audio générés via `.gitignore`.

Limitations connues :

- Les playlists YouTube sont explicitement refusées.
- Le README principal n'est pas nommé `README.md`.
- Pas de mode interactif.
- Pas de système anti-doublons persistant.
- Pas de logs détaillés.
- Pas d'installation globale du script.
- Pas de tests automatisés.

## Échelle de complexité

- XS : changement très simple, faible risque.
- S : petite amélioration localisée.
- M : fonctionnalité moyenne avec quelques cas à vérifier.
- L : fonctionnalité importante qui touche plusieurs parties.
- XL : trop large pour un seul ticket, à découper.

## Backlog

### TICKET-001 — Renommer la documentation principale en README.md

Complexité : XS

Description :
Renommer `README_YOUTUBE_MP3.md` en `README.md` afin que GitHub affiche automatiquement la documentation sur la page du dépôt.

Critères d'acceptation :

- Le fichier `README.md` existe à la racine du projet.
- L'ancien fichier `README_YOUTUBE_MP3.md` n'est plus nécessaire.
- La page GitHub du dépôt affiche la documentation.

---

### TICKET-002 — Ajouter le support explicite des playlists YouTube

Complexité initiale : L

Description :
Permettre au script de télécharger l'audio d'une playlist YouTube complète, sans casser le comportement actuel qui limite volontairement les URLs vidéo à une seule vidéo via `--no-playlist`.

Découpage recommandé :

#### TICKET-002A — Détecter les URLs de playlists

Complexité : S

Description :
Modifier la validation d'URL pour reconnaître les URLs de playlist YouTube et YouTube Music.

Critères d'acceptation :

- `https://www.youtube.com/playlist?list=...` est reconnue comme URL supportée.
- `https://music.youtube.com/playlist?list=...` est reconnue comme URL supportée.
- Les URLs non YouTube restent refusées.

#### TICKET-002B — Ajouter une option `--playlist`

Complexité : M

Description :
Ajouter une option CLI explicite `--playlist` pour autoriser le traitement d'une playlist. Sans cette option, garder le comportement actuel avec `--no-playlist` pour éviter les téléchargements accidentels.

Critères d'acceptation :

- `./youtube_to_mp3.sh --playlist "URL_PLAYLIST"` télécharge la playlist.
- `./youtube_to_mp3.sh "URL_VIDEO_AVEC_LIST"` ne télécharge qu'une seule vidéo.
- L'aide `--help` documente l'option.

#### TICKET-002C — Adapter le nommage des fichiers pour les playlists

Complexité : S

Description :
Utiliser un template de sortie contenant l'index de playlist lorsque le mode playlist est actif.

Critères d'acceptation :

- Les fichiers d'une playlist sont nommés avec un préfixe d'ordre, par exemple `01 - Titre [id].mp3`.
- Les vidéos seules conservent le nommage actuel.

---

### TICKET-003 — Ajouter une archive anti-doublons

Complexité : M

Description :
Ajouter une option permettant d'utiliser `--download-archive` de `yt-dlp`, afin d'éviter de retélécharger les vidéos déjà traitées.

Option proposée :

```bash
./youtube_to_mp3.sh --archive downloaded.txt urls.txt
```

Critères d'acceptation :

- L'utilisateur peut fournir un fichier d'archive personnalisé.
- Si l'option n'est pas fournie, le comportement actuel reste inchangé.
- Une playlist relancée ne retélécharge pas les vidéos déjà présentes dans l'archive.

---

### TICKET-004 — Ajouter une option d'intégration des métadonnées

Complexité : M

Description :
Ajouter une option `--metadata` pour transmettre à `yt-dlp` les options d'intégration des métadonnées et miniatures lorsque c'est possible.

Options `yt-dlp` candidates :

```bash
--embed-metadata
--embed-thumbnail
```

Critères d'acceptation :

- `./youtube_to_mp3.sh --metadata URL` ajoute les métadonnées au fichier généré.
- Sans `--metadata`, le comportement actuel reste inchangé.
- La documentation mentionne que l'intégration des miniatures peut dépendre du format de sortie et de `ffmpeg`.

---

### TICKET-005 — Ajouter un mode simulation / dry-run

Complexité : M

Description :
Ajouter une option `--dry-run` pour afficher ce qui serait téléchargé sans lancer la conversion.

Critères d'acceptation :

- `./youtube_to_mp3.sh --dry-run URL` affiche le ou les titres détectés.
- Aucun fichier audio n'est créé.
- Fonctionne avec les fichiers d'URLs.
- Fonctionne avec les playlists si `--playlist` est aussi fourni.

---

### TICKET-006 — Ajouter un mode interactif

Complexité initiale : L

Description :
Permettre à un utilisateur non technique de lancer le script sans connaître les options CLI.

Découpage recommandé :

#### TICKET-006A — Ajouter l'option `--interactive`

Complexité : S

Description :
Ajouter une option qui déclenche un assistant en terminal.

Critères d'acceptation :

- `./youtube_to_mp3.sh --interactive` lance le mode interactif.
- L'aide documente l'option.

#### TICKET-006B — Demander l'URL, le format et le dossier de sortie

Complexité : M

Description :
Dans le mode interactif, demander à l'utilisateur l'URL ou le fichier, le format audio et le dossier de sortie.

Critères d'acceptation :

- L'utilisateur peut valider les valeurs par défaut avec Entrée.
- Les valeurs saisies sont réutilisées par le flux existant.

#### TICKET-006C — Ajouter une confirmation avant téléchargement

Complexité : S

Description :
Afficher un résumé des paramètres choisis et demander confirmation avant de lancer le téléchargement.

Critères d'acceptation :

- Le script affiche URL/fichier, format et dossier de sortie.
- Réponse `y` ou `yes` lance le traitement.
- Toute autre réponse annule proprement.

---

### TICKET-007 — Ajouter un script d'installation locale

Complexité : M

Description :
Créer un script `install.sh` pour installer la commande dans `~/.local/bin/youtube-to-mp3` ou proposer une autre destination.

Critères d'acceptation :

- `./install.sh` copie le script dans un dossier exécutable utilisateur.
- Le script vérifie que le dossier cible est dans le `PATH` ou affiche une instruction claire.
- Après installation, l'utilisateur peut lancer :

```bash
youtube-to-mp3 urls.txt
```

---

### TICKET-008 — Améliorer le README avec des exemples complets

Complexité : S

Description :
Mettre à jour la documentation avec les cas d'usage principaux et les nouvelles options.

Critères d'acceptation :

- Exemple pour une vidéo seule.
- Exemple pour plusieurs vidéos.
- Exemple avec fichier d'URLs.
- Exemple avec playlist.
- Exemple avec dossier de sortie personnalisé.
- Exemple avec archive anti-doublons.
- Section dépannage enrichie.

---

### TICKET-009 — Ajouter une licence open source

Complexité : XS

Description :
Ajouter un fichier `LICENSE`, probablement en MIT, pour clarifier les droits d'utilisation du projet.

Critères d'acceptation :

- Le fichier `LICENSE` existe.
- Le README mentionne la licence.
- GitHub détecte la licence du dépôt.

---

### TICKET-010 — Ajouter des tests automatisés simples

Complexité initiale : L

Description :
Ajouter des tests pour sécuriser les comportements du script, notamment le parsing des arguments et la validation d'URL.

Découpage recommandé :

#### TICKET-010A — Créer une structure de tests Bash

Complexité : M

Description :
Ajouter un dossier `tests/` avec un premier script de test ou un framework léger comme `bats-core` si choisi.

Critères d'acceptation :

- Un test minimal peut être lancé localement.
- La commande de test est documentée.

#### TICKET-010B — Tester l'aide et les erreurs CLI

Complexité : S

Description :
Tester `--help`, absence d'argument et option inconnue.

Critères d'acceptation :

- `--help` retourne un code succès.
- Absence d'argument retourne une erreur.
- Option inconnue retourne une erreur.

#### TICKET-010C — Tester la validation des URLs

Complexité : M

Description :
Tester les URLs supportées et refusées.

Critères d'acceptation :

- URLs vidéo YouTube acceptées.
- URLs Shorts acceptées.
- URLs Live acceptées.
- URLs playlist acceptées seulement si le ticket playlist est implémenté.
- URLs non YouTube refusées.

---

### TICKET-011 — Ajouter une GitHub Action de validation

Complexité : M

Description :
Ajouter un workflow GitHub Actions pour vérifier automatiquement la syntaxe Bash et ShellCheck à chaque push ou pull request.

Critères d'acceptation :

- Un fichier `.github/workflows/ci.yml` existe.
- Le workflow lance `bash -n youtube_to_mp3.sh`.
- Le workflow lance `shellcheck youtube_to_mp3.sh`.
- Le badge CI peut être ajouté au README.

---

### TICKET-012 — Ajouter un fichier de logs optionnel

Complexité : M

Description :
Ajouter une option `--log FILE` pour écrire un journal des traitements.

Critères d'acceptation :

- Le log contient la date, l'URL, le statut et le format demandé.
- Les succès et échecs sont visibles après exécution.
- Sans option `--log`, le comportement actuel reste inchangé.

---

### TICKET-013 — Ajouter une limite de téléchargement pour playlists

Complexité : S

Description :
Ajouter une option permettant de limiter les éléments traités dans une playlist via `--playlist-items` de `yt-dlp`.

Exemple :

```bash
./youtube_to_mp3.sh --playlist --playlist-items 1-10 "URL_PLAYLIST"
```

Critères d'acceptation :

- L'option est disponible uniquement ou principalement pour le mode playlist.
- La valeur est transmise à `yt-dlp`.
- L'aide documente l'option.

---

### TICKET-014 — Ajouter une option de mise à jour de yt-dlp

Complexité : S

Description :
Ajouter une option `--update-ytdlp` ou documenter une commande de mise à jour, car YouTube change souvent et `yt-dlp` doit rester récent.

Critères d'acceptation :

- L'utilisateur dispose d'une méthode claire pour mettre à jour `yt-dlp`.
- Le script ne casse pas si `yt-dlp` a été installé via Homebrew plutôt que pip.
- La documentation explique les méthodes macOS/Linux.

---

## Ordre de réalisation recommandé

1. TICKET-001 — Renommer le README.
2. TICKET-009 — Ajouter une licence.
3. TICKET-002A/B/C — Support playlists.
4. TICKET-003 — Archive anti-doublons.
5. TICKET-008 — Documentation complète.
6. TICKET-011 — CI ShellCheck.
7. TICKET-005 — Dry-run.
8. TICKET-004 — Métadonnées.
9. TICKET-007 — Installation locale.
10. TICKET-006A/B/C — Mode interactif.
11. TICKET-010A/B/C — Tests automatisés.
12. TICKET-012 — Logs.
13. TICKET-013 — Limite playlists.
14. TICKET-014 — Mise à jour yt-dlp.

## Notes de priorité

La prochaine version utile du projet devrait viser une version `v1.1` avec :

- `README.md`
- `LICENSE`
- support playlist explicite
- archive anti-doublons
- documentation mise à jour

Ces changements améliorent fortement l'utilisation sans rendre le script trop complexe.
