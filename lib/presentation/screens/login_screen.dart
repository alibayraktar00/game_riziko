import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../domain/entities/user_role.dart';
import '../providers/user_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  UserRole? selectedRole;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Custom Background Image from assets
          Positioned.fill(
            child: Image.asset(
              'assets/backgrand/5ae55b86-fcc8-4858-b212-704b55ccc3d1.jpg',
              fit: BoxFit.cover,
            ),
          ),
          // Dark overlay for readability
          Positioned.fill(
            child: Container(
              color: const Color(0xFF070913).withValues(alpha: 0.55),
            ),
          ),
          
          // Soft decorative background glow circles (Mesh gradient effect)
          Positioned(
            top: -120,
            left: -120,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFD500F9).withValues(alpha: 0.12),
              ),
            ).animate(onPlay: (c) => c.repeat(reverse: true))
             .scale(begin: const Offset(1, 1), end: const Offset(1.2, 1.2), duration: 6.seconds)
             .blur(begin: const Offset(60, 60), end: const Offset(90, 90)),
          ),
          Positioned(
            bottom: -150,
            right: -150,
            child: Container(
              width: 380,
              height: 380,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF00E5FF).withValues(alpha: 0.12),
              ),
            ).animate(onPlay: (c) => c.repeat(reverse: true))
             .scale(begin: const Offset(1, 1), end: const Offset(1.15, 1.15), duration: 7.seconds)
             .blur(begin: const Offset(80, 80), end: const Offset(110, 110)),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.4,
            right: -80,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFFD700).withValues(alpha: 0.05),
              ),
            ).animate(onPlay: (c) => c.repeat(reverse: true))
             .scale(begin: const Offset(1, 1), end: const Offset(1.3, 1.3), duration: 5.seconds)
             .blur(begin: const Offset(50, 50), end: const Offset(70, 70)),
          ),

          // Main Scrollable Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Modern Logo Card with Glassmorphism
                    ClipRRect(
                      borderRadius: BorderRadius.circular(32),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 32),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.03),
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.08),
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            children: [
                              // Quiz icon container with gradient glow
                              Container(
                                width: 88,
                                height: 88,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF00E5FF), Color(0xFFD500F9)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF00E5FF).withValues(alpha: 0.3),
                                      blurRadius: 24,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.quiz_rounded,
                                  size: 48,
                                  color: Colors.white,
                                ),
                              ).animate(onPlay: (c) => c.repeat(reverse: true))
                               .shimmer(duration: 3.seconds, color: Colors.white30)
                               .scale(begin: const Offset(1, 1), end: const Offset(1.05, 1.05), duration: 2.seconds, curve: Curves.easeInOut),
                              const SizedBox(height: 24),
                              Text(
                                'RIZIKO',
                                style: GoogleFonts.outfit(
                                  fontSize: 38,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 10,
                                  shadows: [
                                    Shadow(
                                      color: const Color(0xFF00E5FF).withValues(alpha: 0.5),
                                      blurRadius: 15,
                                      offset: const Offset(0, 2),
                                    ),
                                    Shadow(
                                      color: const Color(0xFFD500F9).withValues(alpha: 0.3),
                                      blurRadius: 25,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Çok Oyunculu Quiz Deneyimi',
                                style: GoogleFonts.outfit(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white.withValues(alpha: 0.6),
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic),
                    
                    const SizedBox(height: 48),
                    
                    // "Rolünüzü Seçin" Text
                    Text(
                      'Rolünüzü Seçin',
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white.withValues(alpha: 0.9),
                        letterSpacing: 2,
                      ),
                    ).animate().fadeIn(delay: 200.ms, duration: 600.ms),
                    const SizedBox(height: 24),
                    
                    // Role Cards in Row
                    Row(
                      children: [
                        Expanded(
                          child: _buildModernRoleCard(
                            title: 'YÖNETİCİ',
                            subtitle: 'Oyun oluştur ve yönet',
                            icon: Icons.admin_panel_settings_rounded,
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF5E36), Color(0xFFFF2E93)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            role: UserRole.admin,
                            isSelected: selectedRole == UserRole.admin,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildModernRoleCard(
                            title: 'OYUNCU',
                            subtitle: 'Oyuna hızlıca katıl',
                            icon: Icons.sports_esports_rounded,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF00FF87), Color(0xFF60EFFF)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            role: UserRole.player,
                            isSelected: selectedRole == UserRole.player,
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 300.ms, duration: 600.ms).slideY(begin: 0.05, end: 0, curve: Curves.easeOutCubic),
                    
                    const SizedBox(height: 48),
                    
                    // Modern Continue Button
                    _buildContinueButton().animate().fadeIn(delay: 400.ms, duration: 600.ms),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernRoleCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required LinearGradient gradient,
    required UserRole role,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => setState(() => selectedRole = role),
      child: AnimatedScale(
        scale: isSelected ? 1.04 : 1.0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutBack,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          decoration: BoxDecoration(
            gradient: isSelected 
                ? gradient
                : LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.02),
                      Colors.white.withValues(alpha: 0.04),
                    ],
                  ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isSelected 
                    ? Colors.white.withValues(alpha: 0.25)
                    : Colors.white.withValues(alpha: 0.08),
              width: isSelected ? 2.0 : 1.0,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: gradient.colors.first.withValues(alpha: 0.35),
                      blurRadius: 24,
                      spreadRadius: 1,
                    ),
                  ]
                : [],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon container with background glow when selected
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? Colors.white.withValues(alpha: 0.2)
                      : Colors.white.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 36,
                  color: isSelected ? Colors.white : Colors.white70,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: isSelected ? Colors.white.withValues(alpha: 0.85) : Colors.white.withValues(alpha: 0.5),
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContinueButton() {
    final isEnabled = selectedRole != null;
    
    // Choose gradient based on selected role
    final buttonGradient = selectedRole == UserRole.admin
        ? const LinearGradient(
            colors: [Color(0xFFFF5E36), Color(0xFFFF2E93)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : const LinearGradient(
            colors: [Color(0xFF00FF87), Color(0xFF60EFFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );

    return GestureDetector(
      onTap: isEnabled ? () => _handleRoleSelection(selectedRole!) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        height: 58,
        decoration: BoxDecoration(
          gradient: isEnabled
              ? buttonGradient
              : LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.05),
                    Colors.white.withValues(alpha: 0.03),
                  ],
                ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isEnabled
                ? Colors.white.withValues(alpha: 0.2)
                : Colors.white.withValues(alpha: 0.06),
            width: 1.2,
          ),
          boxShadow: isEnabled
              ? [
                  BoxShadow(
                    color: (selectedRole == UserRole.admin
                            ? const Color(0xFFFF2E93)
                            : const Color(0xFF00FF87))
                        .withValues(alpha: 0.35),
                    blurRadius: 24,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: isEnabled
                ? Row(
                    key: const ValueKey('enabled_state'),
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'DEVAM ET',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: selectedRole == UserRole.player ? const Color(0xFF060913) : Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: selectedRole == UserRole.player ? const Color(0xFF060913) : Colors.white,
                        size: 20,
                      ),
                    ],
                  )
                : Text(
                    key: const ValueKey('disabled_state'),
                    'ROLÜNÜZÜ SEÇİN',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white.withValues(alpha: 0.35),
                      letterSpacing: 2,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  void _handleRoleSelection(UserRole role) {
    ref.read(userProvider.notifier).setUserRole(role);
    
    if (role == UserRole.admin) {
      context.go('/admin');
    } else {
      context.go('/player');
    }
  }
}
