import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/schemes_provider.dart';
import '../../../../core/theme/theme.dart';

class SchemesScreen extends StatelessWidget {
  const SchemesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final provider = Provider.of<SchemesProvider>(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('Government Schemes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync, color: AppTheme.emeraldGreen),
            onPressed: () => provider.fetchSchemes(),
          ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.emeraldGreen))
          : ListView.builder(
              padding: const EdgeInsets.all(24.0),
              itemCount: provider.schemes.length,
              itemBuilder: (context, index) {
                final scheme = provider.schemes[index];
                return FadeInUp(
                  duration: const Duration(milliseconds: 400),
                  child: _buildSchemeCard(context, scheme, provider, theme, isDark),
                );
              },
            ),
    );
  }

  Widget _buildSchemeCard(
    BuildContext context,
    SchemeItem scheme,
    SchemesProvider provider,
    ThemeData theme,
    bool isDark,
  ) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row: Emoji, Title, Category Badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.emeraldGreen.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(scheme.emoji, style: const TextStyle(fontSize: 22)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        scheme.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.emeraldGreen.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          scheme.category,
                          style: GoogleFonts.outfit(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.emeraldGreen,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Description
            Text(
              scheme.description,
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.4,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),

            // Benefits Section
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('🎁 ', style: TextStyle(fontSize: 14)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Benefits',
                        style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.emeraldGreen, fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        scheme.benefits,
                        style: theme.textTheme.bodySmall?.copyWith(height: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Eligibility Section
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('ℹ️ ', style: TextStyle(fontSize: 14)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Eligibility',
                        style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.soilAmber, fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        scheme.eligibility,
                        style: theme.textTheme.bodySmall?.copyWith(height: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Actions: Apply Button
            SizedBox(
              width: double.infinity,
              child: scheme.isApplied
                  ? OutlinedButton.icon(
                      onPressed: null, // Disabled
                      icon: const Icon(Icons.check_circle, color: Colors.green),
                      label: Text(
                        'Applied (Pending Verification)',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        side: const BorderSide(color: Colors.green),
                      ),
                    )
                  : ElevatedButton(
                      onPressed: () {
                        provider.applyForScheme(scheme.title);
                        
                        // Show confirmation alert
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Application Success'),
                            content: Text('Your application request for ${scheme.title} has been logged. Our Agri-Officer will verify your land documents soon.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('OK', style: TextStyle(color: AppTheme.emeraldGreen)),
                              )
                            ],
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        backgroundColor: AppTheme.emeraldGreen,
                      ),
                      child: Text(
                        'Apply Now',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
