# MODLOG : journal du projet

Chaque entrée contient : date, agent, ce qui a été fait, preuves (niveau), prochaine étape.

---

## 2026-10-08 : démarrage, analyse et environnement (session cloud)

**Fait**
- Lecture de trois projets (sources clonées, rien d'exécuté) :
  - universal-modder @ `8370faa8e114baf33acdb23079aff552a7728c4b` (MIT) ;
  - SkyCraft @ `bfcaf178524b92c2cdeb88e4ce0f13ef9ded6f32` (MIT) ;
  - l'exemple `examples/minecraft-gta5-passthrough`.
- 2010-rust-rewrite-mashup : **accès refusé** par le garde-fou de la session. Analysé seulement à travers
  les notes de la base universal-modder (seconde main).
- Inventaire du conteneur cloud :
  - présents : Rust 1.97, gcc/clang, cmake, Python 3.13 + uv, Node 22, Java 21, Docker ;
  - absents : Ghidra, ILSpy, .NET, Blender, RenderDoc, Wine ;
  - réseau : maven.fabricmc.net, repo.papermc.io et download.blender.org bloqués.
- Docs : `docs/01` à `docs/04`. `CLAUDE.md` et les trois agents dans `.claude/agents/`.

**Preuves :** *code lu* uniquement. Aucune fonctionnalité des projets n'a été vérifiée en jeu par nous.

**Bloquants / inconnus**
- Les jeux réellement possédés par l'utilisateur, et sur quelle plateforme.
- La configuration de son PC (Windows ? GPU ? RAM ?).
- Le conteneur cloud ne peut pas lancer de jeu Windows : il faut Claude Code en local pour l'oracle en
  jeu.

**Prochaine étape**
1. L'utilisateur lance `tools/inventaire-pc.ps1` et envoie le résultat.
2. Choix du premier projet (recommandation : option A, le mod Minecraft « Combat CoD + Skate »).
3. Ensuite, l'option B (passthrough).
