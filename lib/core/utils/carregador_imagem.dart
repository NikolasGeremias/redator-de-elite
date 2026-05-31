import 'dart:io';

import 'package:flutter/widgets.dart';

class CarregadorImagem {
  CarregadorImagem._();

  static bool ehUrlRemota(String? caminho) {
    if (caminho == null) return false;
    return caminho.startsWith('http://') || caminho.startsWith('https://');
  }

  static bool ehArquivoLocalValido(String? caminho) {
    if (caminho == null || caminho.isEmpty) return false;
    if (ehUrlRemota(caminho)) return false;
    try {
      return File(caminho).existsSync();
    } catch (_) {
      return false;
    }
  }

  static ImageProvider? imagemPara(String? caminho) {
    if (caminho == null || caminho.isEmpty) return null;
    if (ehUrlRemota(caminho)) return NetworkImage(caminho);
    if (ehArquivoLocalValido(caminho)) return FileImage(File(caminho));
    return null;
  }
}
