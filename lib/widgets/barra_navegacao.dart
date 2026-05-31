import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class ItemBarraNavegacao {
  final IconData icone;
  final IconData iconeSelecionado;
  final String rotulo;

  const ItemBarraNavegacao({
    required this.icone,
    required this.iconeSelecionado,
    required this.rotulo,
  });
}

class BarraNavegacao extends StatelessWidget {
  final int indiceAtual;
  final ValueChanged<int> aoTocar;
  final List<ItemBarraNavegacao> itens;

  const BarraNavegacao({
    super.key,
    required this.indiceAtual,
    required this.aoTocar,
    required this.itens,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(itens.length, (i) {
              return _ItemBarra(
                item: itens[i],
                selecionado: i == indiceAtual,
                aoTocar: () => aoTocar(i),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _ItemBarra extends StatelessWidget {
  final ItemBarraNavegacao item;
  final bool selecionado;
  final VoidCallback aoTocar;

  static const Duration _duracao = Duration(milliseconds: 280);
  static const Curve _curva = Curves.easeOutCubic;

  const _ItemBarra({
    required this.item,
    required this.selecionado,
    required this.aoTocar,
  });

  @override
  Widget build(BuildContext context) {
    final corFundo = AppColors.verde.withValues(alpha: 0.18);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: aoTocar,
        child: AnimatedContainer(
          duration: _duracao,
          curve: _curva,
          padding: EdgeInsets.symmetric(
            horizontal: selecionado ? 18 : 14,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: selecionado ? corFundo : Colors.transparent,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: _duracao,
                switchInCurve: _curva,
                switchOutCurve: _curva,
                transitionBuilder: (child, animation) {
                  return ScaleTransition(
                    scale: animation,
                    child: FadeTransition(
                      opacity: animation,
                      child: child,
                    ),
                  );
                },
                child: Icon(
                  selecionado ? item.iconeSelecionado : item.icone,
                  key: ValueKey(selecionado),
                  color: selecionado
                      ? AppColors.verde
                      : AppColors.textoSuave,
                  size: 24,
                ),
              ),
              ClipRect(
                child: AnimatedAlign(
                  duration: _duracao,
                  curve: _curva,
                  alignment: Alignment.centerLeft,
                  widthFactor: selecionado ? 1.0 : 0.0,
                  heightFactor: 1.0,
                  child: AnimatedOpacity(
                    duration: _duracao,
                    curve: _curva,
                    opacity: selecionado ? 1.0 : 0.0,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(
                        item.rotulo,
                        style: const TextStyle(
                          color: AppColors.verde,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
