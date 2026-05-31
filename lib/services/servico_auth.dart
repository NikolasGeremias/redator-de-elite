import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class ServicoAuth {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  ServicoAuth({FirebaseAuth? auth, GoogleSignIn? googleSignIn})
      : _auth = auth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  FirebaseAuth get auth => _auth;
  GoogleSignIn get googleSignIn => _googleSignIn;
  User? get usuarioAtual => _auth.currentUser;
  Stream<User?> get mudancasEstado => _auth.authStateChanges();

  Future<UserCredential> entrarComEmailSenha(
    String email,
    String senha,
  ) async {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: senha,
    );
  }

  Future<UserCredential> criarConta(String email, String senha) async {
    return _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: senha,
    );
  }

  Future<UserCredential?> entrarComGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;
    final googleAuth = await googleUser.authentication;
    final credencial = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    return _auth.signInWithCredential(credencial);
  }

  Future<void> sair() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  Future<void> enviarRedefinicaoSenha(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }
}
