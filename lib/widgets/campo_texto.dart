import 'package:flutter/material.dart';

class CampoTexto extends StatelessWidget {
  final TextEditingController controlador;
  final String rotulo;
  final IconData? icone;
  final TextInputType? tipoTeclado;
  final TextInputAction? acaoTeclado;
  final FormFieldValidator<String>? validador;
  final void Function(String)? aoSubmeter;
  final bool habilitado;
  final int? linhasMaximas;

  const CampoTexto({
    super.key,
    required this.controlador,
    required this.rotulo,
    this.icone,
    this.tipoTeclado,
    this.acaoTeclado,
    this.validador,
    this.aoSubmeter,
    this.habilitado = true,
    this.linhasMaximas = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controlador,
      decoration: InputDecoration(
        labelText: rotulo,
        prefixIcon: icone != null ? Icon(icone) : null,
      ),
      keyboardType: tipoTeclado,
      textInputAction: acaoTeclado,
      validator: validador,
      onFieldSubmitted: aoSubmeter,
      enabled: habilitado,
      maxLines: linhasMaximas,
    );
  }
}
