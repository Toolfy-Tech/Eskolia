import 'package:flutter/material.dart';

const Color _blue = Color(0xFF3B82F6);
const Color _violet = Color(0xFF7C3AED);

class EskoliaTopBar extends StatelessWidget implements PreferredSizeWidget {
  const EskoliaTopBar({
    super.key,
    required this.userName,
    required this.level,
    required this.currentXp,
    required this.maxXp,
    required this.streak,
  });

  final String userName;
  final int level;
  final int currentXp;
  final int maxXp;
  final int streak;

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) {
    final xpProgress = maxXp > 0 ? (currentXp / maxXp).clamp(0.0, 1.0) : 0.0;

    return SizedBox(
      height: 72,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _AvatarRing(
                    child: Text(
                      userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: Text(
                      userName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: _XpSection(
                      level: level,
                      currentXp: currentXp,
                      maxXp: maxXp,
                      progress: xpProgress,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('\u{1F525}', style: TextStyle(fontSize: 18)),
                      const SizedBox(width: 4),
                      Text(
                        '$streak',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFFF97316),
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const _TopBarDivider(),
        ],
      ),
    );
  }
}

class _AvatarRing extends StatelessWidget {
  const _AvatarRing({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      padding: const EdgeInsets.all(2),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [_blue, _violet],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFF1E293B),
        ),
        alignment: Alignment.center,
        child: child,
      ),
    );
  }
}

class _XpSection extends StatelessWidget {
  const _XpSection({
    required this.level,
    required this.currentXp,
    required this.maxXp,
    required this.progress,
  });

  final int level;
  final int currentXp;
  final int maxXp;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _blue.withValues(alpha: 0.35)),
          ),
          child: Text(
            'Niveau $level',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: SizedBox(
            height: 6,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(color: const Color(0xFF334155)),
                FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: progress,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [_blue, _violet],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$currentXp / $maxXp XP',
          style: TextStyle(
            fontSize: 10,
            color: Colors.white.withValues(alpha: 0.75),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _TopBarDivider extends StatelessWidget {
  const _TopBarDivider();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 2,
      width: double.infinity,
      child: CustomPaint(
        painter: _GradientLinePainter(),
      ),
    );
  }
}

class _GradientLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [
          _blue,
          _violet,
          Colors.transparent,
        ],
        stops: [0, 0.55, 1],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(rect);
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
