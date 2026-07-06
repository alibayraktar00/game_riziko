import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Standard page shell: transparent extended AppBar + neon background image
/// + SafeArea. Unifies the three competing header/background patterns found
/// across screens (transparent-extended vs opaque-appbar vs no-gradient) so
/// every screen has the same header height and background treatment.
class RizikoScaffold extends StatelessWidget {
  final String? title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBackButton;
  final PreferredSizeWidget? bottom;
  final Widget? floatingActionButton;

  const RizikoScaffold({
    super.key,
    this.title,
    required this.body,
    this.actions,
    this.leading,
    this.showBackButton = true,
    this.bottom,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: title != null ? Text(title!) : null,
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: leading ?? (showBackButton && canPop
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null),
        actions: actions,
        bottom: bottom,
      ),
      floatingActionButton: floatingActionButton,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: AppTheme.neonGradient,
        child: SafeArea(child: body),
      ),
    );
  }
}
