import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:campusmarket/constant/const.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CreateProductScreen extends StatefulWidget {
  final String userId;
  final String sellerName;
  final String sellerUniversity;

  const CreateProductScreen({
    super.key,
    required this.userId,
    required this.sellerName,
    required this.sellerUniversity,
  });

  @override
  State<CreateProductScreen> createState() => _CreateProductScreenState();
}

class _CreateProductScreenState extends State<CreateProductScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  List<XFile> selectedImages = [];

  String? selectedCategory;
  String? selectedCondition;

  bool isUploading = false;

  final List<String> conditions = [
    'New',
    'Like New',
    'Good',
    'Fair',
  ];

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  // ============================================================
  // PICK IMAGES
  // ============================================================

  Future<void> pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        imageQuality: 80,
      );

      if (images.isEmpty) {
        return;
      }

      setState(() {
        selectedImages.addAll(images);
      });
    } catch (e) {
      showMessage('Could not select images');
    }
  }

  // ============================================================
  // REMOVE IMAGE
  // ============================================================

  void removeImage(int index) {
    setState(() {
      selectedImages.removeAt(index);
    });
  }

  // ============================================================
  // UPLOAD IMAGES TO FIREBASE STORAGE
  // ============================================================

  // ============================================================
  // CREATE PRODUCT
  // ============================================================

  Future<void> createProduct() async {
    final name = nameController.text.trim();
    final priceText = priceController.text.trim();
    final description = descriptionController.text.trim();

    // Validation
    if (selectedImages.isEmpty) {
      showMessage('Please add at least one product picture');
      return;
    }

    if (name.isEmpty) {
      showMessage('Please enter product name');
      return;
    }

    if (priceText.isEmpty) {
      showMessage('Please enter product price');
      return;
    }

    final price = double.tryParse(priceText);

    if (price == null || price <= 0) {
      showMessage('Please enter a valid price');
      return;
    }

    if (description.isEmpty) {
      showMessage('Please enter product description');
      return;
    }

    if (selectedCategory == null) {
      showMessage('Please select a category');
      return;
    }

    if (selectedCondition == null) {
      showMessage('Please select product condition');
      return;
    }

    setState(() {
      isUploading = true;
    });

    try {
      // ----------------------------------------------------------
      // CREATE PRODUCT DOCUMENT
      // ----------------------------------------------------------

      final productRef =
          FirebaseFirestore.instance.collection('products').doc();

      final productId = productRef.id;

      // ----------------------------------------------------------
      // UPLOAD IMAGES
      // ----------------------------------------------------------

      List<String> imageData = [];

      for (final image in selectedImages) {
        final Uint8List bytes = await image.readAsBytes();

        final String base64Image = base64Encode(bytes);

        imageData.add(base64Image);
      }
      // ----------------------------------------------------------
      // SAVE PRODUCT TO FIRESTORE
      // ----------------------------------------------------------

      await productRef.set({
        'productId': productId,
        'name': name,
        'price': price,
        'description': description,
        'category': selectedCategory,
        'condition': selectedCondition,
        'images': imageData,
        'sellerName': widget.sellerName,
        'sellerUniversity': widget.sellerUniversity,
        'userId': widget.userId,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'available',
        'user': user
      });

      if (!mounted) return;

      setState(() {
        isUploading = false;
      });

      showMessage('Product listed successfully!');

      // Go back
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isUploading = false;
      });

      showMessage('Failed to add product: $e');
    }
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  // ============================================================
  // UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8F8F8),
      appBar: AppBar(
        title: const Text(
          'Sell an Item',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==================================================
              // PICTURES
              // ==================================================

              const Text(
                'Product Pictures',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Add multiple pictures so buyers can see your item clearly.',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 15),

              SizedBox(
                height: 110,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    // Add image button
                    GestureDetector(
                      onTap: pickImages,
                      child: Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.grey.shade300,
                          ),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_a_photo_outlined,
                              size: 30,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Add Photos',
                              style: TextStyle(
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    // Selected images
                    ...List.generate(
                      selectedImages.length,
                      (index) {
                        return Container(
                          width: 110,
                          margin: const EdgeInsets.only(right: 10),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child:
                                    // Platform.isAndroid
                                    //     ? Image.file(
                                    //         File(
                                    //           selectedImages[index].path,
                                    //         ),
                                    //         width: 110,
                                    //         height: 110,
                                    //         fit: BoxFit.cover,
                                    //       )
                                    //     :
                                    FutureBuilder<Uint8List>(
                                  future: selectedImages[index].readAsBytes(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    }

                                    if (snapshot.hasError ||
                                        !snapshot.hasData) {
                                      return const Center(
                                        child: Icon(Icons.error),
                                      );
                                    }

                                    return Image.memory(
                                      snapshot.data!,
                                      fit: BoxFit.cover,
                                    );
                                  },
                                ),
                              ),
                              Positioned(
                                right: 5,
                                top: 5,
                                child: GestureDetector(
                                  onTap: () {
                                    removeImage(index);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: const BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // ==================================================
              // PRODUCT NAME
              // ==================================================

              const Text(
                'Product Name',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 8),

              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: 'e.g. MacBook Air M2',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ==================================================
              // PRICE
              // ==================================================

              const Text(
                'Price',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 8),

              TextField(
                controller: priceController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  hintText: '0.00',
                  prefixText: '\$ ',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ==================================================
              // CATEGORY
              // ==================================================

              const Text(
                'Category',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 8),

              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: InputDecoration(
                  hintText: 'Select category',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value;
                  });
                },
              ),

              const SizedBox(height: 20),

              // ==================================================
              // CONDITION
              // ==================================================

              const Text(
                'Condition',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 8),

              DropdownButtonFormField<String>(
                value: selectedCondition,
                decoration: InputDecoration(
                  hintText: 'Select condition',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: conditions.map((condition) {
                  return DropdownMenuItem(
                    value: condition,
                    child: Text(condition),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCondition = value;
                  });
                },
              ),

              const SizedBox(height: 20),

              // ==================================================
              // DESCRIPTION
              // ==================================================

              const Text(
                'Description',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 8),

              TextField(
                controller: descriptionController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText:
                      'Describe the item, its condition, and anything buyers should know...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // ==================================================
              // SELLER INFORMATION
              // ==================================================

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      child: Icon(Icons.person),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.sellerName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            widget.sellerUniversity,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // ==================================================
              // PUBLISH BUTTON
              // ==================================================

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: isUploading ? null : createProduct,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: isUploading
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Publishing...',
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ],
                        )
                      : const Text(
                          'Publish Product',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
