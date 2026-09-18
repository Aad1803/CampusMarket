import 'package:campusmarket/constant/const.dart';
import 'package:flutter/material.dart';

class ProductDetailScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetailScreen({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  static const Color themeColor = Color(0xFF2563EB);
  static const Color backgroundColor = Color(0xFFF7F8FA);
  static const Color whiteColor = Colors.white;
  static const Color primaryTextColor = Color(0xFF111827);
  static const Color secondaryTextColor = Color(0xFF6B7280);
  static const Color lightTextColor = Color(0xFF9CA3AF);
  static const Color borderColor = Color(0xFFE5E7EB);
  static const Color successColor = Color(0xFF16A34A);

  final PageController pageController = PageController();

  int selectedImage = 0;
  bool isFavorite = false;

  final List<String> productImages = [
    'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?auto=format&fit=crop&w=1200&q=80',
    'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?auto=format&fit=crop&w=1200&q=80',
    'https://images.unsplash.com/photo-1541807084-5c52b6b3adef?auto=format&fit=crop&w=1200&q=80',
  ];

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Scaffold(
      backgroundColor: backgroundColor,

      appBar: AppBar(
        backgroundColor: whiteColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: primaryTextColor,
            size: 20,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                isFavorite = !isFavorite;
              });
            },
            icon: Icon(
              isFavorite
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              color: isFavorite ? Colors.red : primaryTextColor,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.share_outlined,
              color: primaryTextColor,
            ),
          ),
          const SizedBox(width: 6),
        ],
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ------------------------------------------------
            // IMAGE CAROUSEL
            // ------------------------------------------------
            SizedBox(
              height: 330,
              child: Stack(
                children: [
                  PageView.builder(
                    controller: pageController,
                    itemCount: productImages.length,
                    onPageChanged: (index) {
                      setState(() {
                        selectedImage = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return Image.network(
                        productImages[index],
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              size: 50,
                              color: lightTextColor,
                            ),
                          );
                        },
                      );
                    },
                  ),

                  // Image counter
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: primaryTextColor.withOpacity(0.75),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${selectedImage + 1}/${productImages.length}',
                        style: const TextStyle(
                          color: whiteColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  // Page indicators
                  Positioned(
                    bottom: 16,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        productImages.length,
                        (index) {
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            height: 7,
                            width: selectedImage == index ? 22 : 7,
                            decoration: BoxDecoration(
                              color: selectedImage == index
                                  ? whiteColor
                                  : whiteColor.withOpacity(0.55),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ------------------------------------------------
            // PRODUCT INFORMATION
            // ------------------------------------------------
            Container(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
              color: whiteColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category + Condition
                  Row(
                    children: [
                      _InfoBadge(
                        text: product['category'] ?? 'Electronics',
                        backgroundColor: const Color(0xFFEFF6FF),
                        textColor: themeColor,
                      ),
                      const SizedBox(width: 8),
                      _InfoBadge(
                        text: product['condition'] ?? 'Like New',
                        backgroundColor: const Color(0xFFF0FDF4),
                        textColor: successColor,
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Product name
                  Text(
                    product['name'] ?? 'MacBook Air M2',
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w700,
                      color: primaryTextColor,
                      height: 1.2,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Price
                  Text(
                    product['price'] ?? '\$750',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: themeColor,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Location / university
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 18,
                        color: secondaryTextColor,
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Cleveland State University',
                        style: TextStyle(
                          fontSize: 13,
                          color: secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // ------------------------------------------------
            // DESCRIPTION
            // ------------------------------------------------
            Container(
              padding: const EdgeInsets.all(20),
              color: whiteColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      color: primaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    product['description'] ??
                        'This product is in excellent condition and works perfectly. '
                            'It has been well maintained and is ready for its new owner. '
                            'Feel free to message the seller if you have any questions '
                            'or would like to make an offer.',
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.7,
                      color: secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // ------------------------------------------------
            // PRODUCT DETAILS
            // ------------------------------------------------
            Container(
              padding: const EdgeInsets.all(20),
              color: whiteColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Product Details',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      color: primaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _DetailRow(
                    title: 'Category',
                    value: product['category'] ?? 'Electronics',
                  ),
                  _DetailRow(
                    title: 'Condition',
                    value: product['condition'] ?? 'Like New',
                  ),
                  _DetailRow(
                    title: 'Availability',
                    value: 'Available',
                    valueColor: successColor,
                  ),
                  _DetailRow(
                    title: 'Listed',
                    value: '2 days ago',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // ------------------------------------------------
            // SELLER
            // ------------------------------------------------
            Container(
              padding: const EdgeInsets.all(20),
              color: whiteColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Seller',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      color: primaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      // Seller image
                      Container(
                        height: 54,
                        width: 54,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFEFF6FF),
                        ),
                        child: const Icon(
                          Icons.person_rounded,
                          size: 30,
                          color: themeColor,
                        ),
                      ),

                      const SizedBox(width: 13),

                      // Seller information
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product['seller'] ?? 'Alex Johnson',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: primaryTextColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Cleveland State University',
                              style: TextStyle(
                                fontSize: 12,
                                color: secondaryTextColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.verified_rounded,
                                  size: 14,
                                  color: themeColor,
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  'Campus member',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: themeColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Seller profile button
                      Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: borderColor,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 15,
                          color: primaryTextColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 110),
          ],
        ),
      ),

      // ------------------------------------------------
      // MESSAGE SELLER BUTTON
      // ------------------------------------------------
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        decoration: BoxDecoration(
          color: whiteColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Favorite
              Container(
                height: 54,
                width: 54,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: borderColor,
                  ),
                ),
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      isFavorite = !isFavorite;
                    });
                  },
                  icon: Icon(
                    isFavorite
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: isFavorite ? Colors.red : primaryTextColor,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Message seller
              Expanded(
                child: SizedBox(
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Open chat screen later
                    },
                    icon: const Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 20,
                    ),
                    label: const Text(
                      'Message Seller',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeColor,
                      foregroundColor: whiteColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ------------------------------------------------
// INFO BADGE
// ------------------------------------------------

class _InfoBadge extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;

  const _InfoBadge({
    required this.text,
    required this.backgroundColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}

// ------------------------------------------------
// DETAIL ROW
// ------------------------------------------------

class _DetailRow extends StatelessWidget {
  final String title;
  final String value;
  final Color? valueColor;

  const _DetailRow({
    required this.title,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              color: secondaryTextColor,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: valueColor ?? primaryTextColor,
            ),
          ),
        ],
      ),
    );
  }
}
