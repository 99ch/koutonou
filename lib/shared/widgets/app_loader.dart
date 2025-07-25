// Indicateurs de chargement personnalisés
// Fournit différents types de loaders avec styles cohérents

import 'package:flutter/material.dart';
import '../extensions/extensions.dart';

/// Types de loaders disponibles
enum LoaderType { circular, linear, dots, pulse, spinner }

/// Tailles de loaders
enum LoaderSize { small, medium, large }

/// Loader principal personnalisé
class AppLoader extends StatelessWidget {
  final LoaderType type;
  final LoaderSize size;
  final Color? color;
  final String? message;
  final bool overlay;
  final double? value; // Pour les loaders avec progression

  const AppLoader({
    super.key,
    this.type = LoaderType.circular,
    this.size = LoaderSize.medium,
    this.color,
    this.message,
    this.overlay = false,
    this.value,
  });

  /// Constructeur pour loader avec overlay
  const AppLoader.overlay({
    super.key,
    this.type = LoaderType.circular,
    this.size = LoaderSize.medium,
    this.color,
    this.message,
    this.value,
  }) : overlay = true;

  /// Constructeur pour loader linéaire avec progression
  const AppLoader.progress({
    super.key,
    required this.value,
    this.size = LoaderSize.medium,
    this.color,
    this.message,
    this.overlay = false,
  }) : type = LoaderType.linear;

  @override
  Widget build(BuildContext context) {
    final loader = _buildLoader(context);

    if (overlay) {
      return Container(
        color: Colors.black54,
        child: Center(child: loader),
      );
    }

    return loader;
  }

  Widget _buildLoader(BuildContext context) {
    final loaderWidget = _getLoaderWidget(context);

    if (message != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          loaderWidget,
          const SizedBox(height: 16),
          Text(
            message!,
            style: context.textStyles.bodyMedium?.copyWith(
              color: color ?? context.colors.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    return loaderWidget;
  }

  Widget _getLoaderWidget(BuildContext context) {
    switch (type) {
      case LoaderType.circular:
        return _CircularLoader(
          size: size,
          color: color ?? context.colors.primary,
          value: value,
        );
      case LoaderType.linear:
        return _LinearLoader(
          size: size,
          color: color ?? context.colors.primary,
          value: value,
        );
      case LoaderType.dots:
        return _DotsLoader(size: size, color: color ?? context.colors.primary);
      case LoaderType.pulse:
        return _PulseLoader(size: size, color: color ?? context.colors.primary);
      case LoaderType.spinner:
        return _SpinnerLoader(
          size: size,
          color: color ?? context.colors.primary,
        );
    }
  }
}

/// Loader circulaire
class _CircularLoader extends StatelessWidget {
  final LoaderSize size;
  final Color color;
  final double? value;

  const _CircularLoader({required this.size, required this.color, this.value});

  @override
  Widget build(BuildContext context) {
    final sizeValue = _getSizeValue(context);

    return SizedBox(
      width: sizeValue,
      height: sizeValue,
      child: CircularProgressIndicator(
        value: value,
        color: color,
        strokeWidth: _getStrokeWidth(),
      ),
    );
  }

  double _getSizeValue(BuildContext context) {
    switch (size) {
      case LoaderSize.small:
        return context.responsive(mobile: 16, tablet: 18, desktop: 20);
      case LoaderSize.medium:
        return context.responsive(mobile: 24, tablet: 28, desktop: 32);
      case LoaderSize.large:
        return context.responsive(mobile: 32, tablet: 36, desktop: 40);
    }
  }

  double _getStrokeWidth() {
    switch (size) {
      case LoaderSize.small:
        return 2;
      case LoaderSize.medium:
        return 3;
      case LoaderSize.large:
        return 4;
    }
  }
}

/// Loader linéaire
class _LinearLoader extends StatelessWidget {
  final LoaderSize size;
  final Color color;
  final double? value;

  const _LinearLoader({required this.size, required this.color, this.value});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _getWidth(context),
      height: _getHeight(),
      child: LinearProgressIndicator(
        value: value,
        color: color,
        backgroundColor: color.withValues(alpha: 0.2),
      ),
    );
  }

  double _getWidth(BuildContext context) {
    switch (size) {
      case LoaderSize.small:
        return context.responsive(mobile: 100, tablet: 120, desktop: 140);
      case LoaderSize.medium:
        return context.responsive(mobile: 150, tablet: 180, desktop: 200);
      case LoaderSize.large:
        return context.responsive(mobile: 200, tablet: 240, desktop: 280);
    }
  }

  double _getHeight() {
    switch (size) {
      case LoaderSize.small:
        return 3;
      case LoaderSize.medium:
        return 4;
      case LoaderSize.large:
        return 6;
    }
  }
}

/// Loader avec points animés
class _DotsLoader extends StatefulWidget {
  final LoaderSize size;
  final Color color;

