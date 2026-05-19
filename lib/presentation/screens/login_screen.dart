import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loadstock/core/config/env_config.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isPasswordStep = false;
  bool _isLoading = false;
  bool _obscurePassword = true;
  
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _backgroundController;
  
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _backgroundAnimation;

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _backgroundController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _backgroundAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _backgroundController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  bool _isValidUsername(String username) {
    return username.length >= 3;
  }

  void _handleNext() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isPasswordStep = true);
      _fadeController.reset();
      _slideController.reset();
      _fadeController.forward();
      _slideController.forward();
    }
  }

  void _handleBack() {
    setState(() {
      _isPasswordStep = false;
      _passwordController.clear();
    });
    _fadeController.reset();
    _slideController.reset();
    _fadeController.forward();
    _slideController.forward();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      await Future.delayed(const Duration(seconds: 2));
      
      setState(() => _isLoading = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text('Login realizado com sucesso!', style: GoogleFonts.inter()),
              ],
            ),
            backgroundColor: EnvConfig.successColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;
    
    return Scaffold(
      body: Stack(
        children: [
          // Background animado
          _buildAnimatedBackground(),
          
          // Conteúdo principal
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 24 : 48,
                  vertical: 24,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isSmallScreen ? double.infinity : 500,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeader(),
                      SizedBox(height: size.height * 0.06),
                      _buildForm(),
                      const SizedBox(height: 24),
                      _buildActionButton(),
                      if (_isPasswordStep) ...[
                        const SizedBox(height: 16),
                        _buildBackButton(),
                        const SizedBox(height: 24),
                        _buildForgotPassword(),
                      ],
                      if (!_isPasswordStep) ...[
                        const SizedBox(height: 32),
                        _buildDivider(),
                        const SizedBox(height: 32),
                        _buildFooter(),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _backgroundAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                EnvConfig.primaryColor.withValues(alpha: 0.1),
                EnvConfig.secondaryColor.withValues(alpha: 0.05),
                Colors.white,
                EnvConfig.accentColor.withValues(alpha: 0.05),
              ],
              stops: [
                0.0,
                0.3 + (_backgroundAnimation.value * 0.2),
                0.7 + (_backgroundAnimation.value * 0.1),
                1.0,
              ],
            ),
          ),
          child: CustomPaint(
            painter: BackgroundPatternPainter(
              animation: _backgroundAnimation.value,
              color: EnvConfig.primaryColor.withValues(alpha: 0.03),
            ),
            size: Size.infinite,
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Column(
          children: [
            // Logo com efeito glassmorphism
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    EnvConfig.primaryColor,
                    EnvConfig.secondaryColor,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: EnvConfig.primaryColor.withValues(alpha: 0.4),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  EnvConfig.logoIcon,
                  style: GoogleFonts.inter(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              EnvConfig.appName,
              style: GoogleFonts.inter(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1F2937),
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              EnvConfig.appSubtitle,
              style: GoogleFonts.inter(
                fontSize: 16,
                color: const Color(0xFF6B7280),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              _isPasswordStep ? 'Bem-vindo de volta!' : 'Faça login para continuar',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF374151),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!_isPasswordStep) _buildEmailField(),
              if (_isPasswordStep) ...[
                _buildUserDisplay(),
                const SizedBox(height: 20),
                _buildPasswordField(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.next,
        style: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF1F2937),
        ),
        decoration: InputDecoration(
          labelText: 'Usuário ou E-mail',
          labelStyle: GoogleFonts.inter(
            color: const Color(0xFF6B7280),
            fontWeight: FontWeight.w500,
          ),
          hintText: 'Digite seu usuário ou e-mail',
          hintStyle: GoogleFonts.inter(
            color: const Color(0xFF9CA3AF),
            fontSize: 15,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: EnvConfig.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.person_outline_rounded,
              color: EnvConfig.primaryColor,
              size: 24,
            ),
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: const Color(0xFFE5E7EB),
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: EnvConfig.primaryColor,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: EnvConfig.errorColor,
              width: 1.5,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: EnvConfig.errorColor,
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 20,
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Por favor, digite seu usuário ou e-mail';
          }
          if (!_isValidEmail(value) && !_isValidUsername(value)) {
            return 'Digite um usuário válido (mín. 3 caracteres) ou e-mail';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildUserDisplay() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            EnvConfig.primaryColor.withValues(alpha: 0.08),
            EnvConfig.secondaryColor.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: EnvConfig.primaryColor.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  EnvConfig.primaryColor,
                  EnvConfig.secondaryColor,
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: EnvConfig.primaryColor.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Entrando como',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF6B7280),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _emailController.text,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1F2937),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: _passwordController,
        obscureText: _obscurePassword,
        textInputAction: TextInputAction.done,
        style: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF1F2937),
        ),
        onFieldSubmitted: (_) => _handleLogin(),
        decoration: InputDecoration(
          labelText: 'Senha',
          labelStyle: GoogleFonts.inter(
            color: const Color(0xFF6B7280),
            fontWeight: FontWeight.w500,
          ),
          hintText: 'Digite sua senha',
          hintStyle: GoogleFonts.inter(
            color: const Color(0xFF9CA3AF),
            fontSize: 15,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: EnvConfig.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.lock_outline_rounded,
              color: EnvConfig.primaryColor,
              size: 24,
            ),
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: const Color(0xFF6B7280),
            ),
            onPressed: () {
              setState(() => _obscurePassword = !_obscurePassword);
            },
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: const Color(0xFFE5E7EB),
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: EnvConfig.primaryColor,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: EnvConfig.errorColor,
              width: 1.5,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: EnvConfig.errorColor,
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 20,
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Por favor, digite sua senha';
          }
          if (value.length < 6) {
            return 'A senha deve ter no mínimo 6 caracteres';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildActionButton() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              EnvConfig.primaryColor,
              EnvConfig.secondaryColor,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: EnvConfig.primaryColor.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _isLoading
              ? null
              : (_isPasswordStep ? _handleLogin : _handleNext),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            shadowColor: Colors.transparent,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: _isLoading
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _isPasswordStep ? 'Entrar' : 'Avançar',
                      style: GoogleFonts.inter(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      _isPasswordStep
                          ? Icons.login_rounded
                          : Icons.arrow_forward_rounded,
                      size: 22,
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return TextButton.icon(
      onPressed: _handleBack,
      icon: const Icon(Icons.arrow_back_rounded, size: 20),
      label: Text(
        'Voltar',
        style: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFF6B7280),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }

  Widget _buildForgotPassword() {
    return Center(
      child: TextButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Funcionalidade em desenvolvimento',
                style: GoogleFonts.inter(),
              ),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        },
        child: Text(
          'Esqueceu sua senha?',
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: EnvConfig.primaryColor,
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1.5,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  const Color(0xFFE5E7EB),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'ou',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF9CA3AF),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1.5,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFE5E7EB),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Não tem uma conta? ',
            style: GoogleFonts.inter(
              fontSize: 15,
              color: const Color(0xFF6B7280),
            ),
          ),
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Funcionalidade em desenvolvimento',
                    style: GoogleFonts.inter(),
                  ),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'Criar conta',
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: EnvConfig.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter para padrão de fundo
class BackgroundPatternPainter extends CustomPainter {
  final double animation;
  final Color color;

  BackgroundPatternPainter({
    required this.animation,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Desenhar círculos decorativos
    final circles = [
      {'x': 0.1, 'y': 0.2, 'r': 100.0},
      {'x': 0.9, 'y': 0.3, 'r': 150.0},
      {'x': 0.2, 'y': 0.8, 'r': 120.0},
      {'x': 0.8, 'y': 0.7, 'r': 80.0},
    ];

    for (var circle in circles) {
      final x = size.width * (circle['x'] as double);
      final y = size.height * (circle['y'] as double) + (animation * 50);
      final r = circle['r'] as double;
      canvas.drawCircle(Offset(x, y), r, paint);
    }
  }

  @override
  bool shouldRepaint(BackgroundPatternPainter oldDelegate) {
    return animation != oldDelegate.animation;
  }
}
