import 'package:flutter/material.dart';

class Welcome extends StatefulWidget {
  const Welcome({super.key});

  @override
  State<Welcome> createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> with TickerProviderStateMixin {
  double _dragPosition = 0.0;
  double _maxDragExtent = 0.0;

  late AnimationController _buttonAnimationController;
  late Animation<double> _buttonSlideAnimation;

  late AnimationController _goPulseAnimationController;
  late Animation<double> _goPulseAnimation;

  static const double _goButtonSize = 60.0;
  static const double _sliderContainerHeight = 80.0;
  static const double _sliderContainerWidth = 300.0;
  static const double _horizontalPaddingInsideContainer = 20.0;

  @override
  void initState() {
    super.initState();

    _buttonAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _buttonSlideAnimation = Tween<double>(begin: 0.0, end: 0.0).animate(_buttonAnimationController);

    _goPulseAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);

    _goPulseAnimation = Tween<double>(begin: 0.0, end: 15.0).animate(CurvedAnimation(
      parent: _goPulseAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _maxDragExtent = _sliderContainerWidth - _goButtonSize - (_horizontalPaddingInsideContainer * 2);
  }

  @override
  void dispose() {
    _buttonAnimationController.dispose();
    _goPulseAnimationController.dispose();
    super.dispose();
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragPosition += details.primaryDelta!;
      _dragPosition = _dragPosition.clamp(0.0, _maxDragExtent);

      if (_dragPosition > 0) {
        _goPulseAnimationController.stop();
      } else {
        if (!_goPulseAnimationController.isAnimating) {
          _goPulseAnimationController.repeat(reverse: true);
        }
      }

      if (_dragPosition / _maxDragExtent >= 0.95) {
        _navigateToNextScreen();
      }
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (_dragPosition / _maxDragExtent < 0.95) {
      _startButtonSlideAnimation(0.0);
    }
    if (!_goPulseAnimationController.isAnimating && _dragPosition < _maxDragExtent * 0.95) {
      _goPulseAnimationController.repeat(reverse: true);
    }
  }

  void _startButtonSlideAnimation(double targetPosition) {
    if (_buttonAnimationController.isAnimating) {
      _buttonAnimationController.stop();
    }
    
    _buttonSlideAnimation = Tween<double>(
      begin: _dragPosition / _maxDragExtent,
      end: targetPosition / _maxDragExtent,
    ).animate(CurvedAnimation(parent: _buttonAnimationController, curve: Curves.easeOut));

    _buttonAnimationController.forward().then((_) {
      setState(() {
        _dragPosition = targetPosition;
      });
      _buttonAnimationController.reset();
      if (!_goPulseAnimationController.isAnimating && _dragPosition == 0.0) {
        _goPulseAnimationController.repeat(reverse: true);
      }
    });
  }

  void _navigateToNextScreen() {
    if (_dragPosition / _maxDragExtent >= 0.95 && mounted) {
      _buttonAnimationController.stop();
      _goPulseAnimationController.stop();

      setState(() {
        _dragPosition = 0.0;
      });

      Navigator.pushReplacementNamed(context, '/login').then((_) {
        if (!_goPulseAnimationController.isAnimating) {
          _goPulseAnimationController.repeat(reverse: true);
        }
        _startButtonSlideAnimation(0.0);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Image.asset(
            'assets/images/background.jpg',
            fit: BoxFit.cover,
          ),
          Positioned(
            left: (screenWidth - _sliderContainerWidth) / 2,
            right: (screenWidth - _sliderContainerWidth) / 2,
            bottom: 70,
            child: Container(
              height: _sliderContainerHeight,
              width: _sliderContainerWidth,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(_sliderContainerHeight / 2),
              ),
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.symmetric(horizontal: _horizontalPaddingInsideContainer),
              child: Stack(
                children: <Widget>[
                  AnimatedBuilder(
                    animation: Listenable.merge([_buttonAnimationController, _goPulseAnimationController]),
                    builder: (context, child) {
                      double currentOffset = _dragPosition;
                      if (_buttonAnimationController.isAnimating) {
                        currentOffset = _buttonSlideAnimation.value * _maxDragExtent;
                      } else if (_dragPosition == 0.0) {
                        currentOffset += _goPulseAnimation.value;
                      }

                      return Positioned(
                        left: currentOffset,
                        top: (_sliderContainerHeight - _goButtonSize) / 2,
                        child: GestureDetector(
                          onHorizontalDragUpdate: _onHorizontalDragUpdate,
                          onHorizontalDragEnd: _onHorizontalDragEnd,
                          child: FloatingActionButton(
                            onPressed: () {
                              if (_dragPosition / _maxDragExtent >= 0.95) {
                                _navigateToNextScreen();
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Swipe to GO!')),
                                );
                              }
                            },
                            backgroundColor: Colors.blue.shade800,
                            foregroundColor: Colors.white,
                            elevation: 8,
                            shape: const CircleBorder(),
                            child: const Text(
                              'GO',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: screenHeight * 0.2,
            left: 20,
            right: 20,
            child: const Text(
              'Let\'s make our life so a life',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                shadows: [
                  Shadow(
                    blurRadius: 5.0,
                    color: Colors.black,
                    offset: Offset(2.0, 2.0),
                  ),
                ],
                letterSpacing: 0.5,
                height: 1.0,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.visible,
            ),
          ),
        ],
      ),
    );
  }
}