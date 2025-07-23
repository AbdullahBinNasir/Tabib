import 'dart:convert'; // <-- For base64 decode
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class WebOrderReceiptPage extends StatelessWidget {
  final List<Map<String, dynamic>> orderItems;
  final double totalAmount;
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final String shippingAddress;

  const WebOrderReceiptPage({
    super.key,
    required this.orderItems,
    required this.totalAmount,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    required this.shippingAddress,
  });

  Future<void> _downloadPdf() async {
    final pdf = pw.Document();
    final now = DateTime.now();
    final formattedDate = DateFormat('yyyy-MM-dd – hh:mm a').format(now);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("Pharmacy Receipt",
                  style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Text("Date: $formattedDate"),
              pw.Text("Customer Name: $customerName"),
              pw.Text("Email: $customerEmail"),
              pw.Text("Phone: $customerPhone"),
              pw.Text("Address: $shippingAddress"),
              pw.SizedBox(height: 20),
              pw.Text("Order Items:",
                  style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              pw.Table.fromTextArray(
                headers: ['Item', 'Quantity', 'Price'],
                data: orderItems.map((item) {
                  final total = (item['price'] ?? 0) * (item['quantity'] ?? 1);
                  return [
                    item['name'],
                    item['quantity'].toString(),
                    '₹${total.toStringAsFixed(2)}'
                  ];
                }).toList(),
              ),
              pw.SizedBox(height: 20),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text("Total Amount: ₹${totalAmount.toStringAsFixed(2)}",
                    style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
              ),
              pw.SizedBox(height: 20),
              pw.Text("Thank you for shopping with us!"),
            ],
          );
        },
      ),
    );

    final bytes = await pdf.save();
    final blob = html.Blob([bytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', 'receipt.pdf')
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final formattedDate = DateFormat('yyyy-MM-dd – hh:mm a').format(now);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Order Confirmation"),
        backgroundColor: Colors.teal,
        automaticallyImplyLeading: false, // 🔴 Removed Back Icon
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "✅ Order Placed Successfully!",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text("Date: $formattedDate", style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 4),
            Text("Name: $customerName", style: const TextStyle(fontSize: 16)),
            Text("Email: $customerEmail", style: const TextStyle(fontSize: 16)),
            Text("Phone: $customerPhone", style: const TextStyle(fontSize: 16)),
            Text("Address: $shippingAddress", style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 24),

            const Divider(),
            const Text("📦 Order Status", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            Theme(
              data: Theme.of(context).copyWith(
                colorScheme: Theme.of(context).colorScheme.copyWith(primary: Colors.teal),
              ),
              child: Stepper(
                physics: const NeverScrollableScrollPhysics(),
                currentStep: 1,
                controlsBuilder: (context, _) => const SizedBox.shrink(),
                steps: [
                  Step(
                    title: const Text("Order Placed"),
                    content: const Text("Your order has been placed."),
                    isActive: true,
                    state: StepState.complete,
                  ),
                  Step(
                    title: const Text("Processing"),
                    content: const Text("Your order is being processed."),
                    isActive: true,
                    state: StepState.editing,
                  ),
                  Step(
                    title: const Text("Shipped"),
                    content: const Text("Your order is on the way."),
                    isActive: false,
                    state: StepState.indexed,
                  ),
                  Step(
                    title: const Text("Delivered"),
                    content: const Text("Your order has been delivered."),
                    isActive: false,
                    state: StepState.indexed,
                  ),
                ],
              ),
            ),

            const Divider(),
            const Text("🛒 Order Items",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),

            // Order items with base64 images
            ...orderItems.map((item) {
              final name = item['name'] ?? '';
              final qty = item['quantity'] ?? 1;
              final price = item['price'] ?? 0;
              final subtotal = price * qty;
              final base64Image = item['image'];

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 6),
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
                    : const Icon(Icons.shopping_cart),
                title: Text(name),
                subtitle: Text("Quantity: $qty"),
                trailing: Text("₹${subtotal.toStringAsFixed(2)}"),
              );
            }),

            const Divider(),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                "Total: ₹${totalAmount.toStringAsFixed(2)}",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 24),

            // ✅ PDF Button
            Center(
              child: ElevatedButton.icon(
                onPressed: _downloadPdf,
                icon: const Icon(Icons.download),
                label: const Text("Download PDF Receipt"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ✅ Continue Shopping Button
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/home');
                },
                icon: const Icon(Icons.shopping_bag),
                label: const Text("Continue Shopping"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