  const _DotsLoader({required this.size, required this.color});

  @override
  State<_DotsLoader> createState() => _DotsLoaderState();
}

class _DotsLoaderState extends State<_DotsLoader>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      3,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
      ),
    );

    _animations = _controllers.map((controller) {
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));
    }).toList();

    _startAnimation();
  }

  void _startAnimation() {
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (mounted) {
          _controllers[i].repeat(reverse: true);
        }
      });
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dotSize = _getDotSize(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: dotSize,
              height: dotSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color.withValues(
                  alpha: 0.3 + (_animations[index].value * 0.7),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  double _getDotSize(BuildContext context) {
    switch (widget.size) {
      case LoaderSize.small:
        return context.responsive(mobile: 6, tablet: 7, desktop: 8);
      case LoaderSize.medium:
        return context.responsive(mobile: 8, tablet: 9, desktop: 10);
      case LoaderSize.large:
        return context.responsive(mobile: 10, tablet: 11, desktop: 12);
    }
  }
}

/// Loader avec effet de pulsation
class _PulseLoader extends StatefulWidget {
  final LoaderSize size;
  final Color color;

  const _PulseLoader({required this.size, required this.color});

  @override
  State<_PulseLoader> createState() => _PulseLoaderState();
}

class _PulseLoaderState extends State<_PulseLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sizeValue = _getSizeValue(context);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: sizeValue,
          height: sizeValue,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color.withValues(alpha: _animation.value),
          ),
        );
      },
    );
  }

  double _getSizeValue(BuildContext context) {
    switch (widget.size) {
      case LoaderSize.small:
        return context.responsive(mobile: 20, tablet: 22, desktop: 24);
      case LoaderSize.medium:
        return context.responsive(mobile: 30, tablet: 34, desktop: 38);
      case LoaderSize.large:
        return context.responsive(mobile: 40, tablet: 44, desktop: 48);
    }
  }
}

/// Loader spinner personnalisé
class _SpinnerLoader extends StatefulWidget {
  final LoaderSize size;
  final Color color;

  const _SpinnerLoader({required this.size, required this.color});

  @override
  State<_SpinnerLoader> createState() => _SpinnerLoaderState();
}

class _SpinnerLoaderState extends State<_SpinnerLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sizeValue = _getSizeValue(context);

    return SizedBox(
      width: sizeValue,
      height: sizeValue,
      child: CustomPaint(
        painter: _SpinnerPainter(animation: _controller, color: widget.color),
      ),
    );
  }

  double _getSizeValue(BuildContext context) {
    switch (widget.size) {
      case LoaderSize.small:
        return context.responsive(mobile: 20, tablet: 22, desktop: 24);
      case LoaderSize.medium:
        return context.responsive(mobile: 30, tablet: 34, desktop: 38);
      case LoaderSize.large:
        return context.responsive(mobile: 40, tablet: 44, desktop: 48);
    }
  }
}

class _SpinnerPainter extends CustomPainter {
  final Animation<double> animation;
  final Color color;

  _SpinnerPainter({required this.animation, required this.color})
    : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    const startAngle = 0.0;
    final sweepAngle = animation.value * 2 * 3.14159;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Widget d'état de chargement pour les listes
class LoadingListItem extends StatelessWidget {
  final int itemCount;
  final double itemHeight;

  const LoadingListItem({super.key, this.itemCount = 5, this.itemHeight = 60});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Container(
          height: itemHeight,
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const AppLoader(
            type: LoaderType.pulse,
            size: LoaderSize.small,
          ),
        );
      },
    );
  }
}
