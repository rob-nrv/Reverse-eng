# 3. Environnement de travail

## 3.1 Où tourne quoi : point critique

| Machine | Ce qu'on peut y faire | Ce qu'on ne peut pas y faire |
|---|---|---|
| **Conteneur cloud** (cette session Claude Code) | lire et écrire du code, Rust, C/C++ (gcc, clang, cmake), Python/uv, Node, Java 21, Docker, analyses statiques, tests synthétiques avec faux pairs | **lancer un jeu Windows**, voir l'écran, installer un loader. L'accès réseau est filtré : maven.fabricmc.net, repo.papermc.io et download.blender.org sont bloqués. |
| **Ton PC Windows** | lancer les vrais jeux, le **seul oracle valable**, RenderDoc, x64dbg, MSVC | — |

**Conclusion :** pour un vrai mashup, il faut **Claude Code installé sur ton PC** (CLI ou appli de
bureau). Le conteneur cloud reste utile pour l'analyse, le code « pur » et la CI.

## 3.2 Outils dispo dans le conteneur (vérifié le 2026-10-08)

- **Présents :** git, Python 3.13 + uv, Node 22, Java 21 + Maven + Gradle, **Rust 1.97 (cargo)**, gcc 13,
  clang 18, cmake, ninja, gdb, binutils (objdump, readelf, strings), ffmpeg, Docker.
- **Absents :** .NET / ILSpy, Ghidra, Blender, RenderDoc, Wine, radare2.

Ton PC n'a pas encore été inventorié. Lance `tools/inventaire-pc.ps1` (voir §3.6).

## 3.3 Faut-il prendre universal-modder comme base ? → **Oui, mais en partie**

**Pour :**
- MIT, actif (dernier commit le 2026-10-07).
- Sa méthode et ses règles sont exactement les nôtres.
- La base de connaissances évite de refaire les erreurs des autres.
- Trois outils sont directement utiles :
  - `um scan` : détecte le moteur et l'anti-cheat ;
  - `um backup` : sauvegardes ;
  - `um publish check` : bloque toute fuite de fichiers propriétaires.

**Réserves :**
- `fal` (assets générés) est payant. On ne l'active pas pour l'instant.
- `um win` pilote la souris et le clavier. À n'utiliser qu'avec ton accord, à chaque fois.
- Je n'ai **pas exécuté** son code ici. Il faut lancer ses tests (`uv run --with pytest pytest -q tests`)
  sur ton PC avant de lui faire confiance.

**Installation proposée sur ton PC** (à faire seulement après ton accord) :
```
# Dans Claude Code, sur ton PC :
/plugin marketplace add rehan-remade/universal-modder
/plugin install universal-modder@universal-modder
# CLI seule, sans le plugin :
uv tool install git+https://github.com/rehan-remade/universal-modder
```
Pour la reproductibilité, **épingle un commit** : celui lu ici est `8370faa8e114baf33acdb23079aff552a7728c4b`.

## 3.4 Outils : lesquels, et quand

On n'installe un outil **qu'au moment où le projet choisi en a besoin**.

| Outil | Utile pour | Quand l'installer |
|---|---|---|
| **Python + uv** | CLI `um`, faux pairs, scripts d'analyse | tout de suite |
| **Git** | tout | tout de suite |
| **JDK 25 + Fabric (Loom)** | mods Minecraft 26.x | si Minecraft fait partie du projet (probable) |
| **Visual Studio 2022+ (C++ desktop) + CMake** | plugins SKSE, scripts ScriptHookV, add-ons ReShade | si on touche un jeu C++ (Skyrim, GTA) |
| **Ghidra** (gratuit, NSA, open source) | lire du code natif C/C++ | quand une fonction n'est documentée nulle part |
| **RenderDoc** | caméra, profondeur, passes de rendu | pour un passthrough avec composition d'image |
| **ILSpy / ilspycmd** | jeux Unity Mono / .NET | si on cible un jeu Unity |
| **BepInEx** | loader Unity | idem |
| **SKSE64 + Address Library** | loader Skyrim | si Skyrim |
| **Rust** | réimplémentations (IW4L, SK8-ENGINE) | si on part sur la route C, version lourde |
| **Blender** | conversion de modèles 3D (`um render3d`) | si on fait des assets 3D |

## 3.5 Connexions MCP réellement exploitables

| MCP | Pour quoi | Avis |
|---|---|---|
| **GhidraMCP / pyghidra-mcp** | l'agent décompile, renomme, suit les références | ✅ le plus utile pour la rétro-ingénierie native, dès qu'on a besoin de Ghidra |
| **renderdoc-mcp** | l'agent lit une capture de frame | ✅ si passthrough |
| ILSpy-MCP | requêtes sur du C# décompilé | ✅ si Unity |
| x64dbg-mcp / CheatEngine MCP | analyse live de la mémoire | ⚠️ seulement en solo hors ligne. À **lier à 127.0.0.1** (certains écoutent sur 0.0.0.0 par défaut). |
| fal MCP | génération d'assets | ⏸ payant, plus tard |

Chaque serveur MCP est du code tiers. Avant de l'installer : vérifier le dépôt, sa licence, son activité,
et épingler une version.

## 3.6 Inventaire de ton PC

`tools/inventaire-pc.ps1` est **en lecture seule** : il n'installe et ne modifie rien. Il liste :
- Windows, le CPU, la RAM, le GPU et l'espace disque ;
- les outils présents (Java, Python, uv, Git, Visual Studio/MSVC, CMake, Rust, .NET, Ghidra, Blender,
  RenderDoc, WSL) ;
- **les jeux installés via Steam** (manifestes `appmanifest_*.acf`), et ceux d'Epic, Battle.net et EA
  quand ils sont détectables.

Pour le lancer, dans PowerShell :
```
powershell -ExecutionPolicy Bypass -File tools\inventaire-pc.ps1 > inventaire.txt
```
Envoie-moi ensuite le contenu de `inventaire.txt`.

## 3.7 Organisation Claude Code (dans ce repo)

```
CLAUDE.md                      règles du projet + méthode (chargé automatiquement)
MODLOG.md                      journal partagé : chaque découverte, chaque échec, chaque preuve
docs/                          analyses, architecture, CONTRACT.md (quand il y aura un pont)
.claude/agents/
  reverse-engineering.md       agent RE : moteur, formats, binaires, interfaces (lecture et analyse)
  game-integration.md          agent intégration : mods, ponts, gameplay
  qa-testing.md                agent QA : build, tests, logs, preuves, verdict honnête
tools/                         scripts (inventaire, faux pairs, oracles)
```
Les trois agents partagent `MODLOG.md` et `docs/`. Une découverte qui n'est pas écrite n'existe pas.
