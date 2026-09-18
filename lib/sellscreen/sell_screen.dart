// import 'dart:io';

// import 'package:campusmarket/constant/const.dart';
// import 'package:campusmarket/sellscreen/create_product_screen.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';

// class SellScreen extends StatefulWidget {
//   const SellScreen({Key? key}) : super(key: key);

//   @override
//   State<SellScreen> createState() => _SellScreenState();
// }

// class _SellScreenState extends State<SellScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       floatingActionButton: FloatingActionButton(onPressed: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => CreateProductScreen(
//               userId: user['userId'],
//               sellerName: user['name'],
//               sellerUniversity: user['university'],
//             ),
//           ),
//         );
//       }),
//     );
//   }
// }
// import 'dart:convert';

import 'package:campusmarket/sellscreen/create_product_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:campusmarket/constant/const.dart';

class SellScreen extends StatefulWidget {
  const SellScreen({super.key});

  @override
  State<SellScreen> createState() => _SellScreenState();
}

class _SellScreenState extends State<SellScreen> {
  bool isLoading = true;

  List<Map<String, dynamic>> products = [];

  @override
  void initState() {
    super.initState();
    fetchMyProducts();
  }

  Future<void> fetchMyProducts() async {
    try {
      setState(() {
        isLoading = true;
      });

      final snapshot = await FirebaseFirestore.instance
          .collection('products')
          .where(
            'userId',
            isEqualTo: user['userId'],
          )
          .get();

      final List<Map<String, dynamic>> loadedProducts =
          snapshot.docs.map((doc) {
        return {
          'documentId': doc.id,
          ...doc.data(),
        };
      }).toList();

      if (!mounted) return;

      setState(() {
        products = loadedProducts;
        isLoading = false;
      });
    } catch (e) {
      print(e);
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load products: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F8),
      floatingActionButton: FloatingActionButton(onPressed: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CreateProductScreen(
              userId: user['userId'],
              sellerName: user['name'],
              sellerUniversity: user['university'],
            ),
          ),
        );
        fetchMyProducts();
      }),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'My Listings',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: fetchMyProducts,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : products.isEmpty
              ? buildEmptyState()
              : RefreshIndicator(
                  onRefresh: fetchMyProducts,
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 320,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.72,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      return buildProductCard(
                        products[index],
                      );
                    },
                  ),
                ),
    );
  }

  Widget buildEmptyState() {
    return RefreshIndicator(
      onRefresh: fetchMyProducts,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.30,
          ),
          const Icon(
            Icons.storefront_outlined,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 20),
          const Center(
            child: Text(
              'No Listings Yet',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text(
              'Products you list for sale will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildProductCard(Map<String, dynamic> product) {
    final String name = product['name']?.toString() ?? 'Untitled Product';

    final String price = (product['price'] ?? "")?.toString() ?? "0";

    final String category = product['category']?.toString() ?? 'Other';

    final String condition = product['condition']?.toString() ?? '';

    final String status = product['status']?.toString() ?? 'available';

    final List<dynamic> images = product['images'] ?? [];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          Expanded(
            flex: 6,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
              child: images.isNotEmpty
                  ? buildProductImage(images[0])
                  : Container(
                      width: double.infinity,
                      color: Colors.grey.shade100,
                      child: const Center(
                        child: Icon(
                          Icons.image_outlined,
                          size: 50,
                          color: Colors.grey,
                        ),
                      ),
                    ),
            ),
          ),

          // Product Details
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '\$${price}',
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      buildTag(category),
                      if (condition.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        buildTag(condition),
                      ],
                    ],
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: status == 'available'
                              ? Colors.green.withOpacity(0.1)
                              : Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          status.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: status == 'available'
                                ? Colors.green
                                : Colors.orange,
                          ),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                          // Edit / Delete menu later
                        },
                        icon: const Icon(
                          Icons.more_horiz,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildProductImage(dynamic image) {
    try {
      return Image.memory(
        base64Decode(
          image.toString(),
        ),
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
      );
    } catch (e) {
      return Container(
        width: double.infinity,
        color: Colors.grey.shade100,
        child: const Center(
          child: Icon(
            Icons.broken_image_outlined,
            size: 45,
            color: Colors.grey,
          ),
        ),
      );
    }
  }

  Widget buildTag(String text) {
    return Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 5,
        ),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.black54,
          ),
        ),
      ),
    );
  }
}
