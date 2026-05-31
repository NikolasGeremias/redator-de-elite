import 'package:flutter/material.dart';

class Carregando extends StatelessWidget {
  final String? mensagem;

  const Carregando({super.key, this.mensagem});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          if (mensagem != null) ...[
            const SizedBox(height: 12),
            Text(mensagem!),
          ],
        ],
      ),
    );
  }
}
