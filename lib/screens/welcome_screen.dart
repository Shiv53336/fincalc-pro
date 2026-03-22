import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/colors.dart';
import '../main.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _nameController = TextEditingController();
  int _currentPage = 0;
  bool _saving = false;

  static const _slides = [
    _SlideData(
      icon: Icons.calculate_rounded,
      title: 'Your complete financial toolkit',
      subtitle: '21 calculators. Tax, loans, investments — all in one place.',
    ),
    _SlideData(
      icon: Icons.trending_up_rounded,
      title: 'Smart decisions, not guesswork',
      subtitle: 'SIP, EMI, tax savings — see real numbers in seconds.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    setState(() => _saving = true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);
    await prefs.setBool('onboarding_complete', true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
    );
  }

  void _skip() {
    _pageController.animateToPage(
      2,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _next() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Stack(
          children: [
            // Skip button
            Positioned(
              top: 8,
              right: 16,
              child: _currentPage < 2
                  ? TextButton(
                      onPressed: _skip,
                      child: const Text('Skip', style: TextStyle(color: AppColors.textLight, fontSize: 14)),
                    )
                  : const SizedBox.shrink(),
            ),

            Column(
              children: [
                // PageView
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (i) => setState(() => _currentPage = i),
                    children: [
                      ..._slides.map((s) => _SlidePage(data: s)),
                      _NameInputPage(controller: _nameController),
                    ],
                  ),
                ),

                // Dot indicator
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (i) {
                      final isActive = i == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: isActive ? 20 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isActive ? AppColors.primary : AppColors.border,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                ),

                // Action button
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: SizedBox(
                    width: double.infinity,
                    child: _currentPage < 2
                        ? ElevatedButton(
                            onPressed: _next,
                            child: const Text('Next'),
                          )
                        : ListenableBuilder(
                            listenable: _nameController,
                            builder: (_, __) => ElevatedButton(
                              onPressed: (_nameController.text.trim().isEmpty || _saving) ? null : _finish,
                              child: _saving
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                    )
                                  : const Text('Get Started'),
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SlideData {
  final IconData icon;
  final String title;
  final String subtitle;
  const _SlideData({required this.icon, required this.title, required this.subtitle});
}

class _SlidePage extends StatelessWidget {
  final _SlideData data;
  const _SlidePage({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 40, 32, 0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(data.icon, color: Colors.white, size: 40),
          ),
          const SizedBox(height: 36),
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.text, height: 1.3),
          ),
          const SizedBox(height: 14),
          Text(
            data.subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 15, color: AppColors.textMed, height: 1.6),
          ),
        ],
      ),
    );
  }
}

class _NameInputPage extends StatelessWidget {
  final TextEditingController controller;
  const _NameInputPage({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 40, 32, 0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(Icons.person_rounded, color: Colors.white, size: 40),
          ),
          const SizedBox(height: 36),
          const Text(
            'What should we call you?',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.text, height: 1.3),
          ),
          const SizedBox(height: 10),
          const Text(
            "We'll personalise your experience.",
            style: TextStyle(fontSize: 15, color: AppColors.textMed, height: 1.6),
          ),
          const SizedBox(height: 28),
          TextField(
            controller: controller,
            autofocus: false,
            textCapitalization: TextCapitalization.words,
            keyboardType: TextInputType.name,
            style: const TextStyle(fontSize: 16, color: AppColors.text),
            decoration: InputDecoration(
              hintText: 'Your first name',
              hintStyle: const TextStyle(color: AppColors.textLight),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.accent, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
