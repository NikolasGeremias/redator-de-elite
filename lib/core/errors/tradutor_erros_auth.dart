import 'package:firebase_auth/firebase_auth.dart';

class TradutorErrosAuth {
  TradutorErrosAuth._();

  static String traduzir(Object erro) {
    if (erro is FirebaseAuthException) {
      switch (erro.code) {
        case 'invalid-email':
          return 'E-mail inválido.';
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          return 'E-mail ou senha incorretos.';
        case 'user-disabled':
          return 'Usuário desativado.';
        case 'email-already-in-use':
          return 'Este e-mail já está cadastrado.';
        case 'weak-password':
          return 'Senha muito fraca.';
        case 'network-request-failed':
          return 'Falha de conexão com a internet.';
        case 'too-many-requests':
          return 'Muitas tentativas. Tente novamente mais tarde.';
        case 'operation-not-allowed':
          return 'Método de login não habilitado.';
        case 'requires-recent-login':
          return 'Esta operação exige login recente. Faça login de novo.';
        default:
          return erro.message ?? 'Erro de autenticação.';
      }
    }
    return 'Ocorreu um erro inesperado.';
  }
}
