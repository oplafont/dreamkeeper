import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showError('Please fill in all fields');
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!success && mounted) {
      _showError(authProvider.error ?? 'Sign in failed');
    }
  }

  Future<void> _signUp() async {
    if (_emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _fullNameController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      _showError('Please fill in all fields');
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showError('Passwords do not match');
      return;
    }

    if (_passwordController.text.length < 6) {
      _showError('Password must be at least 6 characters');
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      fullName: _fullNameController.text.trim(),
    );

    if (!success && mounted) {
      _showError(authProvider.error ?? 'Sign up failed');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _clearFormFields() {
    _emailController.clear();
    _passwordController.clear();
    _fullNameController.clear();
    _confirmPasswordController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.darkTheme.colorScheme.primary,
              AppTheme.darkTheme.colorScheme.secondary,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.w),
                child: Column(
                  children: [
                    SizedBox(height: 2.h),
                    Container(
                      padding: EdgeInsets.all(2.5.w),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withAlpha(26),
                      ),
                      child: Icon(
                        Icons.nightlight_rounded,
                        size: 8.w,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 1.5.h),
                    Text(
                      'DreamKeeper',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      'Remember your nights, decode your days',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withAlpha(204),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 2.h),

              // Auth Form Card
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Tab Bar
                      Container(
                        margin: EdgeInsets.fromLTRB(4.w, 3.w, 4.w, 2.w),
                        padding: EdgeInsets.all(1.w),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.grey.shade50,
                          border: Border.all(
                            color: Colors.grey.shade200,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            _buildTabButton('Sign In', 0),
                            _buildTabButton('Sign Up', 1),
                          ],
                        ),
                      ),

                      // Tab Content
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [_buildSignInForm(), _buildSignUpForm()],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton(String label, int index) {
    final isSelected = _tabController.index == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          _tabController.animateTo(index);
          _clearFormFields();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: EdgeInsets.symmetric(vertical: 2.5.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: isSelected
                ? AppTheme.darkTheme.colorScheme.primary
                : Colors.transparent,
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppTheme.darkTheme.colorScheme.primary.withAlpha(77),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: isSelected ? Colors.white : Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignInForm() {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Demo Credentials Section
              Container(
                padding: EdgeInsets.all(2.5.w),
                margin: EdgeInsets.only(bottom: 1.5.h),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue.shade50,
                      Colors.blue.shade100.withAlpha(128),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade300, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(1.5.w),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade700,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.info_outline,
                            color: Colors.white,
                            size: 3.5.w,
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          'Demo Credentials',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Colors.blue.shade900,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 1.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 2.w,
                        vertical: 0.8.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(179),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'dreamer@example.com / dreampass123',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.blue.shade900,
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Separator
              Padding(
                padding: EdgeInsets.symmetric(vertical: 1.5.h),
                child: Row(
                  children: [
                    Expanded(
                      child: Divider(color: Colors.grey.shade300, thickness: 1),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 2.w),
                      child: Text(
                        'Sign In to Continue',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(color: Colors.grey.shade300, thickness: 1),
                    ),
                  ],
                ),
              ),

              _buildTextField(
                controller: _emailController,
                label: 'Email Address',
                hint: 'your.email@example.com',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
              ),

              SizedBox(height: 1.5.h),

              _buildTextField(
                controller: _passwordController,
                label: 'Password',
                hint: 'Enter your password',
                icon: Icons.lock_outline,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _signIn(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),

              SizedBox(height: 2.5.h),

              SizedBox(
                height: 5.5.h,
                child: ElevatedButton(
                  onPressed: auth.isLoading ? null : _signIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.darkTheme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    elevation: 3,
                    shadowColor: AppTheme.darkTheme.colorScheme.primary.withAlpha(128),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: auth.isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Sign In'),
                ),
              ),

              SizedBox(height: 1.5.h),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSignUpForm() {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 1.h),

              _buildTextField(
                controller: _fullNameController,
                label: 'Full Name',
                hint: 'How should we greet you?',
                icon: Icons.person_outline,
                textInputAction: TextInputAction.next,
              ),

              SizedBox(height: 1.5.h),

              _buildTextField(
                controller: _emailController,
                label: 'Email Address',
                hint: 'your.email@example.com',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
              ),

              SizedBox(height: 1.5.h),

              _buildTextField(
                controller: _passwordController,
                label: 'Password',
                hint: 'Min. 6 characters',
                icon: Icons.lock_outline,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.next,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),

              SizedBox(height: 1.5.h),

              _buildTextField(
                controller: _confirmPasswordController,
                label: 'Confirm Password',
                hint: 'Enter password again',
                icon: Icons.lock_outline,
                obscureText: _obscureConfirmPassword,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _signUp(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: () => setState(
                    () => _obscureConfirmPassword = !_obscureConfirmPassword,
                  ),
                ),
              ),

              SizedBox(height: 2.5.h),

              SizedBox(
                height: 5.5.h,
                child: ElevatedButton(
                  onPressed: auth.isLoading ? null : _signUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.darkTheme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: auth.isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Create Account'),
                ),
              ),

              SizedBox(height: 1.5.h),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    bool obscureText = false,
    Widget? suffixIcon,
    void Function(String)? onSubmitted,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppTheme.darkTheme.colorScheme.primary,
            width: 2,
          ),
        ),
      ),
    );
  }
}
