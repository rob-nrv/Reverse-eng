# Reverse-eng : labo de modding et de mashups de jeux assistés par IA

Expérimenter le modding, la rétro-ingénierie et les mashups entre jeux (dans l'esprit de SkyCraft ou de
Minecraft × GTA V), avec Claude Code comme agent principal, sur des jeux possédés légalement et hors
ligne.

## Contenu

| Fichier | Rôle |
|---|---|
| [`docs/01-analyse-des-projets.md`](docs/01-analyse-des-projets.md) | Ce que font vraiment universal-modder, SkyCraft, l'exemple GTA V et le mashup MW2 × Skate 3, avec le niveau de preuve de chaque affirmation |
| [`docs/02-techniques-expliquees.md`](docs/02-techniques-expliquees.md) | Décompilation, désassemblage, analyse dynamique, RenderDoc, ponts IPC, synchronisation, comparaison des approches |
| [`docs/03-environnement.md`](docs/03-environnement.md) | Outils, universal-modder, MCP utiles, organisation Claude Code |
| [`docs/04-choix-du-premier-projet.md`](docs/04-choix-du-premier-projet.md) | Faisabilité des approches A, B et C, et recommandation |
| [`CLAUDE.md`](CLAUDE.md) | Règles et méthode, chargées automatiquement par Claude Code |
| [`.claude/agents/`](.claude/agents/) | Agents spécialisés : reverse-engineering, game-integration, qa-testing |
| [`MODLOG.md`](MODLOG.md) | Journal partagé : découvertes, échecs, preuves |
| [`tools/inventaire-pc.ps1`](tools/inventaire-pc.ps1) | Inventaire en lecture seule de ton PC (outils et jeux) |

## Prochaine étape

Sur ton PC Windows :
```
powershell -ExecutionPolicy Bypass -File tools\inventaire-pc.ps1 > inventaire.txt
```
Envoie ensuite le résultat à Claude pour choisir le premier projet.

## Règles

Jeux possédés uniquement, hors ligne ou sur un serveur privé. Aucun contournement de DRM ni d'anti-cheat.
Aucun fichier de jeu ni code décompilé dans ce dépôt. Sauvegardes avant toute modification. Détails dans
[`CLAUDE.md`](CLAUDE.md).
