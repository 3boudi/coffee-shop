import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import '../../models/product.dart';
import '../../models/order.dart';
import '../../services/appwrite_service.dart';

class UserHome extends StatefulWidget {
  final models.User user;
  final VoidCallback onLogout;
  final Client client;

  const UserHome({
    super.key,
    required this.user,
    required this.onLogout,
    required this.client,
  });

  @override
  State<UserHome> createState() => _UserHomeState();
}

class UserOrders extends StatefulWidget {
  final models.User user;
  final Client client;

  const UserOrders({super.key, required this.user, required this.client});

  @override
  State<UserOrders> createState() => _UserOrdersState();
}

class _UserOrdersState extends State<UserOrders> {
  late AppwriteService _appwriteService;
  List<Order> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _appwriteService = AppwriteService(widget.client);
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    try {
      final orders = await _appwriteService.getOrders(userId: widget.user.$id);
      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading orders: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _orders.isEmpty
          ? const Center(
              child: Text(
                'No orders yet',
                style: TextStyle(color: Colors.brown),
              ),
            )
          : ListView.builder(
              itemCount: _orders.length,
              itemBuilder: (context, index) {
                final order = _orders[index];
                return AnimatedOpacity(
                  opacity: 1.0,
                  duration: const Duration(milliseconds: 500),
                  child: Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    color: Colors.blue.shade50,
                    elevation: 4,
                    child: ExpansionTile(
                      title: Text(
                        'Order #${order.id.substring(0, 8)}',
                        style: const TextStyle(color: Colors.blue),
                      ),
                      subtitle: Text(
                        'Status: ${order.status.name} | Total: \$${order.totalPrice.toStringAsFixed(2)}',
                        style: TextStyle(color: Colors.blue.shade700),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Ordered on: ${order.createdAt.toLocal()}',
                                style: const TextStyle(color: Colors.brown),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Items:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.brown,
                                ),
                              ),
                              ...order.products.map(
                                (item) => Text(
                                  '- Product ${item.productId}: ${item.quantity}x',
                                  style: TextStyle(
                                    color: Colors.brown.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class UserProfile extends StatelessWidget {
  final models.User user;

  const UserProfile({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedOpacity(
        opacity: 1.0,
        duration: const Duration(milliseconds: 500),
        child: Container(
          padding: const EdgeInsets.all(24),
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.brown.shade50,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.person, size: 96, color: Colors.blue),
              const SizedBox(height: 16),
              Text(
                'User Profile',
                style: Theme.of(
                  context,
                ).textTheme.headlineMedium?.copyWith(color: Colors.brown),
              ),
              const SizedBox(height: 16),
              Text(
                'Name: ${user.name}',
                style: const TextStyle(color: Colors.blue),
              ),
              const SizedBox(height: 8),
              Text(
                'Email: ${user.email}',
                style: const TextStyle(color: Colors.blue),
              ),
              const SizedBox(height: 8),
              const Text('Role: User', style: TextStyle(color: Colors.blue)),
              const SizedBox(height: 16),
              Text(
                'Joined: ${user.registration.isNotEmpty ? DateTime.parse(user.registration).year : 'N/A'}',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.blue),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserHomeState extends State<UserHome> with TickerProviderStateMixin {
  late TabController _tabController;
  late AppwriteService _appwriteService;
  List<Product> _products = [];
  List<Order> _orders = [];
  Map<String, int> _cart = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _appwriteService = AppwriteService(widget.client);
    _loadProducts();
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

    // Subscribe to user's order updates
    _appwriteService.subscribeToOrders((order) {
      if (order.userId == widget.user.$id) {
        setState(() {
          final index = _orders.indexWhere((o) => o.id == order.id);
          if (index != -1) {
            _orders[index] = order;
          } else {
            _orders.add(order);
          }
        });
      }
    }, userId: widget.user.$id);
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    try {
      final products = await _appwriteService.getProducts();
      final orders = await _appwriteService.getOrders(userId: widget.user.$id);
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

  void _addToCart(String productId) {
    setState(() {
      _cart[productId] = (_cart[productId] ?? 0) + 1;
    });
  }

  void _removeFromCart(String productId) {
    setState(() {
      if (_cart[productId] != null && _cart[productId]! > 0) {
        _cart[productId] = _cart[productId]! - 1;
        if (_cart[productId] == 0) {
          _cart.remove(productId);
        }
      }
    });
  }

  double _calculateTotal() {
    double total = 0;
    _cart.forEach((productId, quantity) {
      final product = _products.firstWhere((p) => p.id == productId);
      total += product.price * quantity;
    });
    return total;
  }

  Future<void> _placeOrder() async {
    if (_cart.isEmpty) return;

    try {
      final orderItems = _cart.entries.map((entry) {
        return OrderItem(productId: entry.key, quantity: entry.value);
      }).toList();

      final order = Order(
        id: '',
        userId: widget.user.$id,
        products: orderItems,
        status: OrderStatus.pending,
        totalPrice: _calculateTotal(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _appwriteService.createOrder(order);
      setState(() => _cart.clear());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order placed successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error placing order: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Coffee Cart'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: widget.onLogout,
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.brown,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Home', icon: Icon(Icons.home)),
            Tab(text: 'Orders', icon: Icon(Icons.shopping_cart)),
            Tab(text: 'Profile', icon: Icon(Icons.person)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildHomeTab(),
          _buildOrdersTab(),
          UserProfile(user: widget.user),
        ],
      ),
    );
  }

  Widget _buildOrdersTab() {
    return Scaffold(
      appBar: AppBar(title: const Text('My Orders')),
      body: _orders.isEmpty
          ? const Center(child: Text('No orders yet'))
          : ListView.builder(
              itemCount: _orders.length,
              itemBuilder: (context, index) {
                final order = _orders[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
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
                            Text('Ordered on: ${order.createdAt.toLocal()}'),
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
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildHomeTab() {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _products.isEmpty
        ? const Center(child: Text('No products available'))
        : Column(
            children: [
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: _products.length,
                  itemBuilder: (context, index) {
                    final product = _products[index];
                    final quantity = _cart[product.id] ?? 0;

                    return AnimatedOpacity(
                      opacity: 1.0,
                      duration: const Duration(milliseconds: 500),
                      child: Card(
                        elevation: 4,
                        color: Colors.brown.shade50,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade100,
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(4),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.coffee,
                                  size: 48,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.brown,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    product.description,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.brown.shade600,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '\$${product.price.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: quantity > 0
                                            ? () => _removeFromCart(product.id)
                                            : null,
                                        icon: const Icon(Icons.remove),
                                        color: Colors.red,
                                      ),
                                      Text(
                                        quantity.toString(),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.brown,
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () => _addToCart(product.id),
                                        icon: const Icon(Icons.add),
                                        color: Colors.green,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (_cart.isNotEmpty)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(16),
                  color: Colors.brown.shade100,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Total: \$${_calculateTotal().toStringAsFixed(2)} (${_cart.values.fold(0, (sum, qty) => sum + qty)} items)',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _placeOrder,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Place Order'),
                      ),
                    ],
                  ),
                ),
            ],
          );
  }
}
