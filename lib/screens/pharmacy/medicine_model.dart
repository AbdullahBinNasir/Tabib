class Medicine {
  final String id;
  final String name;
  final String description;
  final double price;
  final int stock;
  final String imageUrl;
  final String category;
  final String expiryDate;
  final bool isAvailable;

  Medicine({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.imageUrl,
    required this.category,
    required this.expiryDate,
    required this.isAvailable,
  });

  factory Medicine.fromMap(Map<String, dynamic> data, String docId) {
    return Medicine(
      id: docId,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      stock: data['stock'] ?? 0,
      imageUrl: data['imageUrl'] ?? '',
      category: data['category'] ?? '',
      expiryDate: data['expiryDate'] ?? '',
      isAvailable: data['isAvailable'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'imageUrl': imageUrl,
      'category': category,
      'expiryDate': expiryDate,
      'isAvailable': isAvailable,
    };
  }
}
