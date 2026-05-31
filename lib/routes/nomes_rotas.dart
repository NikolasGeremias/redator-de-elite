class NomesRotas {
  NomesRotas._();

  static const String login = '/login';
  static const String cadastro = '/cadastro';
  static const String home = '/';
  static const String redacoes = '/redacoes';
  static const String novaRedacao = '/redacoes/nova';
  static const String detalhesRedacao = '/redacoes/:id';
  static const String editarRedacao = '/redacoes/:id/editar';
  static const String corrigirRedacao = '/redacoes/:id/corrigir';
  static const String conta = '/conta';

  static String parametroDetalhesRedacao(String id) => '/redacoes/$id';
  static String parametroEditarRedacao(String id) => '/redacoes/$id/editar';
  static String parametroCorrigirRedacao(String id) =>
      '/redacoes/$id/corrigir';
}
