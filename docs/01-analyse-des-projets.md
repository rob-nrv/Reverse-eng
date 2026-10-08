# 1. Analyse des projets existants

Analyse faite le 2026-10-08. Les dépôts ont été clonés et lus. **Aucun n'a été exécuté** : ils demandent
Windows et les jeux eux-mêmes, alors que cette analyse tourne dans un conteneur Linux.

## Niveaux de preuve utilisés ici

Tout ce qui est écrit dans ce document porte l'un de ces niveaux (repris de
`knowledge/techniques/evidence-levels-for-mashup-claims.md` dans universal-modder) :

| Niveau | Signification |
|---|---|
| **Déclaré** | Le créateur dit que ça marche (README, vidéo, post). |
| **Code lu** | J'ai lu le code ou la doc, sans rien exécuter. |
| **Test synthétique** | Un test ou un faux jeu a tourné. |
| **Vérifié en jeu** | Le vrai jeu a tourné avec ce build et quelqu'un a regardé le résultat. |

Pour ces trois projets, je n'ai pu atteindre que les niveaux **Déclaré** et **Code lu**.

---

## A. universal-modder (rehan-remade)

- **Provenance :** MIT ; dernier commit le 2026-10-07 (Selene Bray-Hernandez) ; projet actif.
- **Nature :** ce n'est pas un mod. C'est une **boîte à outils pour agents IA** (Claude Code, Codex, Cursor…).
  Elle contient :
  - 11 **skills** : mod-any-game, game-recon, reverse-engineering, mashup-mods, asset-pipeline, fal-assets,
    game-automation, showcase-video, publish-mod, share-field-notes, game-research-websearch ;
  - une **CLI Python `um`** :
    - `scan` : jeux installés, moteur, anti-cheat, loaders ;
    - `backup` : snapshots des sauvegardes ;
    - `win` : lancer, capturer, piloter un jeu Windows ;
    - `fal` / `comfy` : génération d'assets ;
    - `render3d` / `sprite` : conversion d'assets ;
    - `video` : montage ;
    - `publish check` : lint anti-fuite de fichiers propriétaires ;
    - `kb` : base de connaissances ;
  - une **base de connaissances** : ~40 jeux et une dizaine de notes de technique, écrites par des agents
    pour des agents.
- **Méthode** (skill `mod-any-game`), une boucle en 10 étapes :
  1. Intake.
  2. Recon (moteur, anti-cheat, loaders).
  3. **Choix de la route la moins chère.**
  4. Labo (sauvegardes).
  5. **Lire la source de vérité** (décompilation, dumps, mémoire live).
  6. Tranche verticale minimale.
  7. Assets.
  8. **Vérifier dans le vrai jeu** (oracle).
  9. Vidéo et packaging.
  10. Note de terrain.
- **Règles intégrées** (identiques aux nôtres) :
  - pas de client en ligne avec anti-cheat ;
  - pas de contournement de DRM ;
  - aucun fichier de jeu ni code décompilé dans un dépôt ;
  - sauvegardes avant tout lancement moddé ;
  - demander l'accord avant d'installer un loader ou de piloter la souris.
- **Ce qui est réellement prouvé :** le code des exemples et la CLI existent (Code lu). Les trois exemples
  (Terraria, AoE2, Minecraft×GTA V) sont **déclarés** testés en jeu par leurs auteurs.
- **Point faible :** `fal` est un service payant (clé API). Il est optionnel, et on peut s'en passer.

## B. SkyCraft (chasmlol) : Minecraft × Skyrim

- **Provenance :** MIT ; dernier commit le 2026-10-01 ; ~21 600 lignes de C++ et de Java.
- **Route : passthrough**, avec les deux vrais jeux en même temps. Aucun des deux n'est réécrit (DESIGN.md §1).
- **Architecture** (code lu) :
  - **Côté Skyrim :** un plugin SKSE en C++ (CommonLibSSE-NG, vcpkg). Il contient Collision, Combat,
    Input, Link, Overlay, WorldRender, Dig*…
  - **Côté Minecraft 26.3 :** un mod Fabric en Java (Mixins), qui contient `CollisionField`,
    `ActorProxy` et `FrameExporter`.
  - **Transport :** la mémoire partagée `Local\SkyCraft_v1`, décrite dans un seul en-tête
    `protocol/skycraft_protocol.h` (v11) et recopiée côté Java.
    - Un en-tête avec magic, version, PIDs et heartbeats.
    - Des slots « dernière valeur » protégés par un seqlock (état joueur, caméra).
    - Des ring buffers pour les événements (entrées, collisions, coups).
    - Un tampon de pixels pour le rendu.
  - **Correspondance des coordonnées :** 1 bloc = 70 unités Skyrim ; Skyrim est Z-up, Minecraft est Y-up.
    - mc.x = x/70
    - mc.y = z/70
    - mc.z = −y/70
- **Qui fait autorité sur quoi :**
  - **Minecraft** : physique du joueur, inventaire, calcul des dégâts.
  - **Skyrim** : monde, PNJ, quêtes.
  - Skyrim garde un « pantin » du joueur pour que l'IA des PNJ continue de fonctionner.
- **Collision :**
  - Skyrim lance des rayons Havok autour du joueur.
  - Le résultat est découpé en boîtes de 1/8 de bloc.
  - Ces boîtes sont injectées dans les requêtes de collision de Minecraft par un Mixin.
  - La physique vanilla de Minecraft s'applique ensuite sans modification.
- **Combat :**
  - Chaque PNJ Skyrim a un `ActorProxy` invisible côté Minecraft, sur lequel le calcul de dégâts vanilla
    s'applique.
  - Le résultat est renvoyé à Skyrim (`HitActor`), qui l'applique avec ses propres réactions.
