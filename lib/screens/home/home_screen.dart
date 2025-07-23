import 'package:flutter/material.dart';
import 'package:tabib/profile_screen.dart';
import 'package:tabib/screens/home/user_medicine_view.dart';
import 'package:tabib/screens/blood_donation/blood_donation_screen.dart';
import '../../core/theme/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _fabController;
  late Animation<double> _fabScale;

  final List<Widget> _screens = [
    const HomeContent(),
    const BloodDonationScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _fabScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _fabController, curve: Curves.elasticOut),
    );
    _fabController.forward();
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.1, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: _screens[_selectedIndex],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.surfaceColor.withOpacity(0.8),
              AppColors.surfaceColor,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, -10),
              spreadRadius: 0,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) {
              setState(() => _selectedIndex = index);
              _fabController.reset();
              _fabController.forward();
            },
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: const Color(0xFF0891B2),
            unselectedItemColor: AppColors.textColor.withOpacity(0.5),
            selectedFontSize: 12,
            unselectedFontSize: 11,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded),
                activeIcon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bloodtype_rounded),
                activeIcon: Icon(Icons.bloodtype),
                label: 'Blood Donation',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_rounded),
                activeIcon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  const HomeContent({Key? key}) : super(key: key);

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 1.1);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> banners = [
      {
        'image': 'assets/images/banner1.png',
        'title': 'Health at Your Fingertips',
        'subtitle': 'Complete healthcare solutions'
      },
      {
        'image': 'assets/images/banner2.png',
        'title': 'Save Lives, Donate Blood',
        'subtitle': 'Be a hero in someone\'s story'
      },
      {
        'image': 'assets/images/banner3.png',
        'title': 'Expert Care Always',
        'subtitle': 'Professional medical assistance'
      },
    ];

    final List<Map<String, dynamic>> services = [
      {
        'icon': Icons.local_pharmacy_rounded,
        'title': 'Purchase Medicine',
        'subtitle': 'Order tablets, syrups, and more.',
        'color': const Color(0xFF0891B2),
        'lightColor': const Color(0xFF0891B2).withOpacity(0.1),
        'onTap': () {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const UserMedicineView()));
        },
      },
      {
        'icon': Icons.bloodtype_rounded,
        'title': 'Blood Donation',
        'subtitle': 'Donate or request blood easily.',
        'color': const Color(0xFF0B7285),
        'lightColor': const Color(0xFF0B7285).withOpacity(0.1),
        'onTap': () {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const BloodDonationScreen()));
        },
      },
      {
        'icon': Icons.medical_services_rounded,
        'title': 'Book Doctor Appointment',
        'subtitle': 'Find and book doctors quickly.',
        'color': const Color(0xFF0E7490),
        'lightColor': const Color(0xFF0E7490).withOpacity(0.1),
        'onTap': () {
          // Add your navigation logic here
        },
      },
      {
        'icon': Icons.monitor_heart_rounded,
        'title': 'Blood Sugar Checkup',
        'subtitle': 'Track and manage sugar levels.',
        'color': const Color(0xFF0891B2),
        'lightColor': const Color(0xFF0891B2).withOpacity(0.1),
        'onTap': () {
          // Add your navigation logic here
        },
      },
    ];

    return SafeArea(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Enhanced Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Text(
                        //   'Welcome Back!',
                        //   style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        //         color: AppColors.textColor,
                        //         fontWeight: FontWeight.w800,
                        //         letterSpacing: -0.5,
                        //       ),
                        // ),
                        const SizedBox(height: 4),
                        Text(
                          'How can we help you today?',
                          style: TextStyle(
                            color: AppColors.textColor.withOpacity(0.6),
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF0891B2).withOpacity(0.1),
                            const Color(0xFF0891B2).withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF0891B2).withOpacity(0.1),
                        ),
                      ),
                      child: IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.notifications_rounded,
                          color: const Color(0xFF0891B2),
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),

                // Enhanced Image Carousel
                SizedBox(
                  height: 250,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: banners.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemBuilder: (_, index) {
                      return AnimatedBuilder(
                        animation: _pageController,
                        builder: (context, child) {
                          double value = 1.0;
                          if (_pageController.position.haveDimensions) {
                            value = _pageController.page! - index;
                            value = (1 - (value.abs() * 0.15)).clamp(0.0, 1.0);
                          }
                          
                          return Transform.scale(
                            scale: value,
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    const Color(0xFF0B7285),
                                    const Color(0xFF0891B2),
                                    const Color(0xFF0E7490),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF0891B2).withOpacity(0.3),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                    spreadRadius: -5,
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(24),
                                child: Stack(
                                  children: [
                                    // Background Image
                                    Positioned.fill(
                                      child: Image.asset(
                                        banners[index]['image']!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                                colors: [
                                                  AppColors.primaryColor.withOpacity(0.7),
                                                  AppColors.primaryColor,
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    // Gradient Overlay
                                    Positioned.fill(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Colors.transparent,
                                              Colors.black.withOpacity(0.6),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Content
                                    Positioned(
                                      bottom: 20,
                                      left: 20,
                                      right: 20,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            banners[index]['title']!,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            banners[index]['subtitle']!,
                                            style: TextStyle(
                                              color: Colors.white.withOpacity(0.9),
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // Page Indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: banners.asMap().entries.map((entry) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: _currentPage == entry.key ? 24 : 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: _currentPage == entry.key
                            ? const Color(0xFF0891B2)
                            : const Color(0xFF0891B2).withOpacity(0.3),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 32),

                Text(
                  'What We Offer',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.textColor,
                        letterSpacing: -0.5,
                      ),
                ),

                const SizedBox(height: 20),

                // Enhanced Service Cards
                ...services.asMap().entries.map(
                  (entry) => TweenAnimationBuilder(
                    duration: Duration(milliseconds: 600 + (entry.key * 200)),
                    tween: Tween<double>(begin: 0.0, end: 1.0),
                    builder: (context, double value, child) {
                      return Transform.translate(
                        offset: Offset(0, (1 - value) * 50),
                        child: Opacity(
                          opacity: value,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: GestureDetector(
                              onTap: entry.value['onTap'],
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: entry.value['lightColor'],
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: entry.value['color'].withOpacity(0.1),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: entry.value['color'].withOpacity(0.1),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                      spreadRadius: -8,
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            entry.value['color'],
                                            entry.value['color'].withOpacity(0.8),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: entry.value['color'].withOpacity(0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        entry.value['icon'],
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            entry.value['title'],
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: -0.2,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            entry.value['subtitle'],
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: AppColors.textColor.withOpacity(0.6),
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: entry.value['color'].withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        size: 14,
                                        color: entry.value['color'],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}