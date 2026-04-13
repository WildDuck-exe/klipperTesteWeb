import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Magic Bottom Navigation Bar
/// Barra de navegação inferior com botões Kart-like
class MagicBottomNav extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const MagicBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<MagicBottomNav> createState() => _MagicNavState();
}

class _MagicNavState extends State<MagicBottomNav>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _floatAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
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
      height: 75,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1565C0),
            Color(0xFF0D47A1),
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D47A1).withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
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
      ),
    );
  }

  static const List<IconData> _navIcons = [
    Icons.dashboard_outlined,
    Icons.people_outline,
    Icons.calendar_today_outlined,
    Icons.content_cut_outlined,
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
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        height: 70,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              width: isActive ? 50 : 44,
              height: isActive ? 50 : 44,
              decoration: BoxDecoration(
                color: isActive
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                icon,
                size: isActive ? 26 : 22,
                color: isActive
                    ? const Color(0xFF0D47A1)
                    : Colors.white.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: isActive ? 11 : 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.6),
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
