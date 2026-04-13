import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Magic Bottom Navigation Bar
/// Ícone ativo flutua pra cima com círculo branco + entalhe curvado na barra
class MagicBottomNav extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const MagicBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<MagicBottomNav> createState() => _MagicBottomNavState();
}

class _MagicBottomNavState extends State<MagicBottomNav>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _floatAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(MagicBottomNav oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _controller.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: const BoxDecoration(
        color: Color(0xFF0D47A1),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 12,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Barra com entalhe curvado
          Positioned.fill(
            child: CustomPaint(
              painter: _MagicNavPainter(
                activeIndex: widget.currentIndex,
                animValue: _floatAnimation.value,
              ),
            ),
          ),
          // Ícones de navegação
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(5, (index) {
              return _MagicNavItem(
                icon: _navIcons[index],
                label: _navLabels[index],
                isActive: widget.currentIndex == index,
                animValue: _floatAnimation.value,
                onTap: () {
                  if (widget.currentIndex != index) {
                    HapticFeedback.lightImpact();
                    widget.onTap(index);
                  }
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  static const List<IconData> _navIcons = [
    Icons.dashboard_outlined,
    Icons.people_outline,
    Icons.calendar_today_outlined,
    Icons.cut_outlined,
    Icons.monetization_on_outlined,
  ];

  static const List<String> _navLabels = [
    'Dashboard',
    'Clientes',
    'Agenda',
    'Serviços',
    'Vendas',
  ];
}

class _MagicNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final double animValue;
  final VoidCallback onTap;

  const _MagicNavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.animValue,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final double floatOffset = isActive ? -30 : 0;
    final double scale = isActive ? 1.15 : 1.0;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 65,
        height: 80,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              transform: Matrix4.identity()
                ..translate(0.0, floatOffset)
                ..scale(scale),
              transformAlignment: Alignment.center,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                width: isActive ? 48 : 40,
                height: isActive ? 48 : 40,
                decoration: BoxDecoration(
                  color: isActive
                      ? Colors.white
                      : Colors.white.withOpacity(0.0),
                  shape: BoxShape.circle,
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  icon,
                  size: isActive ? 26 : 24,
                  color: isActive
                      ? const Color(0xFF0D47A1)
                      : Colors.white.withOpacity(0.55),
                ),
              ),
            ),
            const SizedBox(height: 4),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: isActive ? 1.0 : 0.55,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// CustomPainter que desenha o entalhe curvado na barra
class _MagicNavPainter extends CustomPainter {
  final int activeIndex;
  final double animValue;

  _MagicNavPainter({
    required this.activeIndex,
    required this.animValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // O entalhe é desenhado pelo fundo da página (implied by MagicNav's container)
    // Apenas desenhamos o brilho sutil na curva
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    // A posição do item ativo
    final itemWidth = size.width / 5;
    final centerX = (activeIndex * itemWidth) + (itemWidth / 2);

    // RADIUS do círculo de corte
    const radius = 28.0;
    const topY = -14.0; // topo do entalhe

    // Desenha o entalhe curvado (sombra interna)
    final path = Path();
    path.addArc(
      Rect.fromCircle(center: Offset(centerX, topY + radius), radius: radius),
      3.14159265359, // pi — começa da esquerda
      3.14159265359, // pi — vai até a direita (semicírculo)
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_MagicNavPainter oldDelegate) {
    return oldDelegate.activeIndex != activeIndex ||
        oldDelegate.animValue != animValue;
  }
}
