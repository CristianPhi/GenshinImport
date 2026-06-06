import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AuthPage extends StatefulWidget {
  final void Function(String token, String role, int userId) onLoginSuccess;

  const AuthPage({super.key, required this.onLoginSuccess});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(60),
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Genshin Import',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      child: Column(
                        children: [
                          TabBar(
                            controller: _tabController,
                            tabs: const [
                              Tab(text: 'Login'),
                              Tab(text: 'Register'),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 320,
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                _LoginForm(onSuccess: widget.onLoginSuccess),
                                _RegisterForm(onSuccess: widget.onLoginSuccess),
                              ],
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
        ),
      ),
    );
  }
}

class _LoginForm extends StatefulWidget {
  final void Function(String token, String role, int userId) onSuccess;

  const _LoginForm({required this.onSuccess});

  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController(text: 'admin@genshinimport.com');
  final passwordController = TextEditingController(text: 'admin123');
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });

    try {
      final res = await ApiService.login(
        emailController.text.trim(),
        passwordController.text,
      );
      if (!mounted) return;
      widget.onSuccess(res['token'], res['role'], res['userId']);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: emailController,
            decoration: const InputDecoration(labelText: 'Email'),
            validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: passwordController,
            decoration: const InputDecoration(labelText: 'Password'),
            obscureText: true,
            validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null,
          ),
          if (_error != null) ...[
            const SizedBox(height: 10),
            Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 13)),
          ],
          const Spacer(),
          ElevatedButton(
            onPressed: _loading ? null : _submit,
            child: _loading
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Login'),
          ),
        ],
      ),
    );
  }
}

class _RegisterForm extends StatefulWidget {
  final void Function(String token, String role, int userId) onSuccess;

  const _RegisterForm({required this.onSuccess});

  @override
  State<_RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<_RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });

    try {
      final res = await ApiService.register(
        usernameController.text.trim(),
        emailController.text.trim(),
        passwordController.text,
      );
      if (!mounted) return;
      widget.onSuccess(res['token'], res['role'], res['userId']);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: usernameController,
            decoration: const InputDecoration(labelText: 'Username'),
            validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: emailController,
            decoration: const InputDecoration(labelText: 'Email'),
            keyboardType: TextInputType.emailAddress,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Wajib diisi';
              if (!v.contains('@')) return 'Email tidak valid';
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: passwordController,
            decoration: const InputDecoration(labelText: 'Password'),
            obscureText: true,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Wajib diisi';
              if (v.length > 30) return 'Max 30 karakter';
              return null;
            },
          ),
          if (_error != null) ...[
            const SizedBox(height: 10),
            Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 13)),
          ],
          const Spacer(),
          ElevatedButton(
            onPressed: _loading ? null : _submit,
            child: _loading
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Daftar'),
          ),
        ],
      ),
    );
  }
}
