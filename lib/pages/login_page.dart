import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../l10n/app_localizations.dart';
import '../main.dart';
import '../theme.dart';
import '../widgets/brand.dart';
import '../widgets/language_selector.dart';

// Esquema de URL al que vuelve el navegador tras el login con Google en
// móvil y escritorio. Debe coincidir con lo configurado en Android/iOS y
// en la lista de "Redirect URLs" de Supabase.
const String _oauthRedirect = 'com.kirolive.app://login-callback/';

/// Pantalla de inicio de sesión y registro con email + contraseña.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // True mientras esperamos respuesta de Supabase (deshabilita los botones).
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Inicia sesión con un usuario ya registrado.
  Future<void> _signIn() async {
    final l = AppLocalizations.of(context);
    setState(() => _loading = true);
    try {
      await supabase.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      // No navegamos manualmente: el AuthGate detecta la sesión y cambia de pantalla.
    } on AuthException catch (error) {
      _showMessage(error.message);
    } catch (error) {
      _showMessage(l.errorUnexpected);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// Registra un usuario nuevo. Con "Confirm email" desactivado en Supabase,
  /// la sesión queda activa de inmediato.
  Future<void> _signUp() async {
    final l = AppLocalizations.of(context);
    setState(() => _loading = true);
    try {
      final response = await supabase.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      // Si la confirmación por email está activada, no habrá sesión todavía.
      if (response.session == null && mounted) {
        _showMessage(l.checkEmailConfirm);
      }
    } on AuthException catch (error) {
      _showMessage(error.message);
    } catch (error) {
      _showMessage(l.errorUnexpected);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// Inicia sesión con Google (OAuth).
  ///
  /// Abre el navegador para que el usuario elija su cuenta. Al terminar, vuelve
  /// a la app y la sesión llega por `onAuthStateChange` (el AuthGate cambia solo
  /// de pantalla), igual que con el login de email.
  Future<void> _signInWithGoogle() async {
    final l = AppLocalizations.of(context);
    try {
      await supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        // En web no hace falta esquema: vuelve a la URL actual de la web.
        // En móvil/escritorio usamos el esquema propio de la app.
        redirectTo: kIsWeb ? null : _oauthRedirect,
      );
    } on AuthException catch (error) {
      _showMessage(error.message);
    } catch (error) {
      _showMessage(l.errorGoogleSignIn);
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final l = AppLocalizations.of(context);

    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 380),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Marca de Kirolive.
                    const Center(child: KiroliveMark(size: 66, glow: true)),
                    const SizedBox(height: 22),
                    Text(
                      'Kirolive',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l.appTagline,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(color: muted),
                    ),
                    const SizedBox(height: 36),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      decoration: InputDecoration(labelText: l.email),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(labelText: l.password),
                    ),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: _loading ? null : _signIn,
                      child: _loading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: AppColors.ink),
                            )
                          : Text(l.signIn),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton(
                      onPressed: _loading ? null : _signUp,
                      child: Text(l.createAccount),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(l.orWord, style: TextStyle(color: muted)),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 24),
                    OutlinedButton.icon(
                      onPressed: _loading ? null : _signInWithGoogle,
                      icon: const Icon(Icons.g_mobiledata, size: 26),
                      label: Text(l.continueWithGoogle),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Selector de idioma (arriba a la derecha), también antes de entrar.
          Positioned(
            top: 4,
            right: 4,
            child: SafeArea(
              child: IconButton(
                tooltip: l.language,
                icon: Icon(Icons.language, color: muted),
                onPressed: () => showLanguagePicker(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
