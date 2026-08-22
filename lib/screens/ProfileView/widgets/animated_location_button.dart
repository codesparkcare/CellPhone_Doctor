import 'package:flutter/material.dart';

class AnimatedLocationButton extends StatefulWidget {
  final bool isDetecting;
  final VoidCallback onTap;

  const AnimatedLocationButton({
    super.key,
    required this.isDetecting,
    required this.onTap,
  });

  @override
  State<AnimatedLocationButton> createState() => _AnimatedLocationButtonState();
}

class _AnimatedLocationButtonState extends State<AnimatedLocationButton>
    with TickerProviderStateMixin {
  late AnimationController _idleController;
  late AnimationController _detectingController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _detectingPulseAnimation;
  late Animation<double> _rotationAnimation;

  // Vibrant color cycling animation (Electric Blue -> Cyan -> Emerald -> Indigo -> Blue)
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    // Continuous smooth color blink / breathing pulse animation
    _idleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _detectingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _colorAnimation = TweenSequence<Color?>([
      TweenSequenceItem(
        weight: 1.0,
        tween: ColorTween(
          begin: const Color(0xFF2563EB), // Royal Blue
          end: const Color(0xFF06B6D4),   // Cyan / Sky
        ),
      ),
      TweenSequenceItem(
        weight: 1.0,
        tween: ColorTween(
          begin: const Color(0xFF06B6D4),
          end: const Color(0xFF10B981),   // Emerald Green / GPS Live
        ),
      ),
      TweenSequenceItem(
        weight: 1.0,
        tween: ColorTween(
          begin: const Color(0xFF10B981),
          end: const Color(0xFF6366F1),   // Indigo
        ),
      ),
      TweenSequenceItem(
        weight: 1.0,
        tween: ColorTween(
          begin: const Color(0xFF6366F1),
          end: const Color(0xFF2563EB),   // Royal Blue
        ),
      ),
    ]).animate(_idleController);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.18).animate(
      CurvedAnimation(parent: _idleController, curve: Curves.easeInOut),
    );

    _detectingPulseAnimation = Tween<double>(begin: 0.85, end: 1.45).animate(
      CurvedAnimation(parent: _detectingController, curve: Curves.easeInOut),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 2 * 3.141592653589793).animate(
      CurvedAnimation(parent: _detectingController, curve: Curves.linear),
    );

    if (widget.isDetecting) {
      _detectingController.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedLocationButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isDetecting != oldWidget.isDetecting) {
      if (widget.isDetecting) {
        _detectingController.repeat();
      } else {
        _detectingController.stop();
        _detectingController.reset();
      }
    }
  }

  @override
  void dispose() {
    _idleController.dispose();
    _detectingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: "Detect Current Location",
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: widget.isDetecting ? null : widget.onTap,
          child: Padding(
            padding: const EdgeInsets.all(6.0),
            child: AnimatedBuilder(
              animation: Listenable.merge([_idleController, _detectingController]),
              builder: (context, child) {
                final activeColor = _colorAnimation.value ?? const Color(0xFF2563EB);

                if (widget.isDetecting) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      // Expanding ripple radar wave with active blinking color
                      Transform.scale(
                        scale: _detectingPulseAnimation.value,
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: activeColor.withValues(
                              alpha: (1.45 - _detectingPulseAnimation.value).clamp(0.0, 0.45),
                            ),
                          ),
                        ),
                      ),
                      // Rotating radar / crosshair icon
                      Transform.rotate(
                        angle: _rotationAnimation.value,
                        child: Icon(
                          Icons.my_location_rounded,
                          color: activeColor,
                          size: 23,
                        ),
                      ),
                    ],
                  );
                }

                // Idle state: Smooth color blinking & breathing pulse aura
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    // Color blinking glowing aura ring
                    Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: activeColor.withValues(alpha: 0.15),
                          boxShadow: [
                            BoxShadow(
                              color: activeColor.withValues(alpha: 0.35),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Icon itself with color-blinking tint
                    Icon(
                      Icons.my_location_rounded,
                      color: activeColor,
                      size: 22,
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
