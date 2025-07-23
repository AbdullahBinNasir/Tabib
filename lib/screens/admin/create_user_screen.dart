import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../widgets/custom_input_field.dart';

class CreateUserScreen extends StatefulWidget {
  static const List<String> occupations = [
    'Heart Specialist',
    'Neuro Surgeon',
    'Child Specialist',
    'Pulmonologist',
  ];

  const CreateUserScreen({Key? key}) : super(key: key);

  @override
  State<CreateUserScreen> createState() => _CreateUserScreenState();
}

class _CreateUserScreenState extends State<CreateUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _ageController = TextEditingController();
  final _roleController = TextEditingController();
  String? _selectedOccupation;

  File? _profilePictureFile;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _ageController.dispose();
    _roleController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profilePictureFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text;
      final email = _emailController.text;
      final password = _passwordController.text;
      final age = _ageController.text;
      final occupation = _selectedOccupation;
      final role = _roleController.text;

      print('Submitting user data:');
      print('Name: $name');
      print('Email: $email');
      print('Password: $password');
      print('Age: $age');
      print('Occupation: $occupation');
      print('Role: $role');
      print('Profile Picture: $_profilePictureFile');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User creation initiated...')),
      );

      // Navigator.pop(context); // Add navigation logic after success
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New User'),
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
                // Profile Picture Preview
                Center(
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: _profilePictureFile != null
                        ? FileImage(_profilePictureFile!)
                        : null,
                    backgroundColor: Colors.grey.shade300,
                    child: _profilePictureFile == null
                        ? Icon(Icons.person, size: 60, color: Colors.grey.shade700)
                        : null,
                  ),
                ),
                const SizedBox(height: 12),
                // Pick Image Button
                ElevatedButton(
                  onPressed: _pickImage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Pick Profile Picture'),
                ),
                const SizedBox(height: 16),

                CustomInputField(
                  label: 'Full Name',
                  hint: 'Enter full name',
                  controller: _nameController,
                  validator: (value) =>
                      value?.isEmpty == true ? 'Please enter full name' : null,
                ),
                CustomInputField(
                  label: 'Email',
                  hint: 'Enter email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value?.isEmpty == true) return 'Please enter email';
                    if (!value!.contains('@')) return 'Please enter a valid email';
                    return null;
                  },
                ),
                CustomInputField(
                  label: 'Password',
                  hint: 'Enter password',
                  controller: _passwordController,
                  isPassword: true,
                  validator: (value) =>
                      value?.isEmpty == true ? 'Please enter password' : null,
                ),
                CustomInputField(
                  label: 'Age',
                  hint: 'Enter age',
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isEmpty == true) return 'Please enter age';
                    if (int.tryParse(value!) == null) return 'Please enter a valid age';
                    return null;
                  },
                ),

                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Occupation',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedOccupation,
                        items: CreateUserScreen.occupations
                            .map((occupation) => DropdownMenuItem(
                                  value: occupation,
                                  child: Text(occupation),
                                ))
                            .toList(),
                        onChanged: (value) => setState(() => _selectedOccupation = value),
                        decoration: InputDecoration(
                          hintText: 'Select Occupation',
                          border: const OutlineInputBorder(),
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                        ),
                        validator: (value) =>
                            value == null ? 'Please select an occupation' : null,
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Role',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _roleController.text.isNotEmpty
                            ? _roleController.text
                            : null,
                        items: ['Doctor', 'Pharmacologist']
                            .map((role) => DropdownMenuItem(
                                  value: role,
                                  child: Text(role),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _roleController.text = value!;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Select Role',
                          border: const OutlineInputBorder(),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 15),
                        ),
                        validator: (value) =>
                            value == null || value.isEmpty
                                ? 'Please select a role'
                                : null,
                      ),
                    ],
                  ),
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
                  child: const Text('Create User'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
