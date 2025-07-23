import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'donor_form_screen.dart';
import 'donor_list_screen.dart';

class BloodDonationScreen extends StatelessWidget {
  const BloodDonationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Blood Donation',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.textColor,
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            _OptionCard(
              title: 'Become a Donor',
              description: 'Register yourself as a blood donor',
              icon: Icons.favorite,
              color: AppColors.primaryColor,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DonorFormScreen()),
              ),
            ),
            const SizedBox(height: 16),
            _OptionCard(
              title: 'Request Blood',
              description: 'Find blood donors near you',
              icon: Icons.search,
              color: AppColors.secondaryColor,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DonorListScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _OptionCard({
    Key? key,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppColors.textColor,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textColor.withOpacity(0.7),
                          ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: AppColors.textColor.withOpacity(0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}