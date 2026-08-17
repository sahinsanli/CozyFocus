# Cozy Focus Android signing

The private upload key lives only on this development machine:

- Keystore: `android/upload-keystore.p12`
- Credentials: `android/key.properties`
- Alias: `upload`

Both files are ignored by Git. Back them up together in an encrypted password
manager or encrypted offline volume before the first Play Console upload. Losing
the upload key is recoverable through Play Console, but keeping a secure backup
avoids the reset process.

## Upload certificate fingerprints

- SHA-1: `E4:9E:D5:D7:C9:E1:29:19:4C:85:5D:22:4E:D0:03:30:90:1A:C1:1E`
- SHA-256: `E3:FD:CB:06:F5:AE:24:77:EB:5A:F2:9E:15:F6:36:7E:1F:AA:A1:5E:90:F0:6B:5E:70:C3:2E:05:D5:2E:C2:90`

After the app is created in Play Console and Play App Signing is enabled, add
the **App signing key certificate** SHA-1 and SHA-256 values to the Firebase
Android app as well. The Play app-signing certificate is different from this
upload certificate.

## Build

```bash
flutter build appbundle --release
```

Before uploading, verify that the AAB is signed and that its package name is
`com.sahinsanli.cozyfocus`.
