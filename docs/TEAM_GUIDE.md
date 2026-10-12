# LocaLink team guide (read this once, 3 minutes)

## 1. Who owns which folder (ONLY the owner edits it)
| Person | Folders |
|---|---|
| A | lib/app, lib/core, lib/dev, lib/main.dart, features/auth, browse, assistant, safety_profile, firestore.rules |
| B | features/requests |
| C | features/provider, features/vendor |

Need a change in someone else's folder? Message them or open a PR and tag them. Never "just fix it".

## 2. Rules that remove 90% of conflicts
1. Never create a new top-level folder under lib/. Never create a second `features/<name>` that already exists.
2. A feature never imports another feature's files. Shared stuff goes to lib/core (ask A).
3. Do NOT edit lib/app/routes.dart. Add your screens in your own `features/<name>/<name>_routes.dart`.
4. Do NOT edit main.dart or pubspec.yaml without telling the team. Pull first, one package per line, alphabetical, tiny PR.
5. Screen file = `<name>_view.dart`, class = `<Name>View`, inside `features/<feature>/views/`.
6. Firebase/Supabase calls only inside `features/<feature>/data/<feature>_repository.dart`.
7. Firestore field names come from the Backend PDF section 4. Do not rename.
8. Never commit keys, env/dev.json, service-account JSON.

## 3. Daily routine
```
git checkout main
git pull
git checkout -b feature/<module>-<what>      # first time only
git merge main                               # every morning
# ...work...
git add .
git commit -m "feat(requests): finding providers screen"
git push -u origin feature/<module>-<what>
# open Pull Request on GitHub, owner reviews, Squash and merge
```
Never push directly to main. Never `git push --force`.

## 4. Conflict in VS Code
Open the file, click Accept Current / Accept Incoming / Accept Both, delete all <<<<<<< ======= >>>>>>> markers,
run `flutter analyze`, then `git add .` and `git commit`. Stuck? `git merge --abort` and ask.

## 5. Run
```
flutter pub get
flutter run --dart-define-from-file=env/dev.json
```
The app opens on the screen launcher (/dev) so you can open any screen. Set `Env.startWithDevMenu = false` in lib/core/config/env.dart for the real flow.
