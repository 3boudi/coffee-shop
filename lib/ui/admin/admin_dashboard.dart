import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import '../../models/product.dart';
import '../../models/order.dart';
import '../../services/appwrite_service.dart';

class AdminDashboard extends StatefulWidget {
  final models.User user;
  final VoidCallback onLogout;
  final Client client;

  const AdminDashboard({
    super.key,
    required this.user,
    required this.onLogout,
    required this.client,
  });

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AppwriteService _appwriteService;

  List<Product> _products = [];
  List<Order> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _appwriteService = AppwriteService(widget.client);
    _loadData();
    _setupRealtimeSubscriptions();
  }

  void _setupRealtimeSubscriptions() {
    // Subscribe to product updates
    _appwriteService.subscribeToProducts((product) {
      setState(() {
        final index = _products.indexWhere((p) => p.id == product.id);
        if (index != -1) {
          _products[index] = product;
        } else {
          _products.add(product);
        }
      });
    });

    // Subscribe to order updates
    _appwriteService.subscribeToOrders((order) {
      setState(() {
        final index = _orders.indexWhere((o) => o.id == order.id);
        if (index != -1) {
          _orders[index] = order;
        } else {
          _orders.add(order);
        }
      });
    });
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final products = await _appwriteService.getProducts();
      final orders = await _appwriteService.getOrders();
      setState(() {
        _products = products;
        _orders = orders;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading data: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            onPressed: widget.onLogout,
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Home', icon: Icon(Icons.home)),
            Tab(text: 'Orders', icon: Icon(Icons.shopping_cart)),
            Tab(text: 'Profile', icon: Icon(Icons.person)),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildHomeTab(),
                _buildOrdersTab(),
                _buildProfileTab(),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddProductDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildHomeTab() {
    return ListView.builder(
      itemCount: _products.length,
      itemBuilder: (context, index) {
        final product = _products[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: Text(product.name),
            subtitle: Text(
              '${product.description}\n\$${product.price.toStringAsFixed(2)}',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showEditProductDialog(product),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deleteProduct(product.id),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileTab() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.person, size: 96, color: Colors.brown),
          const SizedBox(height: 16),
          Text(
            'Owner Profile',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          Text('Name: ${widget.user.name}'),
          const SizedBox(height: 8),
          Text('Email: ${widget.user.email}'),
          const SizedBox(height: 8),
          const Text('Role: Owner'),
          const SizedBox(height: 16),
          Text(
            'Joined: ${widget.user.registration.isNotEmpty ? DateTime.parse(widget.user.registration).year : 'N/A'}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersTab() {
    return ListView.builder(
      itemCount: _orders.length,
      itemBuilder: (context, index) {
        final order = _orders[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ExpansionTile(
            title: Text('Order #${order.id.substring(0, 8)}'),
            subtitle: Text(
              'Status: ${order.status.name} | Total: \$${order.totalPrice.toStringAsFixed(2)}',
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('User ID: ${order.userId}'),
                    const SizedBox(height: 8),
                    const Text(
                      'Items:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    ...order.products.map(
                      (item) => Text(
                        '- Product ${item.productId}: ${item.quantity}x',
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (order.status == OrderStatus.pending)
                      ElevatedButton(
                        onPressed: () => _confirmOrder(order.id),
                        child: const Text('Confirm Order'),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddProductDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Product'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final description = descriptionController.text.trim();
              final price = double.tryParse(priceController.text);

              if (name.isEmpty || description.isEmpty || price == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please fill all fields correctly'),
                  ),
                );
                return;
              }

              try {
                final product = Product(
                  id: '',
                  name: name,
                  description: description,
                  price: price,
                  createdBy: widget.user.$id,
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                );

                await _appwriteService.createProduct(product);
                Navigator.of(context).pop();
                _loadData();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error adding product: $e')),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditProductDialog(Product product) {
    final nameController = TextEditingController(text: product.name);
    final descriptionController = TextEditingController(
      text: product.description,
    );
    final priceController = TextEditingController(
      text: product.price.toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Product'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final description = descriptionController.text.trim();
              final price = double.tryParse(priceController.text);

              if (name.isEmpty || description.isEmpty || price == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please fill all fields correctly'),
                  ),
                );
                return;
              }

              try {
                final updatedProduct = product.copyWith(
                  name: name,
                  description: description,
                  price: price,
                  updatedAt: DateTime.now(),
                );

                await _appwriteService.updateProduct(
                  product.id,
                  updatedProduct,
                );
                Navigator.of(context).pop();
                _loadData();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error updating product: $e')),
                );
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteProduct(String productId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: const Text('Are you sure you want to delete this product?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _appwriteService.deleteProduct(productId);
        _loadData();
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error deleting product: $e')));
      }
    }
  }

  Future<void> _confirmOrder(String orderId) async {
    try {
      final order = _orders.firstWhere((o) => o.id == orderId);
      final updatedOrder = order.copyWith(status: OrderStatus.confirmed);
      await _appwriteService.updateOrder(orderId, updatedOrder);
      _loadData();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error confirming order: $e')));
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
