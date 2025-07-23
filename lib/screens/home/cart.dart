import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'checkout_page.dart';

class CartPage extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;

  const CartPage({super.key, required this.cartItems});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  void updateQuantity(int index, int change) {
    setState(() {
      int currentQty = widget.cartItems[index]['quantity'] ?? 1;
      if (currentQty + change > 0 && currentQty + change <= 10) {
        widget.cartItems[index]['quantity'] = currentQty + change;
      }
    });
  }

  double calculateTotal() {
    return widget.cartItems.fold(0, (sum, item) {
      final price = (item['price'] ?? 0).toDouble();
      final qty = item['quantity'] ?? 1;
      return sum + (price * qty);
    });
  }

  void confirmDelete(int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Text(
          "Remove Item",
          style: TextStyle(
            color: Color(0xFF0E7490),
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        content: Text(
          "Are you sure you want to remove this item from your cart?",
          style: TextStyle(
            color: Color(0xFF64748B),
            fontSize: 16,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: TextStyle(color: Color(0xFF64748B)),
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() => widget.cartItems.removeAt(index));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Item removed from cart'),
                  backgroundColor: Color(0xFF0B7285),
                ),
              );
            },
            child: Text(
              "Remove",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = calculateTotal();

    return Scaffold(
      backgroundColor: Color(0xFFF8FFFE),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF0E7490),
        elevation: 0,
        title: Text(
          "Shopping Cart",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF0E7490),
          ),
        ),
        actions: [
          if (widget.cartItems.isNotEmpty)
            IconButton(
              icon: Icon(
                Icons.delete_sweep,
                color: Color(0xFF64748B),
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    title: Text(
                      "Clear Cart",
                      style: TextStyle(
                        color: Color(0xFF0E7490),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    content: Text(
                      "Are you sure you want to clear your entire cart?",
                      style: TextStyle(color: Color(0xFF64748B)),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          "Cancel",
                          style: TextStyle(color: Color(0xFF64748B)),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() => widget.cartItems.clear());
                          Navigator.pop(context);
                        },
                        child: Text(
                          "Clear",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          SizedBox(width: 8),
        ],
      ),
      body: widget.cartItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 80,
                    color: Color(0xFF64748B),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Your cart is empty",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF0E7490),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Add some medicines to get started",
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Cart Summary
                Container(
                  margin: EdgeInsets.all(16),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${widget.cartItems.length} items",
                            style: TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            "PKR:${total.toStringAsFixed(2)}",
                            style: TextStyle(
                              color: Color(0xFF0B7285),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Color(0xFF0B7285).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "Total",
                          style: TextStyle(
                            color: Color(0xFF0B7285),
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Cart Items
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    itemCount: widget.cartItems.length,
                    itemBuilder: (context, index) {
                      final item = widget.cartItems[index];
                      final quantity = item['quantity'] ?? 1;
                      final imageData = item['image'];
                      Uint8List? imageBytes;

                      try {
                        if (imageData != null) {
                          imageBytes = base64Decode(imageData);
                        }
                      } catch (_) {
                        imageBytes = null;
                      }

                      return Container(
                        margin: EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Row(
                            children: [
                              // Medicine Image
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: imageBytes != null
                                    ? Image.memory(
                                        imageBytes,
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                      )
                                    : Container(
                                        width: 60,
                                        height: 60,
                                        color: Color(0xFFF1F5F9),
                                        child: Icon(
                                          Icons.medication,
                                          color: Color(0xFF0B7285),
                                          size: 24,
                                        ),
                                      ),
                              ),
                              SizedBox(width: 16),
                              
                              // Medicine Details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['name'] ?? '',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                        color: Color(0xFF0E7490),
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      "PKR:${(item['price'] ?? 0).toStringAsFixed(2)} each",
                                      style: TextStyle(
                                        color: Color(0xFF64748B),
                                        fontSize: 14,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      "Subtotal: PKR:${((item['price'] ?? 0) * quantity).toStringAsFixed(2)}",
                                      style: TextStyle(
                                        color: Color(0xFF0B7285),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              // Quantity Controls & Delete
                              Column(
                                children: [
                                  // Quantity Controls
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Color(0xFF0B7285).withOpacity(0.2),
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        GestureDetector(
                                          onTap: () => updateQuantity(index, -1),
                                          child: Container(
                                            padding: EdgeInsets.all(8),
                                            child: Icon(
                                              Icons.remove,
                                              color: Color(0xFF0B7285),
                                              size: 16,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal: 12),
                                          child: Text(
                                            quantity.toString(),
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF0E7490),
                                            ),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: quantity >= 10
                                              ? null
                                              : () {
                                                  updateQuantity(index, 1);
                                                  if (widget.cartItems[index]['quantity'] >= 10) {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(
                                                        content: Text("Maximum 10 items allowed"),
                                                        backgroundColor: Colors.orange,
                                                      ),
                                                    );
                                                  }
                                                },
                                          child: Container(
                                            padding: EdgeInsets.all(8),
                                            child: Icon(
                                              Icons.add,
                                              color: quantity >= 10 
                                                  ? Color(0xFF64748B) 
                                                  : Color(0xFF0B7285),
                                              size: 16,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  
                                  // Delete Button
                                  GestureDetector(
                                    onTap: () => confirmDelete(index),
                                    child: Container(
                                      padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.red.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Icon(
                                        Icons.delete_outline,
                                        color: Colors.red,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
      bottomNavigationBar: widget.cartItems.isEmpty
          ? null
          : Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CheckoutPage(
                            cartItems: widget.cartItems,
                            total: total,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF0B7285),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Proceed to Checkout",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward, size: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}