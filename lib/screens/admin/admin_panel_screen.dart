import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import 'create_user_screen.dart';
import '../../services/donor_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({Key? key}) : super(key: key);

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _donorRequests = [];
  List<Map<String, dynamic>> _bloodRequests = [];
  bool _isLoading = true;
  bool _isLoadingBlood = true;
  final DonorService _donorService = DonorService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchDonorRequests();
    _fetchBloodRequests();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchDonorRequests() async {
    setState(() {
      _isLoading = true;
    });
    try {
      _donorRequests = await _donorService.getDonors(isAdmin: true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching donor requests: $e')),
      );
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _updateRequestStatus(String donorId, String status) async {
    try {
      await _donorService.updateDonorStatus(donorId, status);
      await _fetchDonorRequests();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Request $status.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating status: $e')),
      );
    }
  }

  Future<void> _fetchBloodRequests() async {
    setState(() { _isLoadingBlood = true; });
    try {
      final snapshot = await FirebaseFirestore.instance.collection('blood_requests').orderBy('createdAt', descending: true).get();
      _bloodRequests = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching blood requests: $e')),
      );
    }
    setState(() { _isLoadingBlood = false; });
  }

  Future<void> _updateBloodRequestStatus(String requestId, String status) async {
    try {
      await FirebaseFirestore.instance.collection('blood_requests').doc(requestId).update({'status': status});
      await _fetchBloodRequests();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Request $status.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating status: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        backgroundColor: AppColors.primaryColor,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Donor Requests'),
            Tab(text: 'Blood Requests'),
          ],
        ),
      ),
      body: authProvider.isAdmin
          ? TabBarView(
              controller: _tabController,
              children: [
                // Donor Requests Tab
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Admin Panel',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const CreateUserScreen()),
                          );
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add New User'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Donor Requests',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : _donorRequests.isEmpty
                                ? const Center(child: Text('No donor requests found.'))
                                : ListView.builder(
                                    itemCount: _donorRequests.length,
                                    itemBuilder: (context, index) {
                                      final request = _donorRequests[index];
                                      return Card(
                                        child: Padding(
                                          padding: const EdgeInsets.all(12.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('Name: ${request['name'] ?? ''}', style: TextStyle(fontWeight: FontWeight.bold)),
                                              Text('Email: ${request['email'] ?? ''}'),
                                              Text('Blood Group: ${request['bloodGroup'] ?? ''}'),
                                              Text('Age: ${request['age'] ?? ''}'),
                                              Text('CNIC: ${request['cnicNumber'] ?? ''}'),
                                              Text('Phone: ${request['phoneNumber'] ?? ''}'),
                                              Text('Gender: ${request['gender'] ?? ''}'),
                                              Text('City: ${request['city'] ?? ''}'),
                                              Text('Area: ${request['area'] ?? ''}'),
                                              Text('Blood Amount: ${request['bloodAmount'] ?? ''} liters'),
                                              Text('Price: ${request['price'] ?? 0}'),
                                              Text('Availability Date: ${request['availabilityDate'] ?? ''}'),
                                              Text('Time: ${request['time'] ?? ''}'),
                                              Text('Status: ${request['status'] ?? 'pending'}', style: TextStyle(fontWeight: FontWeight.bold)),
                                              const SizedBox(height: 8),
                                              if ((request['status'] ?? 'pending') == 'pending')
                                                Row(
                                                  children: [
                                                    ElevatedButton(
                                                      onPressed: () => _updateRequestStatus(request['userId'], 'approved'),
                                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                                      child: const Text('Approve'),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    ElevatedButton(
                                                      onPressed: () => _updateRequestStatus(request['userId'], 'rejected'),
                                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                                      child: const Text('Reject'),
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
                ),
                // Blood Requests Tab
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _isLoadingBlood
                      ? const Center(child: CircularProgressIndicator())
                      : _bloodRequests.isEmpty
                          ? const Center(child: Text('No blood requests found.'))
                          : ListView.builder(
                              itemCount: _bloodRequests.length,
                              itemBuilder: (context, index) {
                                final request = _bloodRequests[index];
                                return Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Name: ${request['name'] ?? ''}', style: TextStyle(fontWeight: FontWeight.bold)),
                                        Text('Email: ${request['email'] ?? ''}'),
                                        Text('Phone: ${request['phone'] ?? ''}'),
                                        Text('CNIC: ${request['cnic'] ?? ''}'),
                                        Text('Blood Group: ${request['bloodGroup'] ?? ''}'),
                                        Text('Amount: ${request['amount'] ?? ''} liters'),
                                        Text('City: ${request['city'] ?? ''}'),
                                        Text('Status: ${request['status'] ?? 'pending'}', style: TextStyle(fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 8),
                                        if ((request['status'] ?? 'pending') == 'pending')
                                          Row(
                                            children: [
                                              ElevatedButton(
                                                onPressed: () => _updateBloodRequestStatus(request['id'], 'approved'),
                                                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                                child: const Text('Approve'),
                                              ),
                                              const SizedBox(width: 12),
                                              ElevatedButton(
                                                onPressed: () => _updateBloodRequestStatus(request['id'], 'rejected'),
                                                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                                child: const Text('Reject'),
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
            )
          : const Center(
              child: Text(
                'Access Denied',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ),
    );
  }
}