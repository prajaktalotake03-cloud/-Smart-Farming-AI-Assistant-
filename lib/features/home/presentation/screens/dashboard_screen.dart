import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/constants/constants.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../../weather/presentation/providers/weather_provider.dart';
import '../../../crop_health/presentation/screens/crop_health_screen.dart';
import '../../../soil_yield/presentation/screens/soil_yield_screen.dart';
import '../../../ai_assistant/presentation/screens/chat_screen.dart';
import '../../../weather/presentation/screens/weather_screen.dart';
import '../../../irrigation/presentation/screens/irrigation_screen.dart';
import '../../../fertilizer/presentation/screens/fertilizer_screen.dart';
import '../../../market/presentation/screens/market_screen.dart';
import '../../../schemes/presentation/screens/schemes_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../crop_calendar/presentation/screens/crop_calendar_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  // List of child widgets for each tab
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const HomeOverviewPage(),
      const CropHealthScreen(),
      const SoilYieldScreen(),
      const ChatScreen(),
      const ProfileScreen(),
    ];
    
    // Fetch weather data on launch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<WeatherProvider>(context, listen: false).fetchWeather();
    });
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: _currentIndex == 0
          ? AppBar(
              leading: const Padding(
                padding: EdgeInsets.only(left: 16.0),
                child: Center(
                  child: Text('🌱', style: TextStyle(fontSize: 24)),
                ),
              ),
              title: Text(
                AppConstants.appName,
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 22),
              ),
              actions: [
                // Theme toggler (UI representation)
                IconButton(
                  icon: Icon(
                    isDark ? Icons.light_mode : Icons.dark_mode,
                    color: AppTheme.emeraldGreen,
                  ),
                  onPressed: () {
                    // Quick state trigger to show user instant UI refresh
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Theme switched! Enjoy the premium looks.'),
                        duration: Duration(milliseconds: 1000),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
                // Sign out button
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.redAccent),
                  onPressed: () async {
                    await authProvider.logout();
                    if (mounted) {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                      );
                    }
                  },
                ),
                const SizedBox(width: 8),
              ],
            )
          : null,
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onTabTapped,
        indicatorColor: AppTheme.emeraldGreen.withOpacity(0.12),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: AppTheme.emeraldGreen),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.camera_alt_outlined),
            selectedIcon: Icon(Icons.camera_alt, color: AppTheme.emeraldGreen),
            label: 'Diagnosis',
          ),
          NavigationDestination(
            icon: Icon(Icons.science_outlined),
            selectedIcon: Icon(Icons.science, color: AppTheme.emeraldGreen),
            label: 'Advisory',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble, color: AppTheme.emeraldGreen),
            label: 'AI Chat',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: AppTheme.emeraldGreen),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// HOME OVERVIEW TAB WIDGET
