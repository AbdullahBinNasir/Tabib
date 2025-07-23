import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tabib/screens/home/cart.dart';

class UserMedicineView extends StatefulWidget {
  const UserMedicineView({super.key});

  @override
  State<UserMedicineView> createState() => _UserMedicineViewState();
}

class _UserMedicineViewState extends State<UserMedicineView> {
  final List<Map<String, dynamic>> cartItems = [];
  String searchQuery = '';
  String sortOrder = 'A-Z';

  void addToCart(Map<String, dynamic> item) {
    setState(() {
      cartItems.add(item);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            const Text("Item added to cart"),
          ],
        ),
        backgroundColor: const Color(0xFF0B7285),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final medicines = FirebaseFirestore.instance.collection('medicines');

    return Scaffold(
      backgroundColor: const Color(0xFFF0FDFA),
      appBar: AppBar(
        title: const Text(
          "Medicine Inventory",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Color(0xFF134E4A),
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: const Color(0xFF0891B2).withOpacity(0.1),
        toolbarHeight: 64,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  const Color(0xFF0891B2).withOpacity(0.2),
                  Colors.transparent
                ],
              ),
            ),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCFFAFE),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF0891B2).withOpacity(0.2)),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.shopping_cart_outlined,
                      color: Color(0xFF0B7285),
                      size: 20,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CartPage(cartItems: cartItems),
                        ),
                      );
                    },
                  ),
                ),
                if (cartItems.isNotEmpty)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0E7490),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                      child: Text(
                        '${cartItems.length}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Search & Filter",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0B7285),
                    letterSpacing: 0.1,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    // Search Bar
                    Expanded(
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDFA),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF0891B2).withOpacity(0.2)),
                        ),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search by medicine name...',
                            hintStyle: const TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                            prefixIcon: const Icon(
                              Icons.search,
                              color: Color(0xFF0B7285),
                              size: 20,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onChanged: (val) {
                            setState(() {
                              searchQuery = val.toLowerCase();
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Sort Dropdown
                    Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF0891B2).withOpacity(0.2)),
                      ),
                      child: DropdownButton<String>(
                        value: sortOrder,
                        underline: const SizedBox(),
                        icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF0B7285)),
                        items: const [
                          DropdownMenuItem(
                            value: 'A-Z',
                            child: Text(
                              "A-Z",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF134E4A),
                              ),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'Z-A',
                            child: Text(
                              "Z-A",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF134E4A),
                              ),
                            ),
                          ),
                        ],
                        onChanged: (val) {
                          setState(() {
                            sortOrder = val!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Divider
          Container(
            height: 8,
            color: const Color(0xFFECFDFD),
          ),

          // Medicine List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: medicines.where('isAvailable', isEqualTo: true).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF2F2),
                            borderRadius: BorderRadius.circular(32),
                          ),
                          child: const Icon(Icons.error_outline, size: 32, color: Color(0xFFEF4444)),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Unable to load medicines",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF134E4A),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Please check your connection and try again",
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 32,
                          height: 32,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: Color(0xFF0891B2),
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          "Loading medicines...",
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                List<QueryDocumentSnapshot> docs = snapshot.data!.docs;

                // Apply search filter
                docs = docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final name = (data['name'] ?? '').toString().toLowerCase();
                  return name.contains(searchQuery);
                }).toList();

                // Sort by name
                docs.sort((a, b) {
                  final nameA = (a['name'] ?? '').toString();
                  final nameB = (b['name'] ?? '').toString();
                  return sortOrder == 'A-Z' ? nameA.compareTo(nameB) : nameB.compareTo(nameA);
                });

                if (docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: const Color(0xFFCFFAFE),
                            borderRadius: BorderRadius.circular(32),
                          ),
                          child: const Icon(
                            Icons.inventory_2_outlined,
                            size: 32,
                            color: Color(0xFF0891B2),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          searchQuery.isEmpty ? "No medicines available" : "No medicines found",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF134E4A),
                          ),
                        ),
                        if (searchQuery.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          const Text(
                            "Try adjusting your search criteria",
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final int stock = data['stock'] ?? 0;
                    final String price = data['price']?.toString() ?? '0';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF0891B2).withOpacity(0.1)),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0891B2).withOpacity(0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Medicine Image
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0FDFA),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFF0891B2).withOpacity(0.2)),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: data['image'] != null
                                    ? Image.memory(
                                        base64Decode(data['image']),
                                        fit: BoxFit.cover,
                                      )
                                    : const Icon(
                                        Icons.medication_outlined,
                                        size: 32,
                                        color: Color(0xFF0891B2),
                                      ),
                              ),
                            ),
                            const SizedBox(width: 20),

                            // Medicine Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Medicine Name
                                  Text(
                                    data['name'] ?? 'Unknown Medicine',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF134E4A),
                                      height: 1.2,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),

                                  // Category
                                  if (data['category'] != null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFCFFAFE),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: const Color(0xFF0891B2).withOpacity(0.3)),
                                      ),
                                      child: Text(
                                        data['category'].toString(),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF0B7285),
                                        ),
                                      ),
                                    ),
                                  const SizedBox(height: 12),

                                  // Price and Stock Row
                                  Row(
                                    children: [
                                      // Price
                                      RichText(
                                        text: TextSpan(
                                          style: const TextStyle(fontSize: 14),
                                          children: [
                                            const TextSpan(
                                              text: "Price: ",
                                              style: TextStyle(
                                                color: Color(0xFF6B7280),
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                            TextSpan(
                                              text: "\$$price",
                                              style: const TextStyle(
                                                color: Color(0xFF0E7490),
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 20),
                                      // Stock Status
                                      Row(
                                        children: [
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration: BoxDecoration(
                                              color: stock > 0 ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            stock > 0 ? "In Stock ($stock)" : "Out of Stock",
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: stock > 0 ? const Color(0xFF059669) : const Color(0xFFDC2626),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),

                                  // Description (if available)
                                  if (data['description'] != null && data['description'].toString().isNotEmpty) ...[
                                    const SizedBox(height: 12),
                                    Text(
                                      data['description'].toString(),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF6B7280),
                                        height: 1.3,
                                      ),
                                    ),
                                  ],

                                  const SizedBox(height: 16),

                                  // Action Button
                                  SizedBox(
                                    height: 36,
                                    child: ElevatedButton(
                                      onPressed: stock > 0 ? () => addToCart(data) : null,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: stock > 0 ? const Color(0xFF0891B2) : const Color(0xFFF9FAFB),
                                        foregroundColor: stock > 0 ? Colors.white : const Color(0xFF9CA3AF),
                                        elevation: 0,
                                        shadowColor: Colors.transparent,
                                        padding: const EdgeInsets.symmetric(horizontal: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          side: BorderSide(
                                            color: stock > 0 ? const Color(0xFF0891B2) : const Color(0xFFD1D5DB),
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            stock > 0 ? Icons.add_shopping_cart : Icons.block,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            stock > 0 ? "Add to Cart" : "Unavailable",
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
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
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}