import 'dart:math';
import 'package:flutter/material.dart';

/// Виджет переворачивающейся карточки
class FlipCard extends StatefulWidget {
  final Widget front;
  final Widget back;
  final bool isFlipped;
  final VoidCallback? onFlip;
  final Duration duration;

  const FlipCard({
    super.key,
    required this.front,
    required this.back,
    this.isFlipped = false,
    this.onFlip,
    this.duration = const Duration(milliseconds: 300),
  });

  @override
  State<FlipCard> createState() => _FlipCardState();
}

class _FlipCardState extends State<FlipCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _showFront = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);

    _animation.addListener(() {
      if (_animation.value > 0.5 && _showFront) {
        setState(() => _showFront = false);
      } else if (_animation.value < 0.5 && !_showFront) {
        setState(() => _showFront = true);
      }
    });
  }

  @override
  void didUpdateWidget(FlipCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isFlipped != oldWidget.isFlipped) {
      if (widget.isFlipped) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flip() {
    if (_controller.isAnimating) return;

    widget.onFlip?.call();

    if (_controller.isCompleted) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _flip,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final angle = _animation.value * pi;
          final transform = Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(angle);

          return Transform(
            transform: transform,
            alignment: Alignment.center,
            child: _showFront
                ? widget.front
                : Transform(
                    transform: Matrix4.identity()..rotateY(pi),
                    alignment: Alignment.center,
                    child: widget.back,
                  ),
          );
        },
      ),
    );
  }
}

/// Виджет карточки для изучения
class StudyCardWidget extends StatelessWidget {
  final String word;
  final String? article;
  final String? translation;
  final String? example;
  final String? exampleTranslation;
  final bool showTranslation;
  final VoidCallback? onPlayAudio;

  const StudyCardWidget({
    super.key,
    required this.word,
    this.article,
    this.translation,
    this.example,
    this.exampleTranslation,
    this.showTranslation = false,
    this.onPlayAudio,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!showTranslation) ...[
              // Передняя сторона - немецкое слово
              if (article != null)
                Text(
                  article!,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey.shade600,
                  ),
                ),
              Text(
                word,
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              if (onPlayAudio != null) ...[
                const SizedBox(height: 16),
                IconButton(
                  onPressed: onPlayAudio,
                  icon: const Icon(Icons.volume_up),
                  iconSize: 32,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
              const SizedBox(height: 24),
              Text(
                'Нажмите, чтобы увидеть перевод',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                ),
              ),
            ] else ...[
              // Задняя сторона - перевод
              Text(
                translation ?? '',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              if (example != null) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        example!,
                        style: const TextStyle(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (exampleTranslation != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          exampleTranslation!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
