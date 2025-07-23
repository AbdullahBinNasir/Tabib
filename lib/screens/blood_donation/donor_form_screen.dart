import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/custom_input_field.dart';
import '../../services/donor_service.dart'; // Added missing import

class DonorFormScreen extends StatefulWidget {
  const DonorFormScreen({Key? key}) : super(key: key);

  @override
  State<DonorFormScreen> createState() => _DonorFormScreenState();
}

class _DonorFormScreenState extends State<DonorFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final DonorService _donorService = DonorService(); // Instantiate DonorService
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _ageController = TextEditingController();
  final _cnicController = TextEditingController();
  final _cityController = TextEditingController();
  final _areaController = TextEditingController();

  String? _selectedBloodGroup;
  String? _selectedGender;
  // Removed unused variable String? _selectedCountry;

  final List<String> _bloodGroups = [
    'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'
  ];

  final List<String> _genders = ['Male', 'Female', 'Other'];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    _cnicController.dispose();
    _cityController.dispose();
    _areaController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      // Collect data from controllers and dropdowns
      final name = _nameController.text;
      final email = _emailController.text;
      final phoneNumber = _phoneController.text;
      final age = int.tryParse(_ageController.text);
      final cnicNumber = _cnicController.text;
      final city = _cityController.text;
      final area = _areaController.text;
      final bloodGroup = _selectedBloodGroup;
      final gender = _selectedGender;

      // Basic validation for dropdowns and age
      if (age == null || bloodGroup == null || gender == null) {
         ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all required fields correctly.')),
        );
        return;
      }

      // Optionally show a loading indicator
      // setState(() { _isLoading = true; });

      try {
        // TODO: Replace with actual userId from authentication
        // Using email as a placeholder userId for now.
        // In a real app, you would use the authenticated user's ID.
        final userId = email;

        await _donorService.registerDonor(
          userId: userId,
          name: name,
          email: email,
          bloodGroup: bloodGroup,
          age: age,
          cnicNumber: cnicNumber,
          phoneNumber: phoneNumber,
          gender: gender,
          city: city,
          area: area,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Donor registered successfully!')),
        );
        Navigator.pop(context); // Navigate back after successful submission

      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error registering donor: \$e')),
        );
      } finally {
         // Optionally hide loading indicator
         // setState(() { _isLoading = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Become a Donor'),
        backgroundColor: AppColors.primaryColor,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CustomInputField(
                  label: 'Full Name',
                  hint: 'Enter your full name',
                  controller: _nameController,
                  validator: (value) =>
                      value?.isEmpty == true ? 'Please enter your name' : null,
                ),
                CustomInputField(
                  label: 'Email',
                  hint: 'Enter your email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value?.isEmpty == true) return 'Please enter your email';
                    if (!value!.contains('@')) return 'Please enter a valid email';
                    return null;
                  },
                ),
                _buildDropdownField(
                  'Blood Group',
                  _selectedBloodGroup,
                  _bloodGroups,
                  (value) => setState(() => _selectedBloodGroup = value),
                ),
                CustomInputField(
                  label: 'Age',
                  hint: 'Enter your age',
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isEmpty == true) return 'Please enter your age';
                    final age = int.tryParse(value!);
                    if (age == null || age < 18) {
                      return 'You must be at least 18 years old';
                    }
                    return null;
                  },
                ),
                CustomInputField(
                  label: 'CNIC Number',
                  hint: 'Enter your CNIC number',
                  controller: _cnicController,
                  validator: (value) =>
                      value?.isEmpty == true ? 'Please enter your CNIC number' : null,
                ),
                CustomInputField(
                  label: 'Phone Number',
                  hint: 'Enter your phone number',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  validator: (value) =>
                      value?.isEmpty == true ? 'Please enter your phone number' : null,
                ),
                _buildDropdownField(
                  'Gender',
                  _selectedGender,
                  _genders,
                  (value) => setState(() => _selectedGender = value),
                ),
                CustomInputField(
                  label: 'City',
                  hint: 'Enter your city',
                  controller: _cityController,
                  validator: (value) =>
                      value?.isEmpty == true ? 'Please enter your city' : null,
                ),
                CustomInputField(
                  label: 'Area',
                  hint: 'Enter your area',
                  controller: _areaController,
                  validator: (value) =>
                      value?.isEmpty == true ? 'Please enter your area' : null,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Submit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField(
    String label,
    String? value,
    List<String> items,
    void Function(String?) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textColor,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: value,
            items: items
                .map((item) => DropdownMenuItem(
                      value: item,
                      child: Text(item),
                    ))
                .toList(),
            onChanged: onChanged,
            validator: (value) =>
                value == null ? 'Please select ${label.toLowerCase()}' : null,
            decoration: InputDecoration(
              hintText: 'Select ${label.toLowerCase()}',
              hintStyle: TextStyle(
                color: AppColors.textColor.withOpacity(0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

