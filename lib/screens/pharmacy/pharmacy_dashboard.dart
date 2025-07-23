import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tabib/screens/pharmacy/Pharmacy_orders.dart';
import 'add_medicine_screen.dart';

class PharmacyDashboard extends StatelessWidget {
  const PharmacyDashboard({Key? key}) : super(key: key);

  void _confirmDelete(BuildContext context, String docId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Text(
          'Delete Medicine',
          style: TextStyle(
            color: Color(0xFF0E7490),
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        content: Text(
          'Are you sure you want to delete this medicine?',
          style: TextStyle(
            color: Color(0xFF64748B),
            fontSize: 16,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF64748B)),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await FirebaseFirestore.instance
                  .collection('medicines')
                  .doc(docId)
                  .delete();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Medicine deleted successfully'),
                  backgroundColor: Color(0xFF0B7285),
                ),
              );
            },
            child: Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final CollectionReference medicines =
        FirebaseFirestore.instance.collection('medicines');

    return Scaffold(
      backgroundColor: Color(0xFFF8FFFE),
      appBar: AppBar(
                  automaticallyImplyLeading: false, // back button hide karta hai

        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF0E7490),
        elevation: 0,
        title: Text(
          "Pharmacy Dashboard",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF0E7490),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.receipt_long,
              color: Color(0xFF0B7285),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const OrderManagementPage()),
              );
            },
          ),
          SizedBox(width: 8),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: medicines.orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Something went wrong',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 16,
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: Color(0xFF0B7285),
              ),
            );
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.medical_services_outlined,
                    size: 64,
                    color: Color(0xFF64748B),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No medicines found',
                    style: TextStyle(
                      color: Color(0xFF0E7490),
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;

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
                        child: data['image'] != null
                            ? Image.memory(
                                base64Decode(data['image']),
                                height: 60,
                                width: 60,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                height: 60,
                                width: 60,
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
                              data['name'] ?? '',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF0E7490),
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              data['description'] ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Text(
                                  '₹${data['price'] ?? '0'}',
                                  style: TextStyle(
                                    color: Color(0xFF0B7285),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(width: 16),
                                Text(
                                  'Stock: ${data['stock'] ?? '0'}',
                                  style: TextStyle(
                                    color: Color(0xFF64748B),
                                    fontSize: 12,
                                  ),
                                ),
                                SizedBox(width: 16),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: data['isAvailable'] == true
                                        ? Color(0xFF0B7285).withOpacity(0.1)
                                        : Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    data['isAvailable'] == true ? 'Available' : 'Out of Stock',
                                    style: TextStyle(
                                      color: data['isAvailable'] == true
                                          ? Color(0xFF0B7285)
                                          : Colors.red,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      // Action Buttons
                      Column(
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.edit,
                              color: Color(0xFF0891B2),
                              size: 20,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AddMedicineScreen(
                                    isEdit: true,
                                    docId: docs[index].id,
                                    data: data,
                                  ),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.delete,
                              color: Colors.red,
                              size: 20,
                            ),
                            onPressed: () {
                              _confirmDelete(context, docs[index].id);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddMedicineScreen()),
          );
        },
        backgroundColor: Color(0xFF0B7285),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}