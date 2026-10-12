# firebase/
Copy here from the Backend Architecture package:
- firestore.rules
- firestore.indexes.json
- firebase.json

Deploy (from this folder): `firebase use --add` then `firebase deploy --only firestore`
Cloud Functions go in `firebase/functions/` (`firebase init functions`, TypeScript).
Owner: A (rules), B/C (their own functions, one file per function).
