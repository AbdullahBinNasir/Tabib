import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../services/donor_service.dart';

class DonorListScreen extends StatefulWidget {
  const DonorListScreen({Key? key}) : super(key: key);

  @override
  State<DonorListScreen> createState() => _DonorListScreenState();
}

class _DonorListScreenState extends State<DonorListScreen> {
  String? _selectedBloodGroup = 'All';
  String? _selectedGender = 'All';
  String? _selectedCity = 'All';
  List<Map<String, dynamic>> _donors = [];
  bool _isLoading = true;
  final DonorService _donorService = DonorService();

  final List<String> _bloodGroups = [
    'All', 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'
  ];
  final List<String> _genders = ['All', 'Male', 'Female', 'Other'];
  final List<String> _cities = ['All', 'Karachi', 'Lahore', 'Islamabad'];

  @override
  void initState() {
    super.initState();
    _fetchDonors();
  }

  Future<void> _fetchDonors() async {
    setState(() => _isLoading = true);
    try {
      _donors = await _donorService.getDonors(
        bloodGroup: _selectedBloodGroup == 'All' ? null : _selectedBloodGroup,
        gender: _selectedGender == 'All' ? null : _selectedGender,
        city: _selectedCity == 'All' ? null : _selectedCity,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching donors: \$e')),
      );
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Donors'),
        backgroundColor: AppColors.primaryColor,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildFilter(
                    'Blood Group',
                    _selectedBloodGroup,
                    _bloodGroups,
                    (value) {
                    setState(() => _selectedBloodGroup = value);
                    _fetchDonors();
                  },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildFilter(
                    'Gender',
                    _selectedGender,
                    _genders,
                    (value) {
                    setState(() => _selectedGender = value);
                    _fetchDonors();
                  },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildFilter(
                    'City',
                    _selectedCity,
                    _cities,
                    (value) {
                    setState(() => _selectedCity = value);
                    _fetchDonors();
                  },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _isLoading ? 1 : _donors.length,
              itemBuilder: (context, index) {
                if (_isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                final donor = _donors[index];
                return _DonorCard(
                  name: donor['name'] ?? '',
                  bloodGroup: donor['bloodGroup'] ?? '',
                  city: donor['city'] ?? '',
                  onTap: () => _showDonorDetails(context, donor),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilter(
    String label,
    String? value,
    List<String> items,
    void Function(String?) onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: value ?? 'All',
      items: items
          .map((item) => DropdownMenuItem(
                value: item,
                child: Text(item, style: const TextStyle(fontSize: 14)),
              ))
          .toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _showDonorDetails(BuildContext context, Map<String, dynamic> donor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                'Donor Details',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.textColor,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 24),
              _buildDetailItem('Name', donor['name'] ?? ''),
              _buildDetailItem('Blood Group', donor['bloodGroup'] ?? ''),
              _buildDetailItem('Age', donor['age']?.toString() ?? ''),
              _buildDetailItem('Gender', donor['gender'] ?? ''),
              _buildDetailItem('City', donor['city'] ?? ''),
              _buildDetailItem('Area', donor['area'] ?? ''),
              _buildDetailItem('Phone', donor['phoneNumber'] ?? ''),
              _buildDetailItem('Email', donor['email'] ?? ''),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Implement contact donor functionality
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Contact Donor'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textColor.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _DonorCard extends StatelessWidget {
  final String name;
  final String bloodGroup;
  final String city;
  final VoidCallback onTap;

  const _DonorCard({
    Key? key,
    required this.name,
    required this.bloodGroup,
    required this.city,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Center(
                  child: Text(
                    bloodGroup,
                    style: TextStyle(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      city,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textColor.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.textColor.withOpacity(0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}