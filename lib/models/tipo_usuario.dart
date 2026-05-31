enum TipoUsuario {
  aluno('student'),
  professor('teacher');

  final String valor;
  const TipoUsuario(this.valor);

  static TipoUsuario porValor(String? valor) {
    return TipoUsuario.values.firstWhere(
      (e) => e.valor == valor,
      orElse: () => TipoUsuario.aluno,
    );
  }

  String get rotulo => switch (this) {
        TipoUsuario.aluno => 'Aluno',
        TipoUsuario.professor => 'Professor',
      };
}
