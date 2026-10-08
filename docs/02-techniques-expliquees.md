# 2. Les techniques, expliquées simplement

Ce document sert de carte. Le détail outil par outil est dans le skill `reverse-engineering` de
universal-modder.

## 2.1 Analyser un jeu compilé : par où commencer

Un jeu installé, c'est un exécutable (le code) plus des fichiers de données (modèles, textures, sons,
maps, scripts). On ne commence **jamais** par le binaire : on commence par ce qui est déjà connu.

1. **Le moteur.** Des indices dans le dossier du jeu le trahissent :

   | Indice dans le dossier | Moteur |
   |---|---|
   | `UnityPlayer.dll` + `*_Data/Managed/Assembly-CSharp.dll` | Unity Mono, code en C#, décompilable presque en clair |
   | `GameAssembly.dll` + `global-metadata.dat` | Unity IL2CPP, code natif avec des métadonnées |
   | `*.pak` + `Engine/Binaries` | Unreal |
   | `*.bsa` / `*.ba2` + `*.esm` | Creation Engine (Bethesda) |
   | `*.ff` (FastFiles) | IW engine (Call of Duty) |
   | `.jar` | Java (Minecraft) |

   `um scan "<jeu>"` automatise cette étape.

2. **La communauté.** Pour un jeu connu, il existe presque toujours un loader (SKSE, BepInEx, UE4SS,
   ScriptHookV, Fabric), des outils de format (xEdit, FModel, AssetRipper) et des wikis. Ça représente
   des années de rétro-ingénierie déjà faites, qu'on réutilise.

3. **Le binaire, seulement s'il le faut.** On ne descend au code que pour ce que personne n'a documenté.

## 2.2 Décompilation, désassemblage : la différence

- **Désassembler**, c'est traduire le code machine en instructions assembleur, une par une (`mov`,
  `call`…). C'est fidèle mais illisible à grande échelle.
- **Décompiler**, c'est reconstruire un pseudo-code proche du C (Ghidra, IDA), ou carrément le vrai
  source pour les langages « managés » : C# avec ILSpy, Java avec Vineflower. Pour C# et Java, le
  résultat est très lisible, parce que les noms des classes et des méthodes sont conservés.
- **Pour un binaire C++ natif, on part de chaînes de caractères :**
  1. Chercher une chaîne parlante, par exemple `"Player health"`.
  2. Lister qui y fait référence (les « cross-references »).
  3. On tombe sur la fonction qui gère la vie.
  4. On la renomme, et on recommence avec la suivante.

  Petit à petit, le programme devient lisible.

**Exemple concret.** Pour trouver la fonction de dégâts d'un jeu Unity Mono :
1. Lancer `ilspycmd -p -o ~/jeu-decomp Assembly-CSharp.dll`.
2. Faire un `grep -rn "TakeDamage"`.
3. On obtient la classe, ses champs et la formule exacte, en clair.

Pour IL2CPP, c'est Cpp2IL qui donne les noms, puis Ghidra pour lire le corps des fonctions.

## 2.3 Retrouver la physique, la caméra, l'inventaire… sans le code source

On combine trois sources :

| Source | Outil | Exemple |
|---|---|---|
| **Statique** (on lit) | Ghidra, ILSpy, dumpers Unreal | « la vitesse de sprint vaut 1.3 × la marche » |
| **Dynamique** (on observe le jeu en marche) | Cheat Engine, x64dbg, Frida | on cherche la valeur « vie = 100 », on prend un coup, on cherche 75. Ça donne l'adresse, puis la structure du joueur. |
| **Graphique** | RenderDoc | une capture d'une frame montre chaque appel de dessin, la matrice de caméra et le tampon de profondeur. C'est ce qu'il faut pour incruster un jeu dans un autre. |

**La règle d'or : un oracle.** On enregistre une trace du vrai jeu (positions et vitesses à chaque tick),
puis on la rejoue contre sa réimplémentation. Dans l'exemple Terraria, la vitesse de l'Œil de Cthulhu
correspondait à 99,9 % une fois deux détails corrigés : un décalage d'une frame et une constante `0.2f` au
lieu de `0.2`. Lire le code ne suffit pas, il faut **mesurer**.

## 2.4 Les trois façons de modifier un jeu

