# Comment ce dépôt a été construit avec l'IA

Ce document explique **comment** ce dépôt a été créé, la **méthodologie**
suivie pendant la ou les sessions assistées par IA, et la répartition concrète
des **rôles** entre l'opérateur humain et l'agent IA de codage (GitHub Copilot /
Claude Sonnet 4.5 en mode agent dans VS Code). Il s'agit d'un document de
transparence pour un projet de formation, afin que toute personne relisant le
dépôt comprenne ce qui a été généré, ce qui a été décidé par un humain, et ce
qui doit encore être relu.

## Point de départ

Le dépôt était quasiment vide au départ : un `README.md` avec deux liens (le
site Swagger Petstore + sa spécification OpenAPI) et un dossier `swagger/`
vide, ainsi qu'un environnement virtuel Python 3.14 déjà présent (`.venv`,
`.python-version`) mais sans aucun package installé. Il n'y avait aucun code
Robot Framework, aucun manifeste de dépendances, et deux fichiers
d'instructions vides sous `.github/instructions/`.

## Méthodologie

Le projet a été construit via un **flux de travail conversationnel et
itératif** avec l'agent IA, et non par une génération unique en une seule
fois :

1. **Exprimer l'objectif, pas l'implémentation.** L'opérateur a décrit
   l'intention (« apprendre Robot Framework en testant l'API Petstore,
   utiliser Python 3.14 déjà présent dans le venv, la dernière version
   compatible de Robot Framework, suivre les bonnes pratiques ») et a laissé
   l'agent définir l'architecture concrète.
