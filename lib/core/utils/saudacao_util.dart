class SaudacaoUtil {
  SaudacaoUtil._();

  static String porHora(DateTime agora) {
    final hora = agora.hour;
    if (hora >= 5 && hora < 12) return 'Bom dia';
    if (hora >= 12 && hora < 18) return 'Boa tarde';
    return 'Boa noite';
  }

  static String iniciaisDoNome(String nomeCompleto) {
    final partes = nomeCompleto.trim().split(RegExp(r'\s+'));
    if (partes.isEmpty || partes.first.isEmpty) return '?';
    final primeira = partes.first[0].toUpperCase();
    if (partes.length == 1) return primeira;
    final ultima = partes.last[0].toUpperCase();
    return '$primeira$ultima';
  }
}