| Façon | Principe | Exemple |
|---|---|---|
| **Mod natif / plugin** | On utilise l'API du jeu ou d'un loader. | Plugin Paper, mod Fabric, plugin SKSE, script ScriptHookV |
| **Patch de code** | On intercepte une fonction du jeu (« hook ») et on change son comportement. | Mixin en Java, Harmony en C#, MinHook en C++ |
| **Réimplémentation de moteur** | On réécrit le moteur, qui lit les fichiers d'origine. | OpenMW (Morrowind), IW4L (MW2), SK8-ENGINE (Skate 3) |

## 2.5 Reconstruire une mécanique dans un autre environnement

C'est le « Pattern 1/5 » de universal-modder.
1. **Mesurer la mécanique d'origine** : wiki, données de la communauté, ou traces enregistrées.
2. **L'écrire comme une simulation pure**, sans dépendre de l'hôte, avec les mêmes unités et le même pas
   de temps.
3. **Faire le pont avec l'hôte** grâce à **une seule** fonction de conversion des coordonnées (origine,
   échelle, axes).
4. **Comparer avec l'original**, en rejouant la même trace d'entrée.

C'est la route la plus robuste : elle ne dépend d'aucun binaire, et elle survit aux mises à jour.

## 2.6 Connecter deux jeux en temps réel

| Transport | Débit / latence | Usage typique |
|---|---|---|
| **Mémoire partagée** (`CreateFileMapping`) | énorme / µs | états à chaque frame, pixels (SkyCraft, GTA V) |
| **Named pipes / UDP local** | élevé / faible | flux d'événements |
| **WebSocket / HTTP sur 127.0.0.1** | moyen / ms | contrôle, commandes, événements (GTA V : caméra et sol) |
| **Textures GPU partagées** (DXGI, Vulkan external memory) | maximal | images, mais complexe. En pratique, les projets relisent les pixels côté CPU. |

**Le « contrat » à écrire avant de coder** (`docs/CONTRACT.md`) :
- qui fait autorité sur quoi : par exemple, Minecraft pour la physique du joueur, Skyrim pour les PNJ ;
- les unités et les axes : par exemple, 1 bloc = 70 unités, Z-up vers Y-up ;
- chaque canal, et ce qui se passe s'il est plein ou en retard ;
- la version du protocole et l'ordre des octets ;
- le cycle de vie : qui crée la mémoire partagée, et le heartbeat qui détecte si un côté a planté.

## 2.7 Synchroniser positions, collisions, animations, rendu

- **Positions et caméra :** à chaque frame, avec un horodatage. On envoie la position **interpolée**, pas
  celle du tick à 20 Hz, sinon l'image saccade.
- **Collisions :**
  - l'hôte « sonde » son monde (rayons) autour du joueur ;
  - il l'envoie sous forme de boîtes ou de blocs invisibles ;
  - l'invité applique sa propre physique dessus.
- **Combat :** un proxy invisible côté invité reçoit les coups avec le calcul de dégâts natif. Le résultat
  est renvoyé et rejoué côté hôte avec ses propres animations et réactions.
- **Rendu :**
  - Le plus simple : une image incrustée par-dessus. C'est moche, il n'y a pas de profondeur.
  - Mieux : composer contre le **tampon de profondeur** de l'hôte, pour que les murs cachent les blocs.
  - Le top : dessiner la géométrie de l'invité **dans la passe de rendu de l'hôte**, pour hériter de sa
    lumière et de ses ombres (SkyCraft 0.1.2).
- **Latence :** la re-projection de l'image sur la caméra courante (GTA V) masque environ une frame de
  retard.

## 2.8 Comparaison des approches

| | A. Modifier un jeu | B. Connecter deux jeux | C. Réimplémenter une mécanique |
|---|---|---|---|
| Difficulté | faible à moyenne | élevée | moyenne (très élevée pour un moteur entier) |
| Prérequis | 1 jeu + son loader | 2 jeux, Windows, C++ et Java, beaucoup de RAM et de GPU | 1 hôte + des données de mesure |
| Fragilité | moyenne (mises à jour du jeu) | élevée (2 jeux, 2 loaders, synchronisation) | faible |
| Proto jouable | jours | semaines (en partant d'un exemple existant : jours) | jours (mécanique), mois (moteur) |
| Multijoueur entre amis | oui, si le jeu le permet | difficile : chaque joueur doit lancer les 2 jeux | oui |
