import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

class OrderManagementPage extends StatelessWidget {
  const OrderManagementPage({super.key});

  // Custom Color Scheme
  static const Color primaryBlue = Color(0xFF0B7285);
  static const Color secondaryBlue = Color(0xFF0891B2);
  static const Color backgroundColor = Color(0xFFF8FFFE);
  static const Color headingTextColor = Color(0xFF0E7490);
  static const Color secondaryTextColor = Color(0xFF64748B);

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'order placed':
        return Colors.blue;
      case 'processing':
        return Colors.orange;
      case 'shipped':
        return primaryBlue;
      case 'delivered':
        return Colors.green;
      default:
        return secondaryTextColor;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'order placed':
        return Icons.receipt_long;
      case 'processing':
        return Icons.settings;
      case 'shipped':
        return Icons.local_shipping;
      case 'delivered':
        return Icons.check_circle;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Order Management',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        backgroundColor: primaryBlue,
        elevation: 2,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: primaryBlue,
                strokeWidth: 3,
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyState();
          }

          final orders = snapshot.data!.docs;

          return RefreshIndicator(
            color: primaryBlue,
            backgroundColor: Colors.white,
            onRefresh: () async {
              // Refresh functionality can be added here
              await Future.delayed(const Duration(seconds: 1));
            },
            child: ListView.builder(
              padding: EdgeInsets.all(isTablet ? 24 : 16),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                final data = order.data() as Map<String, dynamic>;
                final items = List<Map<String, dynamic>>.from(data['items'] ?? []);
                final status = data['status'] ?? 'Order Placed';
                final timestamp = data['timestamp'] as Timestamp?;

                return Container(
                  margin: EdgeInsets.only(bottom: isTablet ? 20 : 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: primaryBlue.withOpacity(0.08),
                        spreadRadius: 1,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      dividerColor: Colors.transparent,
                      expansionTileTheme: const ExpansionTileThemeData(
                        backgroundColor: Colors.transparent,
                        collapsedBackgroundColor: Colors.transparent,
                      ),
                    ),
                    child: ExpansionTile(
                      tilePadding: EdgeInsets.all(isTablet ? 24 : 20),
                      childrenPadding: EdgeInsets.only(
                        left: isTablet ? 24 : 20,
                        right: isTablet ? 24 : 20,
                        bottom: isTablet ? 24 : 20,
                      ),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _getStatusColor(status).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _getStatusIcon(status),
                          color: _getStatusColor(status),
                          size: 20,
                        ),
                      ),
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data['name'] ?? 'N/A',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: isTablet ? 18 : 16,
                              color: headingTextColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(status).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              status,
                              style: TextStyle(
                                color: _getStatusColor(status),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          children: [
                            Icon(
                              Icons.currency_rupee,
                              size: 16,
                              color: primaryBlue,
                            ),
                            Text(
                              '${data['total'] ?? 0}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: isTablet ? 16 : 14,
                                color: primaryBlue,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Icon(
                              Icons.shopping_bag,
                              size: 16,
                              color: secondaryTextColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${items.length} items',
                              style: TextStyle(
                                color: secondaryTextColor,
                                fontSize: isTablet ? 14 : 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      children: [
                        // Customer Details Section
                        _buildSectionHeader('Customer Details', Icons.person),
                        const SizedBox(height: 12),
                        _buildCustomerDetails(data, timestamp, isTablet),
                        
                        const SizedBox(height: 20),
                        
                        // Order Items Section
                        _buildSectionHeader('Order Items', Icons.shopping_cart),
                        const SizedBox(height: 12),
                        _buildOrderItems(items, isTablet),
                        
                        const SizedBox(height: 20),
                        
                        // Status Update Section
                        _buildStatusUpdateSection(order.id, status, isTablet),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: primaryBlue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: primaryBlue,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Orders Yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: headingTextColor,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Orders will appear here once\ncustomers place them',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: secondaryTextColor,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: secondaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            size: 16,
            color: secondaryBlue,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: headingTextColor,
          ),
        ),
      ],
    );
  }

  Widget _buildCustomerDetails(Map<String, dynamic> data, Timestamp? timestamp, bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: primaryBlue.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _buildDetailRow(Icons.phone, 'Phone', data['phone'] ?? 'N/A', isTablet),
          const SizedBox(height: 12),
          _buildDetailRow(Icons.email, 'Email', data['email'] ?? 'N/A', isTablet),
          const SizedBox(height: 12),
          _buildDetailRow(Icons.location_on, 'Address', data['address'] ?? 'N/A', isTablet),
          const SizedBox(height: 12),
          _buildDetailRow(
            Icons.access_time,
            'Order Date',
            timestamp?.toDate().toString().split('.').first ?? 'N/A',
            isTablet,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, bool isTablet) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color: secondaryBlue,
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: isTablet ? 80 : 60,
          child: Text(
            '$label:',
            style: TextStyle(
              fontSize: isTablet ? 14 : 13,
              fontWeight: FontWeight.w600,
              color: headingTextColor,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: isTablet ? 14 : 13,
              color: secondaryTextColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderItems(List<Map<String, dynamic>> items, bool isTablet) {
    return Column(
      children: items.map((item) {
        final img = item['image'];
        final hasImage = img != null && img != 'N/A' && img.toString().isNotEmpty;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: EdgeInsets.all(isTablet ? 16 : 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: primaryBlue.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: isTablet ? 60 : 50,
                height: isTablet ? 60 : 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: backgroundColor,
                ),
                child: hasImage
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.memory(
                          base64Decode(img),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.broken_image,
                              color: primaryBlue.withOpacity(0.6),
                              size: isTablet ? 24 : 20,
                            );
                          },
                        ),
                      )
                    : Icon(
                        Icons.medical_services,
                        color: primaryBlue.withOpacity(0.6),
                        size: isTablet ? 24 : 20,
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['name'] ?? 'Item',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: isTablet ? 16 : 14,
                        color: headingTextColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: secondaryBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Qty: ${item['quantity'] ?? 0}',
                            style: TextStyle(
                              fontSize: isTablet ? 12 : 11,
                              fontWeight: FontWeight.w600,
                              color: secondaryBlue,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '₹${item['price'] ?? 0}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: isTablet ? 14 : 13,
                            color: primaryBlue,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStatusUpdateSection(String orderId, String currentStatus, bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: primaryBlue.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.update,
                  size: 16,
                  color: primaryBlue,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Update Status',
                style: TextStyle(
                  fontSize: isTablet ? 16 : 14,
                  fontWeight: FontWeight.bold,
                  color: headingTextColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: primaryBlue.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: currentStatus,
                isExpanded: true,
                style: TextStyle(
                  color: primaryBlue,
                  fontWeight: FontWeight.w600,
                  fontSize: isTablet ? 14 : 13,
                ),
                dropdownColor: Colors.white,
                borderRadius: BorderRadius.circular(8),
                icon: const Icon(
                  Icons.keyboard_arrow_down,
                  color: primaryBlue,
                ),
                items: [
                  'Order Placed',
                  'Processing',
                  'Shipped',
                  'Delivered',
                ].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Row(
                      children: [
                        Icon(
                          _getStatusIcon(value),
                          size: 16,
                          color: _getStatusColor(value),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          value,
                          style: TextStyle(
                            color: _getStatusColor(value),
                            fontWeight: FontWeight.w600,
                            fontSize: isTablet ? 14 : 13,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (newStatus) {
                  if (newStatus != null && newStatus != currentStatus) {
                    FirebaseFirestore.instance
                        .collection('orders')
                        .doc(orderId)
                        .update({'status': newStatus});
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}