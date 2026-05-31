import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class ServicoStorage {
  final FirebaseStorage _storage;

  ServicoStorage({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  Future<String> _uploadArquivo(String caminhoLocal, String caminhoStorage) async {
    final arquivo = File(caminhoLocal);
    final ref = _storage.ref(caminhoStorage);
    final tarefa = await ref.putFile(
      arquivo,
      SettableMetadata(contentType: 'image/jpeg'),
    );
    return tarefa.ref.getDownloadURL();
  }

  Future<String> uploadFotoPerfil({
    required String usuarioId,
    required String caminhoLocal,
  }) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return _uploadArquivo(
      caminhoLocal,
      'profile_photos/$usuarioId/$timestamp.jpg',
    );
  }

  Future<String> uploadFotoRedacao({
    required String usuarioId,
    required String redacaoId,
    required String caminhoLocal,
  }) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return _uploadArquivo(
      caminhoLocal,
      'essays/$usuarioId/$redacaoId/$timestamp.jpg',
    );
  }

  Future<String> uploadFotoCorrecao({
    required String correcaoId,
    required String caminhoLocal,
  }) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return _uploadArquivo(
      caminhoLocal,
      'corrections/$correcaoId/$timestamp.jpg',
    );
  }
}
