import 'package:flutter/material.dart';

class CampoSenha extends StatefulWidget {
  final TextEditingController controlador;
  final String rotulo;
  final FormFieldValidator<String>? validador;
  final TextInputAction? acaoTeclado;
  final void Function(String)? aoMudar;
  final void Function(String)? aoSubmeter;

  const CampoSenha({
    super.key,
    required this.controlador,
    this.rotulo = 'Senha',
    this.validador,
    this.acaoTeclado,
    this.aoMudar,
    this.aoSubmeter,
  });

  @override
  State<CampoSenha> createState() => _CampoSenhaState();
}

class _CampoSenhaState extends State<CampoSenha> {
  bool _oculta = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controlador,
      obscureText: _oculta,
      decoration: InputDecoration(
        labelText: widget.rotulo,
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(_oculta ? Icons.visibility : Icons.visibility_off),
          onPressed: () => setState(() => _oculta = !_oculta),
        ),
      ),
      validator: widget.validador,
      textInputAction: widget.acaoTeclado,
      onChanged: widget.aoMudar,
      onFieldSubmitted: widget.aoSubmeter,
    );
  }
}
