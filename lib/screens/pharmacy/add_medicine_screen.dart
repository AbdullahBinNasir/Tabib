import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddMedicineScreen extends StatefulWidget {
  final bool isEdit;
  final String? docId;
  final Map<String, dynamic>? data;

  const AddMedicineScreen({super.key, this.isEdit = false, this.docId, this.data});

  @override
  State<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends State<AddMedicineScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController stockController = TextEditingController();
  String category = 'Tablet';
  bool isAvailable = true;
  String imgBase64 = "";
  final ImagePicker picker = ImagePicker();

  // Color constants
  static const Color primaryBlue = Color(0xFF0B7285);
  static const Color secondaryBlue = Color(0xFF0891B2);
  static const Color backgroundColor = Color(0xFFF8FFFE);
  static const Color headingColor = Color(0xFF0E7490);
  static const Color secondaryTextColor = Color(0xFF64748B);

  @override
  void initState() {
    super.initState();

    if (widget.isEdit && widget.data != null) {
      nameController.text = widget.data!['name'] ?? '';
      descriptionController.text = widget.data!['description'] ?? '';
      priceController.text = widget.data!['price'].toString();
      stockController.text = widget.data!['stock'].toString();
      category = widget.data!['category'] ?? 'Tablet';
      isAvailable = widget.data!['isAvailable'] ?? true;
      imgBase64 = widget.data!['image'] ?? '';
    }
  }

  Future<void> pickImage() async {
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final Uint8List bytes = await image.readAsBytes();
      setState(() {
        imgBase64 = base64Encode(bytes);
      });
    }
  }

  Future<void> handleSubmit() async {
    final name = nameController.text.trim();
    final description = descriptionController.text.trim();
    final price = priceController.text.trim();
    final stock = stockController.text.trim();

    final RegExp alphaRegex = RegExp(r'^[a-zA-Z\s]+$');
    final RegExp numberRegex = RegExp(r'^\d+$');

    if (name.isEmpty || price.isEmpty || stock.isEmpty || imgBase64.isEmpty) {
      _showSnackBar('Please fill all required fields', isError: true);
      return;
    }

    if (!alphaRegex.hasMatch(name)) {
      _showSnackBar('Name must contain only alphabets and spaces', isError: true);
      return;
    }

    if (description.isNotEmpty && !alphaRegex.hasMatch(description)) {
      _showSnackBar('Description must contain only alphabets and spaces', isError: true);
      return;
    }

    if (!numberRegex.hasMatch(price)) {
      _showSnackBar('Price must be numeric only (no symbols or hyphens)', isError: true);
      return;
    }

    if (!numberRegex.hasMatch(stock)) {
      _showSnackBar('Stock must be numeric only (no symbols or hyphens)', isError: true);
      return;
    }

    final medicineData = {
      'name': name,
      'description': description,
      'price': double.tryParse(price) ?? 0,
      'stock': int.tryParse(stock) ?? 0,
      'category': category,
      'isAvailable': isAvailable,
      'image': imgBase64,
      'timestamp': FieldValue.serverTimestamp(),
    };

    try {
      final medicines = FirebaseFirestore.instance.collection('medicines');

      if (widget.isEdit && widget.docId != null) {
        await medicines.doc(widget.docId!).update(medicineData);
        _showSnackBar('Medicine updated successfully!');
      } else {
        await medicines.add(medicineData);
        _showSnackBar('Medicine added successfully!');
      }

      Navigator.pop(context);
    } catch (e) {
      print("Error: $e");
      _showSnackBar('Failed to save medicine', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: isError ? Colors.red[700] : primaryBlue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool isRequired = false,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? prefix,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: TextStyle(
          fontSize: 16,
          color: headingColor,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label + (isRequired ? ' *' : ''),
          labelStyle: TextStyle(
            color: secondaryTextColor,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          prefixText: prefix,
          prefixStyle: TextStyle(
            color: headingColor,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: primaryBlue, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.isEdit;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(

        title: Text(
          
          isEditing ? 'Edit Medicine' : 'Add Medicine',
          style: TextStyle(
            color: Colors.white,
            
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: primaryBlue,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header section with gradient
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [primaryBlue, secondaryBlue],
                ),
              ),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: primaryBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            isEditing ? Icons.edit_rounded : Icons.add_rounded,
                            color: primaryBlue,
                            size: 24,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isEditing ? 'Update Medicine' : 'Add New Medicine',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: headingColor,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                isEditing 
                                  ? 'Modify the medicine details below'
                                  : 'Fill in the medicine details below',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: secondaryTextColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            // Form section
            Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                children: [
                  _buildTextField(
                    controller: nameController,
                    label: 'Medicine Name',
                    isRequired: true,
                  ),
                  
                  _buildTextField(
                    controller: descriptionController,
                    label: 'Description',
                    maxLines: 3,
                  ),
                  
                  _buildTextField(
                    controller: priceController,
                    label: 'Price',
                    isRequired: true,
                    keyboardType: TextInputType.number,
                    prefix: '\$ ',
                  ),
                  
                  _buildTextField(
                    controller: stockController,
                    label: 'Stock Quantity',
                    isRequired: true,
                    keyboardType: TextInputType.number,
                  ),

                  // Category dropdown
                  Container(
                    margin: EdgeInsets.only(bottom: 20),
                    child: DropdownButtonFormField<String>(
                      value: category,
                      style: TextStyle(
                        fontSize: 16,
                        color: headingColor,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Category',
                        labelStyle: TextStyle(
                          color: secondaryTextColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: primaryBlue, width: 2),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                      items: ['Tablet', 'Syrup', 'Capsule', 'Injection']
                          .map((type) => DropdownMenuItem(
                                value: type,
                                child: Text(type),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() => category = value ?? 'Tablet');
                      },
                    ),
                  ),

                  // Availability switch
                  Container(
                    margin: EdgeInsets.only(bottom: 24),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!, width: 1),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Availability Status',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: headingColor,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              isAvailable ? 'Medicine is available' : 'Medicine is out of stock',
                              style: TextStyle(
                                fontSize: 13,
                                color: secondaryTextColor,
                              ),
                            ),
                          ],
                        ),
                        Switch(
                          value: isAvailable,
                          onChanged: (val) => setState(() => isAvailable = val),
                          activeColor: Colors.white,
                          activeTrackColor: primaryBlue,
                          inactiveThumbColor: Colors.grey[400],
                          inactiveTrackColor: Colors.grey[300],
                        ),
                      ],
                    ),
                  ),

                  // Image picker section
                  Container(
                    margin: EdgeInsets.only(bottom: 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Medicine Image *',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: headingColor,
                          ),
                        ),
                        SizedBox(height: 12),
                        GestureDetector(
                          onTap: pickImage,
                          child: Container(
                            width: double.infinity,
                            height: imgBase64.isEmpty ? 120 : 200,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: imgBase64.isEmpty ? Colors.grey[300]! : primaryBlue,
                                width: imgBase64.isEmpty ? 2 : 2,
                                style: imgBase64.isEmpty ? BorderStyle.solid : BorderStyle.solid,
                              ),
                            ),
                            child: imgBase64.isEmpty
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: primaryBlue.withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.add_photo_alternate_outlined,
                                          color: primaryBlue,
                                          size: 32,
                                        ),
                                      ),
                                      SizedBox(height: 12),
                                      Text(
                                        'Tap to add image',
                                        style: TextStyle(
                                          color: primaryBlue,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'Required field',
                                        style: TextStyle(
                                          color: secondaryTextColor,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  )
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Stack(
                                      children: [
                                        Image.memory(
                                          base64Decode(imgBase64),
                                          width: double.infinity,
                                          height: 200,
                                          fit: BoxFit.cover,
                                        ),
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: Container(
                                            padding: EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: Colors.black54,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.edit,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Submit button
                  Container(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        isEditing ? 'Update Medicine' : 'Add Medicine',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}