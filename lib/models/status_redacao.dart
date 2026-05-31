enum StatusRedacao {
  rascunho('draft'),
  enviada('submitted'),
  corrigida('corrected');

  final String valor;
  const StatusRedacao(this.valor);

  static StatusRedacao porValor(String? valor) {
    return StatusRedacao.values.firstWhere(
      (e) => e.valor == valor,
      orElse: () => StatusRedacao.rascunho,
    );
  }

  String get rotulo => switch (this) {
        StatusRedacao.rascunho => 'Rascunho',
        StatusRedacao.enviada => 'Enviada',
        StatusRedacao.corrigida => 'Corrigida',
      };
}
