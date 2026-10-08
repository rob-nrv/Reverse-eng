# 4. Choisir le premier projet

## Critères

1. **Jouable rapidement :** un premier prototype en quelques jours, pas en quelques mois.
2. **Testable sur ta machine :** le vrai jeu doit servir d'oracle.
3. **Dans nos règles :** jeux possédés, hors ligne ou serveur privé, aucun anti-cheat touché, rien de
   redistribué.
4. **Réutilise l'open source existant** (SkyCraft, l'exemple GTA V, Fabric…).
5. **Lié à ce que tu veux vraiment :** Minecraft, l'univers CoD, le skate, jouer avec tes amis.

## Jeux exclus d'office

| Jeu | Pourquoi |
|---|---|
| CoD récents (MWIII, BO6, BO7, Warzone) | anti-cheat noyau Ricochet, en ligne |
| skate. (EA, 2025) | en ligne uniquement, avec anti-cheat |
| GTA Online | anti-cheat ; ScriptHookV le refuse de toute façon |

## Les trois approches, appliquées à ton cas

### A. Modifier directement un jeu : **mod Minecraft « Combat CoD + Skate »**
- **Quoi :** un mod Fabric (ou un plugin Paper côté serveur) qui réimplémente :
  - les armes CoD avec les vraies stats mesurées par la communauté (cadence, dégâts selon la distance,
    temps pour tuer) ;
  - la killcam en replay, les killstreaks ;
  - une planche de skate avec des figures à la souris.
- **Prérequis :** Minecraft Java, JDK 25. C'est tout.
- **Difficultés :** l'animation du skateur est limitée par Minecraft. La « sensation » se règle à la main.
- **Risques :** quasi aucun.
- **Proto jouable :** **2 à 4 jours**, jouable avec tes amis sur ton serveur.
- **Assets :** génériques ou faits sur mesure. Option plus tard : un convertisseur local qui lit **ta**
  copie d'un vieux CoD PC vers un resource pack **privé** (non partagé).

### B. Connecter deux jeux : **Minecraft × GTA V** ou **Minecraft × Skyrim**
- **Quoi :** repartir de l'exemple GTA V de universal-modder ou de SkyCraft, le faire tourner chez toi,
  puis y ajouter ta propre mécanique (par exemple les armes CoD de l'option A dans GTA ou dans Skyrim).
- **Prérequis :**
  - GTA V **Legacy** (Steam) + ScriptHookV + ReShade, **ou** Skyrim AE + SKSE ;
  - Minecraft Java ;
  - Visual Studio C++, JDK 25 ;
  - 16 Go de RAM minimum.
- **Difficultés :**
  - Les versions doivent correspondre au build près (ScriptHookV ne marche que sur les builds
    supportés).
  - Il y a deux jeux à faire tourner en même temps.
  - Ce sont des projets « early and experimental ».
- **Risques :** casser une installation (d'où les sauvegardes avant tout), le mode histoire seulement.
- **Proto jouable :** **quelques jours** pour faire tourner l'existant, puis 1 à 3 semaines pour une vraie
  fonctionnalité à toi.
- **Limite :** en solo, ou avec des amis qui possèdent et lancent les deux jeux.

### C. Réimplémenter une mécanique ailleurs : **la physique du skate**
- **Version légère** :
  - réimplémenter le skate (élan, ollie, flip, grind) comme une simulation pure, mesurée et réglée ;
  - le brancher dans Minecraft (voir A), puis dans un autre hôte.
  - Proto en **1 à 2 semaines**.
- **Version lourde** :
  - repartir de SK8-ENGINE, qui lit les données de **ta** copie Xbox 360 de Skate 3 ;
  - il faut alors posséder le disque, le dumper toi-même, et travailler en Rust.
  - Des **mois**, avec beaucoup d'incertitude.

## Ma recommandation

**Étape 1 : l'option A** (le mod Minecraft « Combat CoD + Skate »). Elle répond à ton envie de départ,
elle se teste immédiatement, elle se joue avec tes amis, et elle t'apprend :
- les Mixins et les hooks ;
- la simulation séparée de l'hôte ;
- la conversion de coordonnées ;
- les oracles.

Ce sont exactement les briques de base d'un mashup.

**Étape 2 : l'option B**, en réutilisant le travail de l'étape 1. Par exemple, sortir les armes et le skate
de Minecraft vers GTA V ou Skyrim, via le passthrough existant. C'est là qu'on fera de la vraie
rétro-ingénierie : RenderDoc, Ghidra, CommonLib.

## Ce qu'il me faut de toi pour trancher

1. Le résultat de `tools/inventaire-pc.ps1`.
2. Tes jeux et leurs plateformes : as-tu GTA V (Steam, Legacy ?), Skyrim AE, un vieux CoD PC (WaW,
   MW2 2009), Skate 3 (Xbox 360 / PS3) ?
3. Le temps que tu veux y mettre, et si le serveur entre amis reste prioritaire.
