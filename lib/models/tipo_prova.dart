enum TipoProva {
  enem('enem'),
  acafe('acafe');

  final String valor;
  const TipoProva(this.valor);

  static TipoProva porValor(String? valor) {
    return TipoProva.values.firstWhere(
      (e) => e.valor == valor,
      orElse: () => TipoProva.enem,
    );
  }

  String get rotulo => switch (this) {
        TipoProva.enem => 'ENEM',
        TipoProva.acafe => 'ACAFE',
      };
}
