import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loadstock/core/config/env_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  bool _isDarkMode = false;
  bool _rememberUser = false;
  
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _floatingController;
  
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _floatingAnimation;

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _floatingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _floatingAnimation = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
    _slideController.forward();
    
    // Carregar usuário salvo
    _loadSavedUser();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  bool _isValidUsername(String username) {
    return username.length >= 3;
  }

  // Carregar usuário salvo
  Future<void> _loadSavedUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedUser = prefs.getString('saved_user');
      final rememberUser = prefs.getBool('remember_user') ?? false;
      
      if (savedUser != null && rememberUser) {
        setState(() {
          _emailController.text = savedUser;
          _rememberUser = true;
        });
      }
    } catch (e) {
      debugPrint('Erro ao carregar usuário salvo: $e');
    }
  }

  // Salvar usuário
  Future<void> _saveUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_rememberUser) {
        await prefs.setString('saved_user', _emailController.text);
        await prefs.setBool('remember_user', true);
      } else {
        await prefs.remove('saved_user');
        await prefs.setBool('remember_user', false);
      }
    } catch (e) {
      debugPrint('Erro ao salvar usuário: $e');
    }
  }

  // Alternar "Lembrar usuário"
  void _toggleRememberUser(bool? value) {
    setState(() {
      _rememberUser = value ?? false;
    });
    _saveUser();
  }

  void _handleNext() {
    if (_formKey.currentState!.validate()) {
      // Salvar usuário se a opção estiver marcada
      _saveUser();
      
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

  Color get _backgroundColor => _isDarkMode ? const Color(0xFF0F172A) : Colors.white;
  Color get _textColor => _isDarkMode ? Colors.white : const Color(0xFF1F2937);
  Color get _subtitleColor => _isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF6B7280);
  Color get _inputFillColor => _isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFF9FAFB);
  Color get _borderColor => _isDarkMode ? const Color(0xFF334155) : const Color(0xFFE5E7EB);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: Stack(
        children: [
          // Background com efeitos visuais
          _buildAnimatedBackground(),
          
          // Conteúdo principal
          SafeArea(
            child: Column(
              children: [
                // Header com logo e toggle dark mode
                _buildHeader(),
                
                // Formulário centralizado
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 450),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildWelcomeText(),
                            const SizedBox(height: 40),
                            _buildForm(),
                            const SizedBox(height: 24),
                            _buildActionButton(),
                            if (_isPasswordStep) ...[
                              const SizedBox(height: 16),
                              _buildBackButton(),
                              const SizedBox(height: 16),
                              _buildForgotPassword(),
                            ],
                            if (!_isPasswordStep) ...[
                              const SizedBox(height: 32),
                              _buildDivider(),
                              const SizedBox(height: 24),
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
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _floatingAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: _isDarkMode
                  ? [
                      const Color(0xFF0F172A),
                      const Color(0xFF1E293B),
                      const Color(0xFF0F172A),
                    ]
                  : [
                      Colors.white,
                      EnvConfig.primaryColor.withValues(alpha: 0.03),
                      Colors.white,
                    ],
            ),
          ),
          child: CustomPaint(
            painter: FloatingShapesPainter(
              animation: _floatingAnimation.value,
              isDarkMode: _isDarkMode,
              primaryColor: EnvConfig.primaryColor,
            ),
            size: Size.infinite,
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Logo pequena ao lado do nome
          Container(
            width: 48,
            height: 48,
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
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                EnvConfig.logoIcon,
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            EnvConfig.appName,
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: _textColor,
              letterSpacing: -0.5,
            ),
          ),
          const Spacer(),
          // Toggle Dark Mode
          Container(
            decoration: BoxDecoration(
              color: _inputFillColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _borderColor),
            ),
            child: IconButton(
              icon: Icon(
                _isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                color: _isDarkMode ? Colors.amber : EnvConfig.primaryColor,
              ),
              onPressed: () {
                setState(() => _isDarkMode = !_isDarkMode);
              },
              tooltip: _isDarkMode ? 'Modo Claro' : 'Modo Escuro',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeText() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _isPasswordStep ? 'Bem-vindo de volta!' : 'Entrar na sua conta',
            style: GoogleFonts.inter(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: _textColor,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _isPasswordStep
                ? 'Digite sua senha para continuar'
                : 'Digite suas credenciais para acessar',
            style: GoogleFonts.inter(
              fontSize: 16,
              color: _subtitleColor,
              height: 1.5,
            ),
          ),
        ],
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
              if (!_isPasswordStep) ...[
                _buildEmailField(),
                const SizedBox(height: 12),
                _buildRememberUserCheckbox(),
              ],
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
        boxShadow: _isDarkMode
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 15,
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
          color: _textColor,
        ),
        decoration: InputDecoration(
          labelText: 'Usuário ou E-mail',
          labelStyle: GoogleFonts.inter(
            color: _subtitleColor,
            fontWeight: FontWeight.w500,
          ),
          hintText: 'Digite seu usuário ou e-mail',
          hintStyle: GoogleFonts.inter(
            color: _subtitleColor.withValues(alpha: 0.6),
            fontSize: 15,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  EnvConfig.primaryColor.withValues(alpha: 0.15),
                  EnvConfig.secondaryColor.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.person_outline_rounded,
              color: EnvConfig.primaryColor,
              size: 22,
            ),
          ),
          filled: true,
          fillColor: _inputFillColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: _borderColor, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: EnvConfig.primaryColor, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: EnvConfig.errorColor, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: EnvConfig.errorColor, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
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

  Widget _buildRememberUserCheckbox() {
    return Row(
      children: [
        SizedBox(
          height: 24,
          width: 24,
          child: Checkbox(
            value: _rememberUser,
            onChanged: _toggleRememberUser,
            activeColor: EnvConfig.primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: GestureDetector(
            onTap: () => _toggleRememberUser(!_rememberUser),
            child: Text(
              'Lembrar meu usuário',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: _subtitleColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserDisplay() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _isDarkMode
              ? [
                  EnvConfig.primaryColor.withValues(alpha: 0.15),
                  EnvConfig.secondaryColor.withValues(alpha: 0.1),
                ]
              : [
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
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  EnvConfig.primaryColor,
                  EnvConfig.secondaryColor,
                ],
              ),
              borderRadius: BorderRadius.circular(14),
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
              size: 28,
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
                    color: _subtitleColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _emailController.text,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _textColor,
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
        boxShadow: _isDarkMode
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 15,
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
          color: _textColor,
        ),
        onFieldSubmitted: (_) => _handleLogin(),
        decoration: InputDecoration(
          labelText: 'Senha',
          labelStyle: GoogleFonts.inter(
            color: _subtitleColor,
            fontWeight: FontWeight.w500,
          ),
          hintText: 'Digite sua senha',
          hintStyle: GoogleFonts.inter(
            color: _subtitleColor.withValues(alpha: 0.6),
            fontSize: 15,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  EnvConfig.primaryColor.withValues(alpha: 0.15),
                  EnvConfig.secondaryColor.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.lock_outline_rounded,
              color: EnvConfig.primaryColor,
              size: 22,
            ),
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: _subtitleColor,
            ),
            onPressed: () {
              setState(() => _obscurePassword = !_obscurePassword);
            },
          ),
          filled: true,
          fillColor: _inputFillColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: _borderColor, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: EnvConfig.primaryColor, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: EnvConfig.errorColor, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: EnvConfig.errorColor, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
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
        height: 58,
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
              offset: const Offset(0, 8),
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
                      _isPasswordStep ? 'Entrar' : 'Continuar',
                      style: GoogleFonts.inter(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Icon(
                      _isPasswordStep
                          ? Icons.login_rounded
                          : Icons.arrow_forward_rounded,
                      size: 20,
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
      icon: Icon(Icons.arrow_back_rounded, size: 20, color: _subtitleColor),
      label: Text(
        'Voltar',
        style: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: _subtitleColor,
        ),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
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
            height: 1,
            color: _borderColor,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'ou',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: _subtitleColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: _borderColor,
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
              color: _subtitleColor,
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
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
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

// Custom painter para formas flutuantes no fundo
class FloatingShapesPainter extends CustomPainter {
  final double animation;
  final bool isDarkMode;
  final Color primaryColor;

  FloatingShapesPainter({
    required this.animation,
    required this.isDarkMode,
    required this.primaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = isDarkMode
          ? primaryColor.withValues(alpha: 0.05)
          : primaryColor.withValues(alpha: 0.03);

    // Círculos flutuantes
    final circles = [
      {'x': 0.15, 'y': 0.2, 'r': 120.0},
      {'x': 0.85, 'y': 0.15, 'r': 100.0},
      {'x': 0.1, 'y': 0.7, 'r': 90.0},
      {'x': 0.9, 'y': 0.8, 'r': 110.0},
      {'x': 0.5, 'y': 0.5, 'r': 80.0},
    ];

    for (var circle in circles) {
      final x = size.width * (circle['x'] as double);
      final y = size.height * (circle['y'] as double) + animation;
      final r = circle['r'] as double;
      
      // Círculo com blur
      canvas.drawCircle(
        Offset(x, y),
        r,
        paint..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40),
      );
    }

    // Linhas decorativas
    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = isDarkMode
          ? primaryColor.withValues(alpha: 0.08)
          : primaryColor.withValues(alpha: 0.05);

    final path = Path();
    path.moveTo(0, size.height * 0.3 + animation);
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.25 + animation,
      size.width * 0.5,
      size.height * 0.3 + animation,
    );
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.35 + animation,
      size.width,
      size.height * 0.3 + animation,
    );
    canvas.drawPath(path, linePaint);

    final path2 = Path();
    path2.moveTo(0, size.height * 0.7 - animation);
    path2.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.65 - animation,
      size.width * 0.5,
      size.height * 0.7 - animation,
    );
    path2.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.75 - animation,
      size.width,
      size.height * 0.7 - animation,
    );
    canvas.drawPath(path2, linePaint);
  }

  @override
  bool shouldRepaint(FloatingShapesPainter oldDelegate) {
    return animation != oldDelegate.animation || isDarkMode != oldDelegate.isDarkMode;
  }
}
