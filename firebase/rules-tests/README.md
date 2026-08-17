# Firestore rules tests

Requirements: Firebase CLI, Node.js and Java 21+.

From this directory, run:

```bash
firebase emulators:exec --only firestore "npm test"
```

If a packaged Firebase CLI shadows the system Node binary on macOS, replace
`npm test` with the absolute Node path, for example:

```bash
firebase emulators:exec --only firestore \
  "/opt/homebrew/bin/node --test test/firestore.rules.test.cjs"
```