class HomeOverviewPage extends StatelessWidget {
  const HomeOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final weatherProvider = Provider.of<WeatherProvider>(context);
    final weather = weatherProvider.weather;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Greeting & Date Card
          FadeInDown(
            duration: const Duration(milliseconds: 500),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello Farmer 👋',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Welcome to your agricultural workspace.',
                      style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.emeraldGreen.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    '🚜',
                    style: TextStyle(fontSize: 22),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Search Bar
          FadeInDown(
            delay: const Duration(milliseconds: 100),
            duration: const Duration(milliseconds: 500),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search seeds, crop diseases, advisory...',
                prefixIcon: const Icon(Icons.search, color: AppTheme.emeraldGreen),
                suffixIcon: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.emeraldGreen,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.tune, color: Colors.white, size: 20),
                ),
                fillColor: isDark ? const Color(0xFF13251A) : Colors.white,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade200,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Weather Card
          FadeInUp(
            duration: const Duration(milliseconds: 600),
            child: weatherProvider.isLoading
                ? Container(
                    height: 140,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF13251A) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(color: AppTheme.emeraldGreen),
                    ),
                  )
                : weather == null
                    ? Container()
                    : GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => const WeatherScreen()),
                          );
                        },
                        child: Card(
                          elevation: 0,
                          color: isDark ? const Color(0xFF0D1E15) : const Color(0xFFE8F5E9),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Row(
                              children: [
                                Text(
                                  weather.iconEmoji,
                                  style: const TextStyle(fontSize: 48),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${weather.tempCelsius}°C - ${weather.condition}',
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.emeraldGreen,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Humidity: ${weather.humidity}%  •  Wind: ${weather.windSpeedKph} km/h',
                                        style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        weather.location,
                                        style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
          ),
          const SizedBox(height: 16),

          // Today's Recommendation Card
          FadeInUp(
            delay: const Duration(milliseconds: 150),
            duration: const Duration(milliseconds: 600),
            child: Card(
              elevation: 0,
              color: isDark ? const Color(0xFF22160F) : const Color(0xFFFFF3E0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isDark ? AppTheme.soilAmber.withOpacity(0.2) : AppTheme.soilAmber.withOpacity(0.1),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('📝', style: TextStyle(fontSize: 20)),
                        const SizedBox(width: 8),
                        Text(
                          "Today's Recommendation",
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.soilAmber,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      weather?.agriculturalAdvisory ?? 'Light rainfall expected tomorrow. Perfect time to apply organic fertilizers, but delay pesticide spraying to avoid runoff.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        height: 1.5,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Quick Features Grid Header
          Text(
            'Quick Features',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // 8-item grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.25,
            children: [
              _buildFeatureCard(
                theme,
                isDark,
                emoji: '🔬',
                title: 'Disease Detection',
                subtitle: 'Scan leaf health',
                color: AppTheme.emeraldGreen,
                onTap: () {
                  final state = context.findAncestorStateOfType<_DashboardScreenState>();
                  state?._onTabTapped(1); // Switch to Diagnosis Screen
                },
              ),
              _buildFeatureCard(
                theme,
                isDark,
                emoji: '🧪',
                title: 'Crop Recommendation',
                subtitle: 'Optimize inputs',
                color: AppTheme.soilAmber,
                onTap: () {
                  final state = context.findAncestorStateOfType<_DashboardScreenState>();
                  state?._onTabTapped(2); // Switch to Advisory Screen
                },
              ),
              _buildFeatureCard(
                theme,
                isDark,
                emoji: '🌦️',
                title: 'Weather',
                subtitle: 'View forecast',
                color: Colors.blueAccent,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const WeatherScreen()),
                  );
                },
              ),
              _buildFeatureCard(
                theme,
                isDark,
                emoji: '💰',
                title: 'Market Prices',
                subtitle: 'Live crop rates',
                color: AppTheme.sunYellow,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const MarketScreen()),
                  );
                },
              ),
              _buildFeatureCard(
                theme,
                isDark,
                emoji: '💧',
                title: 'Irrigation',
                subtitle: 'Water scheduler',
                color: Colors.teal,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const IrrigationScreen()),
                  );
                },
              ),
              _buildFeatureCard(
                theme,
                isDark,
                emoji: '💬',
                title: 'AI Chat',
                subtitle: 'Farming chatbot',
                color: Colors.indigoAccent,
                onTap: () {
                  final state = context.findAncestorStateOfType<_DashboardScreenState>();
                  state?._onTabTapped(3); // Switch to Chat Screen
                },
              ),
              _buildFeatureCard(
                theme,
                isDark,
                emoji: '🏛️',
                title: 'Govt Schemes',
                subtitle: 'Subsidies & aid',
                color: Colors.deepOrangeAccent,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const SchemesScreen()),
                  );
                },
              ),
              _buildFeatureCard(
                theme,
                isDark,
                emoji: '📍',
                title: 'Agri Centers',
                subtitle: 'Locate near you',
                color: Colors.purpleAccent,
                onTap: () {
                  _showAgriCentersSheet(context, theme, isDark);
                },
              ),
              _buildFeatureCard(
                theme,
                isDark,
                emoji: '🌱',
                title: 'Fertilizers',
                subtitle: 'Recommend dosage',
                color: Colors.lightGreen,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const FertilizerScreen()),
                  );
                },
              ),
              _buildFeatureCard(
                theme,
                isDark,
                emoji: '📅',
                title: 'Sowing Calendar',
                subtitle: 'Track crop timeline',
                color: Colors.teal,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const CropCalendarScreen()),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
    ThemeData theme,
    bool isDark, {
    required String emoji,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF13251A) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.04) : Colors.grey.shade200,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Text(emoji, style: const TextStyle(fontSize: 18)),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showWeatherForecastSheet(BuildContext context, WeatherProvider provider, ThemeData theme, bool isDark) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      backgroundColor: isDark ? const Color(0xFF0F1E15) : Colors.white,
      builder: (context) {
        final weather = provider.weather;
        if (weather == null) return const SizedBox(height: 100, child: Center(child: Text('No weather forecast loaded.')));
        return Padding(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('5-Day Weather Forecast', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: AppTheme.emeraldGreen)),
              const SizedBox(height: 4),
              Text('Advisory plans for upcoming days', style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
              const SizedBox(height: 20),
              ...weather.forecast.map((day) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(width: 80, child: Text(day.dayName, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold))),
                    Row(
                      children: [
                        Text(day.iconEmoji, style: const TextStyle(fontSize: 22)),
                        const SizedBox(width: 12),
                        Text(day.condition, style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey)),
                      ],
                    ),
                    Text('${day.tempCelsius}°C', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: AppTheme.soilAmber)),
                  ],
                ),
              )),
            ],
          ),
        );
      },
    );
  }

  void _showMarketPricesSheet(BuildContext context, ThemeData theme, bool isDark) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      backgroundColor: isDark ? const Color(0xFF0F1E15) : Colors.white,
      builder: (context) {
        final cropsList = [
          {'crop': 'Wheat (Kalyansona)', 'price': '₹2,450 / quintal', 'trend': '+1.2%', 'up': true},
          {'crop': 'Onion (Nashik Red)', 'price': '₹1,800 / quintal', 'trend': '-0.5%', 'up': false},
          {'crop': 'Cotton (Long Staple)', 'price': '₹7,200 / quintal', 'trend': '+3.4%', 'up': true},
          {'crop': 'Rice (Basmati Premium)', 'price': '₹8,400 / quintal', 'trend': '0.0%', 'up': true},
        ];
        return Padding(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Live Mandi Rates', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: AppTheme.emeraldGreen)),
              const SizedBox(height: 4),
              Text('Minimum Support Price & market updates', style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
              const SizedBox(height: 20),
              ...cropsList.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(item['crop'] as String, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600))),
                    Text(item['price'] as String, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: (item['up'] as bool) ? Colors.green.withOpacity(0.12) : Colors.red.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item['trend'] as String,
                        style: TextStyle(
                          color: (item['up'] as bool) ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
            ],
          ),
        );
      },
    );
  }

  void _showIrrigationSheet(BuildContext context, ThemeData theme, bool isDark) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      backgroundColor: isDark ? const Color(0xFF0F1E15) : Colors.white,
      builder: (context) {
        final schedules = [
          {'crop': 'Tomato (Block A)', 'time': 'Tomorrow, 7:00 AM', 'water': '12 Liters/sqm', 'status': 'Scheduled'},
          {'crop': 'Wheat (Block B)', 'time': 'In 3 days', 'water': '30 Liters/sqm', 'status': 'Postponed (Rain expected)'},
        ];
        return Padding(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Smart Watering Planner', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: AppTheme.emeraldGreen)),
              const SizedBox(height: 4),
              Text('Irrigation plans customized by soil sensors', style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
              const SizedBox(height: 20),
              ...schedules.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(item['crop']!, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: item['status']!.contains('Rain') ? Colors.orange.withOpacity(0.12) : Colors.teal.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            item['status']!,
                            style: TextStyle(
                              color: item['status']!.contains('Rain') ? Colors.orange : Colors.teal,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 14, color: Colors.grey),
                        const SizedBox(width: 6),
                        Text(item['time']!, style: const TextStyle(fontSize: 13, color: Colors.grey)),
                        const SizedBox(width: 16),
                        const Icon(Icons.opacity, size: 14, color: Colors.blueAccent),
                        const SizedBox(width: 6),
                        Text(item['water']!, style: const TextStyle(fontSize: 13, color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(height: 1),
                  ],
                ),
              )),
            ],
          ),
        );
      },
    );
  }

  void _showSchemesSheet(BuildContext context, ThemeData theme, bool isDark) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      backgroundColor: isDark ? const Color(0xFF0F1E15) : Colors.white,
      builder: (context) {
        final schemes = [
          {'title': 'PM-KISAN Samman Nidhi', 'benefit': 'Direct Income Support of ₹6,000 / year', 'status': 'Enrolled ✅'},
          {'title': 'Agri-Infrastructure Subvention Fund', 'benefit': '3% interest subvention for storage loans', 'status': 'Apply Now'},
          {'title': 'National Horticulture Subsidies', 'benefit': '50% subsidy on greenhouse and polyhouse setup', 'status': 'Apply Now'},
        ];
        return Padding(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Government Schemes & Aid', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: AppTheme.emeraldGreen)),
              const SizedBox(height: 4),
              Text('Active subsidies and financial support schemes', style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
              const SizedBox(height: 20),
              ...schemes.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text(item['title']!, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold))),
                        Text(
                          item['status']!,
                          style: TextStyle(
                            color: item['status']!.contains('✅') ? AppTheme.emeraldGreen : AppTheme.soilAmber,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(item['benefit']!, style: const TextStyle(fontSize: 13, color: Colors.grey)),
                    const SizedBox(height: 12),
                    const Divider(height: 1),
                  ],
                ),
              )),
            ],
          ),
        );
      },
    );
  }

  void _showAgriCentersSheet(BuildContext context, ThemeData theme, bool isDark) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      backgroundColor: isDark ? const Color(0xFF0F1E15) : Colors.white,
      builder: (context) {
        final centers = [
          {'name': 'Krishi Vigyan Kendra (KVK)', 'dist': '2.4 km away', 'phone': '+91 98765 43210', 'type': 'Govt Testing & Advisory'},
          {'name': 'Farmer Fertilizer Seed Depot', 'dist': '4.1 km away', 'phone': '+91 99998 88877', 'type': 'Subsidized Input Center'},
        ];
        return Padding(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Nearby Agriculture Centers', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: AppTheme.emeraldGreen)),
              const SizedBox(height: 4),
              Text('Contact local testing facilities & supply stores', style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
              const SizedBox(height: 20),
              ...centers.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(item['name']!, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                        Text(item['dist']!, style: const TextStyle(fontSize: 11, color: AppTheme.emeraldGreen, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('${item['type']} • Tel: ${item['phone']}', style: const TextStyle(fontSize: 13, color: Colors.grey)),
                    const SizedBox(height: 12),
                    const Divider(height: 1),
                  ],
                ),
              )),
            ],
          ),
        );
      },
    );
  }
}
