# dev/
Developer-only tools. Not shown to real users.

- dev_menu_view.dart : list of every screen (owner: A)
- dev_login_view.dart : your existing test login (keep ONE copy, owner: A)
- Want to run only your module? Create lib/dev/main_<yourmodule>.dart
  and run: flutter run -t lib/dev/main_<yourmodule>.dart
  (one file per person, so nobody edits the same file)
