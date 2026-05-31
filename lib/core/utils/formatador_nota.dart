import 'package:flutter/services.dart';

import '../../models/tipo_prova.dart';

class FormatadorNotaEnem extends TextInputFormatter {
  static const int maxValor = 200;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return const TextEditingValue();
    }
    final apenasDigitos = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (apenasDigitos.isEmpty) {
      return const TextEditingValue();
    }
    final valor = int.tryParse(apenasDigitos);
    if (valor == null) return oldValue;
    if (valor > maxValor) return oldValue;
    return TextEditingValue(
      text: apenasDigitos,
      selection: TextSelection.collapsed(offset: apenasDigitos.length),
    );
  }
}

class FormatadorNotaAcafe extends TextInputFormatter {
  static const int maxValorInterno = 25;

  static const TextEditingValue _vazio = TextEditingValue(
    text: '0,0',
    selection: TextSelection.collapsed(offset: 3),
  );

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final apenasDigitos = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (apenasDigitos.isEmpty) {
      return _vazio;
    }
    final valor = int.tryParse(apenasDigitos);
    if (valor == null) return oldValue;
    if (valor > maxValorInterno) return oldValue;
    final inteiro = valor ~/ 10;
    final decimal = valor % 10;
    final texto = '$inteiro,$decimal';
    return TextEditingValue(
      text: texto,
      selection: TextSelection.collapsed(offset: texto.length),
    );
  }

  static String formatarValor(double valor) {
    return valor.toStringAsFixed(1).replaceAll('.', ',');
  }

  static String valorInicial() => '0,0';
}

class FormatadoresNota {
  FormatadoresNota._();

  static TextInputFormatter para(TipoProva tipo) {
    return tipo == TipoProva.enem ? FormatadorNotaEnem() : FormatadorNotaAcafe();
  }

  static String valorInicial(TipoProva tipo) {
    return tipo == TipoProva.enem ? '' : FormatadorNotaAcafe.valorInicial();
  }

  static String formatarValor(double valor, TipoProva tipo) {
    if (tipo == TipoProva.enem) return valor.toStringAsFixed(0);
    return FormatadorNotaAcafe.formatarValor(valor);
  }
}
