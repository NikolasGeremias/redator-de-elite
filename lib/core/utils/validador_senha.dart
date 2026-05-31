enum NivelForcaSenha { vazia, fraca, media, boa, forte }

class ValidadorSenha {
  ValidadorSenha._();

  static bool temTamanhoMinimo(String senha) => senha.length >= 8;
  static bool temLetra(String senha) => RegExp(r'[A-Za-z]').hasMatch(senha);
  static bool temNumero(String senha) => RegExp(r'\d').hasMatch(senha);
  static bool temEspecial(String senha) =>
      RegExp(r'[!@#\$%\^&\*\(\)_\+\-=\[\]\{\};:"\\|,.<>\/?~`]').hasMatch(senha);

  static bool ehValida(String senha) {
    return temTamanhoMinimo(senha) &&
        temLetra(senha) &&
        temNumero(senha) &&
        temEspecial(senha);
  }

  static NivelForcaSenha avaliarForca(String senha) {
    if (senha.isEmpty) return NivelForcaSenha.vazia;
    int pontos = 0;
    if (temTamanhoMinimo(senha)) pontos++;
    if (temLetra(senha)) pontos++;
    if (temNumero(senha)) pontos++;
    if (temEspecial(senha)) pontos++;
    if (senha.length >= 12) pontos++;
    switch (pontos) {
      case 0:
      case 1:
        return NivelForcaSenha.fraca;
      case 2:
        return NivelForcaSenha.media;
      case 3:
        return NivelForcaSenha.boa;
      default:
        return NivelForcaSenha.forte;
    }
  }
}
