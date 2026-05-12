import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A237E), // Deep blue
              Color(0xFF0D47A1), // Dark blue
              Color(0xFF2196F3), // Electric blue
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Modern Logo Card
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 40,
                        spreadRadius: 0,
                      ),
                      BoxShadow(
                        color: const Color(0xFF2196F3).withValues(alpha: 0.2),
                        blurRadius: 60,
                        spreadRadius: -20,
                        offset: const Offset(0, -10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0, end: 1),
                        duration: const Duration(seconds: 2),
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: 1.0 + (value * 0.1),
                            child: child!,
                          );
                        },
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF2196F3), Color(0xFF21D4FD)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF2196F3).withValues(alpha: 0.3),
                                blurRadius: 20,
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.quiz_rounded,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'RIZIKO',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 8,
                          shadows: [
                            Shadow(
                              color:  Color(0xFF2196F3),
                              blurRadius: 20,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Çok Oyunculu Quiz Deneyimi',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withValues(alpha: 0.8),
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Modern Role Selection
                Column(
                  children: [
                    Text(
                      'Rolünüzü Seçin',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Role Cards
                    Row(
                      children: [
                        Expanded(
                          child: _buildModernRoleCard(
                            title: 'YÖNETİCİ',
                            subtitle: 'Oyun oluştur ve yönet',
                            icon: Icons.admin_panel_settings,
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF6B35), Color(0xFFFF9558)],
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
                            subtitle: 'Oyuna katıl',
                            icon: Icons.person,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF00C853), Color(0xFF00D084)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            role: UserRole.player,
                            isSelected: selectedRole == UserRole.player,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Modern Continue Button
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 800),
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(0, (1 - value) * 20),
                      child: child!,
                    );
                  },
                  child: GestureDetector(
                    onTap: selectedRole != null ? () => _handleRoleSelection(selectedRole!) : null,
                    child: Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: selectedRole != null
                            ? const LinearGradient(
                                colors: [Color(0xFF2196F3), Color(0xFF21D4FD)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : LinearGradient(
                                colors: [
                                  Colors.grey.withValues(alpha: 0.3),
                                  Colors.grey.withValues(alpha: 0.1),
                                ],
                              ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: selectedRole != null
                            ? [
                                BoxShadow(
                                  color: const Color(0xFF2196F3).withValues(alpha: 0.4),
                                  blurRadius: 20,
                                  spreadRadius: 0,
                                ),
                              ]
                            : null,
                      ),
                      child: Center(
                        child: selectedRole != null
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    'DEVAM ET',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(
                                    Icons.arrow_forward,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ],
                              )
                            : Text(
                                'ROL SEÇİN',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white.withValues(alpha: 0.7),
                                  letterSpacing: 1,
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
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: 1),
        duration: const Duration(milliseconds: 300),
        builder: (context, value, child) {
          return Transform.scale(
            scale: 1.0 + (value * 0.05),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: isSelected 
                    ? gradient
                    : LinearGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.1),
                          Colors.white.withValues(alpha: 0.05),
                        ],
                      ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected 
                        ? gradient.colors.first.withValues(alpha: 0.5)
                        : Colors.white.withValues(alpha: 0.2),
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: gradient.colors.first.withValues(alpha: 0.3),
                          blurRadius: 20,
                          spreadRadius: 0,
                        ),
                      ]
                    : null,
              ),
              child: Column(
                children: [
                  Icon(
                    icon,
                    size: 48,
                    color: isSelected ? Colors.white : Colors.white70,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: isSelected ? Colors.white.withValues(alpha: 0.8) : Colors.white60,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _handleRoleSelection(UserRole role) {
    ref.read(userProvider.notifier).setUserRole(role);
    
    if (role == UserRole.admin) {
      context.go('/admin/home');
    } else {
      context.go('/player/home');
    }
  }
}
