import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

enum CozyAccountType { guest, google, email }

class CozyAccount {
  const CozyAccount({
    required this.uid,
    required this.type,
    this.email,
    this.displayName,
  });

  final String uid;
  final CozyAccountType type;
  final String? email;
  final String? displayName;

  bool get isGuest => type == CozyAccountType.guest;
}

abstract interface class AccountService {
  CozyAccount? get currentAccount;

  Future<CozyAccount> ensureGuest();
  Future<CozyAccount> continueWithGoogle();
  Future<CozyAccount> createEmailAccount(String email, String password);
  Future<CozyAccount> signInWithEmail(String email, String password);
  Future<void> sendPasswordReset(String email);
  Future<CozyAccount> signOutToGuest();
  Future<void> reauthenticate({String? password});
  Future<void> deleteCurrentAccount();
}

class FirebaseAccountService implements AccountService {
  FirebaseAccountService({FirebaseAuth? auth, GoogleSignIn? googleSignIn})
    : _auth = auth ?? FirebaseAuth.instance,
      _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  bool _googleInitialized = false;

  @override
  CozyAccount? get currentAccount {
    final user = _auth.currentUser;
    return user == null ? null : _accountFrom(user);
  }

  @override
  Future<CozyAccount> ensureGuest() async {
    final current = _auth.currentUser;
    if (current != null) return _accountFrom(current);
    final credential = await _auth.signInAnonymously();
    return _accountFrom(credential.user!);
  }

  @override
  Future<CozyAccount> continueWithGoogle() async {
    final credential = await _googleCredential();
    final current = _auth.currentUser;
    UserCredential result;
    if (current?.isAnonymous ?? false) {
      try {
        result = await current!.linkWithCredential(credential);
      } on FirebaseAuthException catch (error) {
        if (error.code != 'credential-already-in-use' &&
            error.code != 'provider-already-linked') {
          rethrow;
        }
        result = await _auth.signInWithCredential(credential);
      }
    } else {
      result = await _auth.signInWithCredential(credential);
    }
    return _accountFrom(result.user!);
  }

  @override
  Future<CozyAccount> createEmailAccount(String email, String password) async {
    final credential = EmailAuthProvider.credential(
      email: email.trim(),
      password: password,
    );
    final current = _auth.currentUser;
    final result = current?.isAnonymous ?? false
        ? await current!.linkWithCredential(credential)
        : await _auth.createUserWithEmailAndPassword(
            email: email.trim(),
            password: password,
          );
    await result.user?.sendEmailVerification();
    return _accountFrom(result.user!);
  }

  @override
  Future<CozyAccount> signInWithEmail(String email, String password) async {
    final result = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    return _accountFrom(result.user!);
  }

  @override
  Future<void> sendPasswordReset(String email) =>
      _auth.sendPasswordResetEmail(email: email.trim());

  @override
  Future<CozyAccount> signOutToGuest() async {
    await _auth.signOut();
    try {
      await _ensureGoogleInitialized();
      await _googleSignIn.signOut();
    } catch (_) {
      // A missing native Google session must not prevent guest fallback.
    }
    return ensureGuest();
  }

  @override
  Future<void> reauthenticate({String? password}) async {
    final user = _auth.currentUser;
    if (user == null || user.isAnonymous) return;
    if (user.providerData.any(
      (provider) => provider.providerId == 'google.com',
    )) {
      await user.reauthenticateWithCredential(await _googleCredential());
      return;
    }
    final email = user.email;
    if (email == null || password == null || password.isEmpty) {
      throw FirebaseAuthException(
        code: 'password-required',
        message: 'Please enter your password to delete this account.',
      );
    }
    await user.reauthenticateWithCredential(
      EmailAuthProvider.credential(email: email, password: password),
    );
  }

  @override
  Future<void> deleteCurrentAccount() async {
    await _auth.currentUser?.delete();
  }

  Future<AuthCredential> _googleCredential() async {
    await _ensureGoogleInitialized();
    final account = await _googleSignIn.authenticate();
    final authentication = account.authentication;
    return GoogleAuthProvider.credential(idToken: authentication.idToken);
  }

  Future<void> _ensureGoogleInitialized() async {
    if (!_googleInitialized) {
      await _googleSignIn.initialize();
      _googleInitialized = true;
    }
  }

  static CozyAccount _accountFrom(User user) {
    final providerIds = user.providerData.map((value) => value.providerId);
    final type = user.isAnonymous
        ? CozyAccountType.guest
        : providerIds.contains('google.com')
        ? CozyAccountType.google
        : CozyAccountType.email;
    return CozyAccount(
      uid: user.uid,
      type: type,
      email: user.email,
      displayName: user.displayName,
    );
  }
}
