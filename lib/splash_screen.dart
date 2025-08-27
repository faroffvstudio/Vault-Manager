import 'package:flutter/material.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _backgroundController;
  late Animation<double> _logoScale;
  late Animation<double> _logoRotation;
  late Animation<double> _textFade;
  late Animation<Offset> _textSlide;
  late Animation<double> _backgroundRotation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startAnimations();
    _navigateToHome();
  }

  void _initAnimations() {
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );

    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _logoRotation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeInOut),
    );
    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeInOut),
    );
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeOutBack));
    _backgroundRotation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _backgroundController, curve: Curves.linear),
    );
  }

  void _startAnimations() async {
    _backgroundController.repeat();
    await Future.delayed(const Duration(milliseconds: 300));
    _logoController.forward();
    await Future.delayed(const Duration(milliseconds: 800));
    _textController.forward();
  }

  _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _backgroundController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF667eea),
                  const Color(0xFF764ba2),
                  const Color(0xFF8B5CF6),
                  const Color(0xFFAB47BC),
                ],
                stops: const [0.0, 0.3, 0.7, 1.0],
                transform: GradientRotation(_backgroundRotation.value * 6.28),
              ),
            ),
            child: Stack(
              children: [
                // Floating particles
                ...List.generate(20, (index) => _buildFloatingParticle(index)),
                // Main content
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Animated logo
                      AnimatedBuilder(
                        animation: _logoController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _logoScale.value,
                            child: Transform.rotate(
                              angle: _logoRotation.value * 0.5,
                              child: Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    colors: [Colors.white, Color(0xFFF0F0F0)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 30,
                                      offset: const Offset(0, 15),
                                    ),
                                    BoxShadow(
                                      color: Colors.white.withOpacity(0.8),
                                      blurRadius: 20,
                                      offset: const Offset(-5, -5),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.security,
                                  size: 60,
                                  color: Color(0xFF667eea),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 40),
                      // Animated text
                      AnimatedBuilder(
                        animation: _textController,
                        builder: (context, child) {
                          return FadeTransition(
                            opacity: _textFade,
                            child: SlideTransition(
                              position: _textSlide,
                              child: Column(
                                children: [
                                  ShaderMask(
                                    shaderCallback: (bounds) => const LinearGradient(
                                      colors: [Colors.white, Color(0xFFE8EAF6)],
                                    ).createShader(bounds),
                                    child: const Text(
                                      'VAULT',
                                      style: TextStyle(
                                        fontSize: 42,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                        letterSpacing: 8,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(25),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.3),
                                      ),
                                    ),
                                    child: const Text(
                                      'Employee Management',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                        letterSpacing: 2,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 60),
                      // Loading indicator
                      AnimatedBuilder(
                        animation: _textController,
                        builder: (context, child) {
                          return FadeTransition(
                            opacity: _textFade,
                            child: Column(
                              children: [
                                SizedBox(
                                  width: 40,
                                  height: 40,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white.withOpacity(0.8),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Loading...',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white.withOpacity(0.8),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFloatingParticle(int index) {
    final random = (index * 1234567) % 1000 / 1000.0;
    final size = 4.0 + (random * 8);
    final left = random * MediaQuery.of(context).size.width;
    final animationDelay = random * 2000;
    
    return AnimatedBuilder(
      animation: _backgroundController,
      builder: (context, child) {
        final progress = (_backgroundController.value + animationDelay / 2000) % 1.0;
        final top = MediaQuery.of(context).size.height * progress;
        
        return Positioned(
          left: left,
          top: top - 100,
          child: Opacity(
            opacity: 0.6,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.7),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.5),
                    blurRadius: size,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}