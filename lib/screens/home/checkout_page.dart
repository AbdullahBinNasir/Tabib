import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tabib/screens/home/order_page.dart';

class CheckoutPage extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final double total;

  const CheckoutPage({super.key, required this.cartItems, required this.total});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  // Custom Color Palette
  static const Color primaryBlue = Color(0xFF0B7285);
  static const Color primaryBlueDark = Color(0xFF0891B2);
  static const Color backgroundColor = Color(0xFFF8FFFE);
  static const Color headingColor = Color(0xFF0E7490);
  static const Color secondaryTextColor = Color(0xFF64748B);

  Future<void> _submitOrder() async {
    if (_formKey.currentState!.validate()) {
      final orderData = {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'total': widget.total,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'Order Placed',
        'items': widget.cartItems.map((item) {
          return {
            'name': item['name'] ?? '',
            'price': item['price'] ?? 0,
            'quantity': item['quantity'] ?? 1,
            'image': item['image'] ?? '',
          };
        }).toList(),
      };

      try {
        await FirebaseFirestore.instance.collection('orders').add(orderData);

        AwesomeDialog(
          context: context,
          dialogType: DialogType.success,
          animType: AnimType.bottomSlide,
          title: 'Order Placed!',
          desc: 'Your order was successfully placed!',
          btnOkColor: primaryBlue,
          btnOkOnPress: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => WebOrderReceiptPage(
                  orderItems: widget.cartItems,
                  totalAmount: widget.total,
                  customerName: _nameController.text.trim(),
                  customerEmail: _emailController.text.trim(),
                  customerPhone: _phoneController.text.trim(),
                  shippingAddress: _addressController.text.trim(),
                ),
              ),
            );
          },
        ).show();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error saving order: $e"),
            backgroundColor: primaryBlueDark,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          "Checkout",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: primaryBlue,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              "Enter Your Details",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: headingColor,
              ),
            ),
            const SizedBox(height: 12),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  // Name Field
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                      labelStyle: TextStyle(color: secondaryTextColor),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: primaryBlue),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: secondaryTextColor.withOpacity(0.5)),
                      ),
                    ),
                    style: TextStyle(color: headingColor),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return 'Name is required';
                      final regex = RegExp(r"^[a-zA-Z\s]+$");
                      if (!regex.hasMatch(value)) return 'Enter a valid name (only alphabets)';
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),

                  // Email Field
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(color: secondaryTextColor),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: primaryBlue),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: secondaryTextColor.withOpacity(0.5)),
                      ),
                    ),
                    style: TextStyle(color: headingColor),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Email is required';
                      final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$');
                      if (!regex.hasMatch(value)) return 'Enter a valid email address';
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),

                  // Phone Field
                  TextFormField(
                    controller: _phoneController,
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      labelStyle: TextStyle(color: secondaryTextColor),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: primaryBlue),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: secondaryTextColor.withOpacity(0.5)),
                      ),
                    ),
                    style: TextStyle(color: headingColor),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Phone number is required';
                      final regex = RegExp(r'^\d{11}$');
                      if (!regex.hasMatch(value)) return 'Enter a valid 11-digit phone number';
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),

                  // Address Field
                  TextFormField(
                    controller: _addressController,
                    decoration: InputDecoration(
                      labelText: 'Shipping Address',
                      labelStyle: TextStyle(color: secondaryTextColor),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: primaryBlue),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: secondaryTextColor.withOpacity(0.5)),
                      ),
                    ),
                    style: TextStyle(color: headingColor),
                    maxLines: 2,
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Address is required' : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Order Summary",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: headingColor,
              ),
            ),
            Divider(height: 16, color: secondaryTextColor.withOpacity(0.3)),

            // Order Items List
            ...widget.cartItems.map((item) {
              final name = item['name'] ?? '';
              final qty = item['quantity'] ?? 1;
              final price = item['price'] ?? 0;
              final subtotal = price * qty;
              final base64Image = item['image'];

              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: base64Image != null && base64Image.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.memory(
                          base64Decode(base64Image),
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: primaryBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.shopping_cart,
                          color: primaryBlue,
                        ),
                      ),
                title: Text(
                  name,
                  style: TextStyle(
                    color: headingColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  "Qty: $qty",
                  style: TextStyle(color: secondaryTextColor),
                ),
                trailing: Text(
                  "₹${subtotal.toStringAsFixed(2)}",
                  style: TextStyle(
                    color: headingColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }),

            Divider(color: secondaryTextColor.withOpacity(0.3)),
            Text(
              "Total: ₹${widget.total.toStringAsFixed(2)}",
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: headingColor,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _submitOrder,
              icon: const Icon(Icons.check_circle, color: Colors.white),
              label: const Text(
                "Confirm Order",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                minimumSize: const Size.fromHeight(50),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}