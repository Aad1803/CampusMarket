import 'package:campusmarket/homescreen/product_detail_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Colors
  static const Color themeColor = Color(0xFF2563EB);
  static const Color backgroundColor = Color(0xFFF7F8FA);
  static const Color whiteColor = Colors.white;
  static const Color primaryTextColor = Color(0xFF111827);
  static const Color secondaryTextColor = Color(0xFF6B7280);
  static const Color lightTextColor = Color(0xFF9CA3AF);
  static const Color borderColor = Color(0xFFE5E7EB);
  static const Color cardColor = Colors.white;

  final TextEditingController searchController = TextEditingController();

  int selectedCategory = 0;

  final List<String> categories = [
    'All',
    'Electronics',
    'Books',
    'Furniture',
    'Clothing',
    'Vehicles',
    'Other',
  ];

  final List<Map<String, dynamic>> products = [
    {
      'name': 'MacBook Air M2',
      'price': '\$750',
      'category': 'Electronics',
      'condition': 'Like New',
      'seller': 'Alex Johnson',
      'image':
          'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?auto=format&fit=crop&w=800&q=80',
    },
    {
      'name': 'Calculus Textbook',
      'price': '\$35',
      'category': 'Books',
      'condition': 'Good',
      'seller': 'Sarah Miller',
      'image':
          'https://images.unsplash.com/photo-1544947950-fa07a98d237f?auto=format&fit=crop&w=800&q=80',
    },
    {
      'name': 'Study Desk',
      'price': '\$80',
      'category': 'Furniture',
      'condition': 'Good',
      'seller': 'Michael Lee',
      'image':
          'https://images.unsplash.com/photo-1518455027359-f3f8164ba6b0?auto=format&fit=crop&w=800&q=80',
    },
    {
      'name': 'Winter Jacket',
      'price': '\$45',
      'category': 'Clothing',
      'condition': 'Like New',
      'seller': 'Emma Wilson',
      'image':
          'https://images.unsplash.com/photo-1551028719-00167b16eac5?auto=format&fit=crop&w=800&q=80',
    },
    {
      'name': 'iPhone 15',
      'price': '\$550',
      'category': 'Electronics',
      'condition': 'Good',
      'seller': 'David Brown',
      'image':
          'https://images.unsplash.com/photo-1592750475338-74b7b21085ab?auto=format&fit=crop&w=800&q=80',
    },
    {
      'name': 'Office Chair',
      'price': '\$60',
      'category': 'Furniture',
      'condition': 'Good',
      'seller': 'Chris Wilson',
      'image':
          'https://images.unsplash.com/photo-1580480055273-228ff5388ef8?auto=format&fit=crop&w=800&q=80',
    },
  ];
  List<Map<String, dynamic>> get filteredProducts {
    if (selectedCategory == 0) {
      return products;
    }

    final category = categories[selectedCategory];

    return products
        .where((product) => product['category'] == category)
        .toList();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: _buildHeader(),
              ),
            ),

            // Search
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: _buildSearchBar(),
              ),
            ),

            // Categories title
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 28, 20, 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Categories',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                        color: primaryTextColor,
                      ),
                    ),
                    Text(
                      'See all',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: themeColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Categories
            SliverToBoxAdapter(
              child: SizedBox(
                height: 42,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    return _buildCategoryChip(index);
                  },
                ),
              ),
            ),

            // Filter options
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 25, 20, 15),
                child: _buildFilterSection(),
              ),
            ),

            // Product heading
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 5, 20, 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recommended for you',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                        color: primaryTextColor,
                      ),
                    ),
                    Text(
                      '${filteredProducts.length} items',
                      style: const TextStyle(
                        fontSize: 13,
                        color: secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Product Grid
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final product = filteredProducts[index];

                    return _buildProductCard(product);
                  },
                  childCount: filteredProducts.length,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.65,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------
  // HEADER
  // --------------------------------------------------

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          height: 46,
          width: 46,
          decoration: BoxDecoration(
            color: themeColor,
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Icon(
            Icons.storefront_rounded,
            color: whiteColor,
            size: 25,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good morning 👋',
                style: TextStyle(
                  fontSize: 13,
                  color: secondaryTextColor,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Campus Marketplace',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: primaryTextColor,
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 44,
          width: 44,
          decoration: BoxDecoration(
            color: whiteColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: borderColor,
            ),
          ),
          child: const Icon(
            Icons.notifications_none_rounded,
            color: primaryTextColor,
            size: 23,
          ),
        ),
      ],
    );
  }

  // --------------------------------------------------
  // SEARCH
  // --------------------------------------------------

  Widget _buildSearchBar() {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: TextField(
        controller: searchController,
        decoration: const InputDecoration(
          hintText: 'Search products...',
          hintStyle: TextStyle(
            color: lightTextColor,
            fontSize: 14,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: secondaryTextColor,
            size: 23,
          ),
          suffixIcon: Icon(
            Icons.tune_rounded,
            color: themeColor,
            size: 21,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            vertical: 16,
          ),
        ),
      ),
    );
  }

  // --------------------------------------------------
  // CATEGORY CHIP
  // --------------------------------------------------

  Widget _buildCategoryChip(int index) {
    final bool isSelected = selectedCategory == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 9),
        padding: const EdgeInsets.symmetric(horizontal: 17),
        decoration: BoxDecoration(
          color: isSelected ? themeColor : whiteColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? themeColor : borderColor,
          ),
        ),
        child: Center(
          child: Text(
            categories[index],
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isSelected ? whiteColor : secondaryTextColor,
            ),
          ),
        ),
      ),
    );
  }

  // --------------------------------------------------
  // FILTER SECTION
  // --------------------------------------------------

  Widget _buildFilterSection() {
    return Row(
      children: [
        _buildOptionButton(
          icon: Icons.tune_rounded,
          title: 'Filter',
        ),
        const SizedBox(width: 9),
        _buildOptionButton(
          icon: Icons.swap_vert_rounded,
          title: 'Sort',
        ),
        const SizedBox(width: 9),
        _buildOptionButton(
          icon: Icons.attach_money_rounded,
          title: 'Price',
        ),
        const SizedBox(width: 9),
        _buildOptionButton(
          icon: Icons.auto_awesome_outlined,
          title: 'New',
        ),
      ],
    );
  }

  Widget _buildOptionButton({
    required IconData icon,
    required String title,
  }) {
    return Expanded(
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: whiteColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: borderColor,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: secondaryTextColor,
            ),
            const SizedBox(width: 5),
            Text(
              title,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: secondaryTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------
  // PRODUCT CARD
  // --------------------------------------------------

  Widget _buildProductCard(Map<String, dynamic> product) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(
              product: product,
            ),
          ),
        );
        // Product details screen will be added later.
      },
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: borderColor,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image placeholder
            Expanded(
              flex: 5,
              child: Stack(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: double.infinity,
                    child: Image.network(
                      product['image'],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            size: 40,
                            color: lightTextColor,
                          ),
                        );
                      },
                    ),
                  ),

                  // Favorite
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      height: 34,
                      width: 34,
                      decoration: BoxDecoration(
                        color: whiteColor.withOpacity(0.92),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.favorite_border_rounded,
                        size: 18,
                        color: primaryTextColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Product information
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product['name'],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: primaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      product['price'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: themeColor,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            product['condition'],
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              color: secondaryTextColor,
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4),
                          child: Text(
                            '•',
                            style: TextStyle(
                              color: lightTextColor,
                            ),
                          ),
                        ),
                        Flexible(
                          child: Text(
                            product['category'],
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              color: secondaryTextColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Container(
                          height: 22,
                          width: 22,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE5E7EB),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.person,
                            size: 13,
                            color: secondaryTextColor,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            product['seller'],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: secondaryTextColor,
                            ),
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
      ),
    );
  }
}
