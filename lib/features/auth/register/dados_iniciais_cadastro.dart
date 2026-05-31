class DadosIniciaisCadastro {
  final String nomeCompleto;
  final String email;
  final String? fotoUrl;
  final bool completandoAuth;

  const DadosIniciaisCadastro({
    this.nomeCompleto = '',
    this.email = '',
    this.fotoUrl,
    this.completandoAuth = false,
  });
}