2. **L'agent s'ancre dans la réalité avant d'écrire du code.** Avant de
   générer quoi que ce soit, l'agent a inspecté l'état réel du dépôt (fichiers
   existants, version Python du venv, packages installés) au lieu de
   supposer, et a mobilisé la **skill `robotcode`** spécifique au projet
   (fournie avec l'extension VS Code RobotCode) comme source de vérité pour
   l'outillage Robot Framework, la configuration (`robot.toml`) et les
   conventions, plutôt que de s'appuyer uniquement sur des connaissances
   génériques pré-entraînées.
3. **L'agent demande avant de prendre des décisions structurantes.** Chaque
   fois qu'un choix pouvait façonner significativement le projet (gestionnaire
   de dépendances, bibliothèque de test HTTP, installation d'outillage CLI
   supplémentaire en dépendance partagée par l'équipe), l'agent s'est arrêté
   et a posé des questions explicites à choix multiples à l'opérateur, au lieu
   de choisir silencieusement une valeur par défaut.
4. **Vérifier les faits sur les bibliothèques/mots-clés plutôt que deviner.**
   Pour les signatures des mots-clés Robot Framework (par ex. `GET On Session`,
   `Status Should Be`, `Create Session` de `RequestsLibrary`), l'agent a
   interrogé `robotcode libdoc` sur la version réellement installée de la
   bibliothèque plutôt que de se fier à sa mémoire — le même principe
   d'« ancrage factuel » appliqué de façon cohérente.
5. **Valider en continu, face à la vraie cible.** Après avoir généré la
   suite, l'agent a lancé une analyse statique (`robotcode analyze code`), la
   découverte des suites (`robotcode discover tests`), puis a réellement
   exécuté les tests contre l'API Petstore publique en ligne — ce qui a permis
   de détecter et corriger un vrai bug d'assertion et une configuration TLS
   non sécurisée par défaut, plutôt que de faire confiance au code juste parce
   qu'il « semblait correct ».
6. **L'humain relit et oriente entre les itérations.** Après la première
   génération, l'opérateur a relu le résultat dans l'éditeur, effectué de
   petites modifications manuelles ou via l'outillage (par ex. Poetry qui a
   reformaté `pyproject.toml`, un ajustement du `.gitignore`), puis a formulé
   des demandes de suivi, ciblées (compléter le fichier d'instructions,
   corriger le `.gitignore`) que l'agent a traitées en relisant d'abord le
   contenu actuel des fichiers (sans jamais supposer que ses éditions
   précédentes étaient toujours l'état le plus récent).
7. **Capitaliser sur la connaissance réutilisable, pas seulement sur le
   code.** Les conventions apparues pendant la session (architecture, schéma
   de tags, choix de sécurité) ont été consignées à la fois dans la
   documentation du projet (`README.md`,
   `.github/instructions/e2e/robot-e2e.instructions.md`) et dans la mémoire
   propre à l'agent, propre à ce dépôt, afin que les prochaines sessions sur
   ce dépôt restent cohérentes sans redériver les mêmes décisions.

## Déroulé, étape par étape

1. **Découverte.** Lecture des fichiers d'instructions vides et du
   `README.md` existant, listing de l'espace de travail, confirmation que le
   `.venv` était en Python 3.14.3 sans aucun package installé.
2. **Contrat de l'API.** L'agent avait besoin du contrat OpenAPI de Petstore
   pour concevoir des tests réalistes ; l'opérateur a fourni directement le
   fichier local `swagger/swagger.json` plutôt que de laisser l'agent le
   récupérer sur internet.
3. **Clarifier le périmètre avec l'opérateur.** Trois questions rapides à
   choix multiples ont été posées et répondues :
   - Gestion des dépendances → **Poetry**, en réutilisant le `.venv` existant
     (`poetry config virtualenvs.in-project true --local` +
     `poetry env use .venv/bin/python`).
   - Client HTTP → **RequestsLibrary** (le wrapper Robot Framework standard de
     la communauté autour de `requests`), plutôt que l'alternative plus
     « boîte noire » pilotée par OpenAPI, afin de préserver la valeur
     pédagogique de l'écriture manuelle des mots-clés.
   - Outillage → installer **`robotcode[runner,analyze,repl]`** en dépendance
     de développement Poetry afin que toute l'équipe dispose du CLI utilisé
     pour exécuter, déboguer et analyser statiquement la suite.
4. **Générer l'architecture** (voir `README.md` → _Project layout_ pour
   l'arborescence actuelle) : `robot.toml` pour la configuration/les profils,
   `tests/__init__.robot` pour une session HTTP unique et partagée
   (`Suite Setup`/`Suite Teardown`), une suite de tests par tag Swagger
   (`pet.robot`, `store.robot`, `user.robot`), et un fichier
   `resources/*_keywords.resource` par ressource d'API encapsulant les appels
   HTTP et la construction des payloads (avec des identifiants/noms
   d'utilisateur aléatoires pour éviter les collisions sur le serveur de
   démonstration public partagé).
5. **Valider face à la réalité.**
   - `robotcode analyze code` → détection et correction d'un import de
     bibliothèque dupliqué.
   - `robotcode robot` (exécution complète contre
     `https://petstore.swagger.io/v2`) → 15/16 tests passés ; un vrai bug
     découvert (assertion sur l'ensemble de la réponse JSON de login au lieu
     de son champ `message`) puis corrigé et re-vérifié.
   - Constat que `RequestsLibrary` a `verify=False` par défaut ; le mot-clé de
     session partagé a été modifié en `verify=${True}` pour que les
     certificats TLS soient réellement vérifiés (une correction pertinente au
     regard d'OWASP, pas un simple choix de style).
6. **Documentation et rangement.**
   - Rédaction des sections _Project layout_, _Setup_ et _Running the tests_
     du `README.md`.
   - Remplissage de `.github/instructions/e2e/robot-e2e.instructions.md` avec
     les conventions concrètes suivies par la suite (outillage via
     `robotcode`, séparation tests/resources, règles de conception des
     mots-clés, patterns d'assertion, tagging, règles de sécurité/hygiène)
     afin que l'agent comme les contributeurs humains disposent d'une source
     de vérité unique pour les futurs changements.
   - Détection et suppression de `log.html` / `output.xml` / `report.html`
     qui avaient été accidentellement commités à la racine du dépôt (produits
     par une invocation `robot` brute qui ignore le `output-dir` de
     `robot.toml`), et correction de l'extrait du README qui suggérait cette
     commande.
   - Resserrement d'un motif `.gitignore` trop large (`*.html` / `*.xml`,
     ajouté par une modification externe) en le remplaçant par les noms
     précis des artefacts Robot Framework, afin que de futurs fichiers
     HTML/XML sans rapport ne soient pas ignorés silencieusement.

## Qui a fait quoi

| Responsabilité                                                                                                      | Opérateur humain | Agent IA                                          |
| ------------------------------------------------------------------------------------------------------------------- | ---------------- | ------------------------------------------------- |
| Définir l'objectif et les contraintes (apprendre RF, tester l'API Petstore, Python 3.14, « bonnes pratiques »)      | ✅               |                                                   |
| Choisir le gestionnaire de dépendances, la bibliothèque HTTP, le périmètre de l'outillage                           | ✅ (a décidé)    | ✅ (a posé la question, a présenté les compromis) |
| Explorer l'état du dépôt/de l'environnement avant d'agir                                                            |                  | ✅                                                |
| Concevoir l'architecture de test (découpage suites/resources, cycle de vie de la session, tagging)                  |                  | ✅ (proposée et implémentée)                      |
| Vérifier les signatures des mots-clés via la bibliothèque installée (`libdoc`) plutôt que deviner                   |                  | ✅                                                |
| Écrire tous les fichiers `.robot` / `.resource` / `robot.toml` / de configuration                                   |                  | ✅                                                |
| Exécuter la suite contre l'API réelle et corriger les échecs/défauts de sécurité constatés                          |                  | ✅                                                |
| Relire les fichiers générés, déclencher des demandes de suivi/d'affinage                                            | ✅               |                                                   |
| Fournir la spécification OpenAPI utilisée pour concevoir les tests                                                  | ✅               |                                                   |
| Maintenir la documentation (`README.md`, fichier d'instructions, ce fichier) synchronisée avec l'état réel du dépôt |                  | ✅ (sur demande)                                  |

## Ce qu'il faut garder à l'esprit

Cette suite a été générée par un agent IA et **validée en l'exécutant
réellement contre l'API de démonstration Petstore en ligne** — ce n'est pas du
code spéculatif. Cela dit, comme pour toute contribution assistée par IA, un
humain devrait continuer à relire les futurs changements Robot Framework
(par ex. via `robotcode analyze code` et une exécution réelle des tests) avant
de leur faire confiance, car le comportement de l'API de démonstration sur les
cas limites (identifiants invalides, erreurs de validation) ne correspond pas
toujours exactement à ce que la spécification Swagger promet formellement.
