# Reverse-eng : laboratoire de modding et de mashups de jeux

Ce dépôt sert à expérimenter le modding et la rétro-ingénierie de jeux assistés par IA (mods natifs,
mashups entre jeux, réimplémentations de mécaniques), en suivant la méthode de
[universal-modder](https://github.com/rehan-remade/universal-modder).

L'utilisateur parle français : réponses, docs et journal en français.

## Règles non négociables
- **Uniquement** des jeux possédés légalement, hors ligne, sur des serveurs privés que l'utilisateur
  contrôle, ou des projets open source.
- **Jamais** de client en ligne protégé par un anti-cheat (CoD récents, Warzone, skate. d'EA, GTA Online…).
  Pas de contournement de DRM, d'anti-cheat ni de vérification de licence. Pas de triche contre d'autres
  joueurs.
- **Ne jamais committer** de fichiers de jeu, d'assets extraits, de code décompilé, ni d'offsets retail
  copiés d'un décompilateur.
  - Les décompilations vont **hors du dépôt** (par exemple `~/<jeu>-decomp/`).
  - Les assets d'un jeu sont lus ou convertis depuis l'installation de l'utilisateur, en local.
- **Sauvegarder** les sauvegardes et les configs du jeu avant tout lancement moddé (`um backup create`).
- **Demander l'accord** avant :
  - d'installer un loader dans un dossier de jeu ;
  - de toucher au registre ;
  - de piloter la souris ou le clavier ;
  - d'installer un outil ou un MCP tiers ;
  - de publier quoi que ce soit.
- Arrêter un processus par son **PID exact**, jamais par motif de nom.
- Code tiers : vérifier sa provenance (dépôt, licence, activité) et **épingler une version ou un commit**
  avant de l'utiliser.

## Méthode (boucle de mod-any-game)
1. Intake.
2. Recon (`um scan`, base de connaissances).
3. Route la moins chère.
4. Labo (sauvegardes).
5. Lire la source de vérité.
6. Tranche verticale minimale.
7. Assets.
8. Vérifier dans le vrai jeu.
9. Packaging.
10. Note de terrain.

## Preuves
- Une fonctionnalité n'est « faite » qu'avec une **preuve** : un build qui compile, un test qui passe, ou
  un log et une capture du **vrai jeu**.
- Toujours étiqueter le niveau de preuve : *déclaré*, *code lu*, *test synthétique*, *vérifié en jeu*
  (voir `docs/01-analyse-des-projets.md`).
- Coupe-circuit : 3 échecs identiques → arrêter, écrire ce qu'on sait dans le journal, changer d'approche
  ou demander.

## Mémoire partagée entre agents
- `MODLOG.md` : le journal chronologique. Chaque découverte (chemins, versions, noms, formats), chaque
  échec et sa cause, chaque preuve, et la prochaine étape. **Ce qui n'est pas dans le journal est perdu.**
- `docs/` :
  - les analyses ;
  - l'architecture ;
  - `docs/CONTRACT.md` dès qu'un pont entre deux processus existe (qui fait autorité, unités et axes,
    canaux, version, cycle de vie).
- Agents spécialisés dans `.claude/agents/` : `reverse-engineering`, `game-integration`, `qa-testing`.

## Environnement
- Cette session cloud tourne sous Linux : **elle ne peut pas lancer les jeux Windows**. La vérification
  en jeu se fait sur le PC de l'utilisateur, avec Claude Code installé localement.
- Les dépôts de référence lus pour l'analyse (non vendorisés) :
  - universal-modder @ `8370faa` ;
  - SkyCraft @ `bfcaf17`.