- **Rendu :**
  - Minecraft rend hors écran, avec la caméra de Skyrim, trois couches : monde, main et interface.
  - La couche monde est composée contre le tampon de profondeur de Skyrim, dans la passe de rendu même
    de Skyrim.
- **Tests présents :**
  - 2 tests unitaires Java (`SkyRayTest`, `TriColliderTest`) ;
  - des faux pairs (`tools/fake_skyrim.py`, `fake_guest.py`) ;
  - c'est du **Test synthétique** au mieux.
- **Ce qui est déclaré mais non vérifié par moi :** toute la liste « What works » du README. Le README
  dit lui-même « early and experimental ».
- **Prérequis joueur :**
  - Skyrim AE 1.6/1.7 (développé sur 1.7.104), SKSE64 et Address Library ;
  - Minecraft Java, avec un lanceur Prism portable fourni ;
  - **posséder les deux jeux.**

## C. Exemple « minecraft-gta5-passthrough » (dans universal-modder)

- **Route : passthrough avec composition d'image.**
- **Architecture** (code lu) :
  - **Côté GTA :** un script ScriptHookV (`script.cpp`) envoie à Minecraft, via WebSocket sur
    127.0.0.1:25599, la caméra de GTA, le sol autour du joueur et les touches.
  - **Côté Minecraft :** le mod Fabric reçoit ces données. Il pose des blocs barrière invisibles sur le
    sol de GTA, et rend le monde avec la caméra de GTA.
  - **Retour d'image :** Minecraft écrit chaque frame (couleur, profondeur, puis main et HUD) dans la
    mémoire partagée `Local\MCPassthroughFrame`.
  - **Composition :** un add-on ReShade (`compositor.cpp` + `MCPassthrough.fx`) compose cette image
    contre la profondeur de GTA (Z inversé). Il re-projette aussi l'image pour masquer la latence.
  - **Événements :** les explosions et projectiles de Minecraft sont rejoués comme des explosions et des
    balles dans GTA.
- **Déclaré testé :** GTA V **Legacy** sur Steam (build 3889), ScriptHookV 3889.0, ReShade 6.8.0, en
  septembre 2026. Mode histoire uniquement.
- **Tests présents :**
  - `fakehost.py`, `fakegta.cpp` : des faux GTA (**Test synthétique**) ;
  - `ws_test.cpp` : la base de connaissances note elle-même qu'il est faible (il passe si une chaîne
    contient « explosion »).
- **Leçon notée par les auteurs :** mettre les armes de GTA dans les mains de Steve n'a pas marché (la
  caméra de visée et les animations ne collent pas). Les armes de Minecraft avec des effets GTA, si.

## D. 2010 Rust Rewrite Mashup (chasmlol) : MW2 × Skate 3 × Minecraft

- **Accès au dépôt refusé dans cette session** (garde-fou de l'environnement). Ce qui suit vient
  **uniquement** des notes de la base universal-modder. C'est donc **de seconde main**.
- **Route : recréation de moteur, puis fusion.** Aucun jeu original ne tourne :
  - **IW4L** : un runtime MW2 réécrit en Rust (Bevy + wgpu) qui **lit les FastFiles de l'installation
    du joueur** et traduit les shaders D3D9 en WGSL.
  - **SK8-ENGINE** : un moteur Skate 3 réécrit en Rust, construit en comparant avec une recompilation
    statique et une base IDA. Il **lit les données Xbox 360 du joueur**.
  - **Une réimplémentation de Minecraft en Rust.**
  - **La fusion :** les trois dans un seul processus.
    - La simulation du skate prend le contrôle du soldat MW2.
    - La collision des maps MW2 alimente le monde du skate.
    - Les rails de grind sont tirés des arêtes de collision.
    - Les os du squelette du skateur sont retransférés (« retargeting ») sur celui du soldat.
- **Ce qui l'a fait marcher, selon les notes :**
  - un runtime scriptable servant d'oracle (spawn → attendre → capture → dump) ;
  - un journal de preuves par étape ;
  - un lint qui bloque toute fuite d'offsets ou de noms issus du décompilateur avant un push.
- **Prérequis :** posséder MW2 (2009) sur PC **et** Skate 3 sur Xbox 360, dumper soi-même le disque, et
  avoir une machine solide. C'est la route la plus lourde.

---

## Synthèse : les routes réellement utilisées

| Route | Exemple | Jeux qui tournent | Ce qui traverse la frontière | Difficulté |
|---|---|---|---|---|
| Porter le contenu (imiter dans l'hôte) | Bloons TD 6 dans Minecraft | l'hôte seul | rien (règles réécrites) | ★☆☆ |
| Passthrough avec composition d'image | Minecraft × GTA V | les deux | caméra, sol, événements, pixels | ★★☆ |
| Passthrough avec géométrie native | SkyCraft | les deux | collisions, acteurs, coups, maillages | ★★★ |
| Recréation de moteur + fusion | MW2 × Skate 3 × MC | aucun (moteur réécrit) | rien, un seul processus | ★★★★ |

**À retenir :**
1. Aucun projet sérieux ne copie les fichiers d'un jeu dans le mod. Les assets sont lus ou convertis
   depuis **l'installation du joueur**.
2. Tous s'appuient sur des **loaders communautaires** existants (SKSE, ScriptHookV, Fabric, ReShade) plutôt
   que d'injecter du code à la main.
3. Tous ont des **faux pairs** pour développer sans lancer les deux jeux. Mais seul le vrai jeu fait foi.
4. Les jeux visés sont **solo ou hors ligne** : GTA en mode histoire, Skyrim, MW2 réécrit. Aucun ne
   touche à un client protégé par un anti-cheat.
