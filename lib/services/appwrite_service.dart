// Temporarily silence deprecation warnings for Appwrite document APIs.
// These APIs are deprecated in the newer Appwrite SDK; a migration to
// TablesDB.listRows/createRow/updateRow/deleteRow should be performed
// in a follow-up change. For now we keep the existing implementation to
// minimize risk and CI churn.
// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:appwrite/appwrite.dart';
import '../models/product.dart';
import '../models/order.dart';

class AppwriteService {
  static const String _productsCollectionId =
      'products'; // Replace with actual collection ID
  static const String _ordersCollectionId =
      'orders'; // Replace with actual collection ID
  static const String _databaseId = 'shop_db';
  static const String _notificationFunctionId =
      '68f33097003af1f0089a'; // Notification function ID

  final Databases _databases;
  final Realtime _realtime;
  final Functions _functions;

  AppwriteService(Client client)
    : _databases = Databases(client),
      _realtime = Realtime(client),
      _functions = Functions(client);

  // Products CRUD Operations
  Future<List<Product>> getProducts() async {
    try {
      final response = await _databases.listDocuments(
        databaseId: _databaseId,
        collectionId: _productsCollectionId,
      );
      return response.documents
          .map((doc) => Product.fromJson(doc.data))
          .toList();
    } catch (e) {
      debugPrint('Error fetching products: $e');
      throw Exception('Failed to fetch products: $e');
    }
  }

  Future<Product> createProduct(Product product) async {
    try {
      final response = await _databases.createDocument(
        databaseId: _databaseId,
        collectionId: _productsCollectionId,
        documentId: ID.unique(),
        data: product.toJson(),
      );
      return Product.fromJson(response.data);
    } catch (e) {
      debugPrint('Error creating product: $e');
      throw Exception('Failed to create product: $e');
    }
  }

  Future<Product> updateProduct(String productId, Product product) async {
    try {
      final response = await _databases.updateDocument(
        databaseId: _databaseId,
        collectionId: _productsCollectionId,
        documentId: productId,
        data: product.toJson(),
      );
      return Product.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update product: $e');
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      await _databases.deleteDocument(
        databaseId: _databaseId,
        collectionId: _productsCollectionId,
        documentId: productId,
      );
    } catch (e) {
      throw Exception('Failed to delete product: $e');
    }
  }

  // Orders CRUD Operations
  Future<List<Order>> getOrders({String? userId}) async {
    try {
      final queries = userId != null
          ? [Query.equal('userId', userId)]
          : <String>[];
      final response = await _databases.listDocuments(
        databaseId: _databaseId,
        collectionId: _ordersCollectionId,
        queries: queries,
      );
      return response.documents.map((doc) => Order.fromJson(doc.data)).toList();
    } catch (e) {
      throw Exception('Failed to fetch orders: $e');
    }
  }

  Future<Order> createOrder(Order order) async {
    try {
      final response = await _databases.createDocument(
        databaseId: _databaseId,
        collectionId: _ordersCollectionId,
        documentId: ID.unique(),
        data: order.toJson(),
      );
      final createdOrder = Order.fromJson(response.data);

      // Send notification to owner about new order
      try {
        await _sendNotificationToOwner(createdOrder);
      } catch (e) {
        debugPrint('Failed to send new order notification: $e');
        // Don't fail order creation if notification fails
      }

      return createdOrder;
    } catch (e) {
      debugPrint('Error creating order: $e');
      throw Exception('Failed to create order: $e');
    }
  }

  Future<Order> updateOrder(String orderId, Order order) async {
    try {
      final response = await _databases.updateDocument(
        databaseId: _databaseId,
        collectionId: _ordersCollectionId,
        documentId: orderId,
        data: order.toJson(),
      );
      final updatedOrder = Order.fromJson(response.data);

      // Send notification to user if order was confirmed
      if (updatedOrder.status == OrderStatus.confirmed) {
        try {
          await _sendNotificationToUser(updatedOrder);
        } catch (e) {
          debugPrint('Failed to send order confirmation notification: $e');
          // Don't fail order update if notification fails
        }
      }

      return updatedOrder;
    } catch (e) {
      throw Exception('Failed to update order: $e');
    }
  }

  // Realtime Subscriptions
  StreamSubscription<RealtimeMessage> subscribeToProducts(
    void Function(Product) onProductUpdate,
  ) {
    return _realtime
        .subscribe([
          'databases.$_databaseId.collections.$_productsCollectionId.documents',
        ])
        .stream
        .listen((event) {
          try {
            if (event.events.any(
              (e) =>
                  e.contains('databases.*.collections.*.documents.*.create') ||
                  e.contains('databases.*.collections.*.documents.*.update') ||
                  e.contains('databases.*.collections.*.documents.*.delete'),
            )) {
              final product = Product.fromJson(event.payload);
              onProductUpdate(product);
            }
          } catch (e) {
            debugPrint('Error processing product realtime event: $e');
          }
        });
  }

  StreamSubscription<RealtimeMessage> subscribeToOrders(
    void Function(Order) onOrderUpdate, {
    String? userId,
  }) {
    return _realtime
        .subscribe([
          'databases.$_databaseId.collections.$_ordersCollectionId.documents',
        ])
        .stream
        .listen((event) {
          try {
            if (event.events.any(
              (e) =>
                  e.contains('databases.*.collections.*.documents.*.create') ||
                  e.contains('databases.*.collections.*.documents.*.update'),
            )) {
              final order = Order.fromJson(event.payload);
              if (userId == null || order.userId == userId) {
                onOrderUpdate(order);
              }
            }
          } catch (e) {
            debugPrint('Error processing order realtime event: $e');
          }
        });
  }

  // Notification helper methods
  Future<void> _sendNotificationToOwner(Order order) async {
    try {
      final payload = {
        'type': 'new_order',
        'orderId': order.id,
        'userId': order.userId,
        'totalPrice': order.totalPrice,
        'title': 'New Order Received! 📦',
        'body':
            'A new order has been placed for \$${order.totalPrice.toStringAsFixed(2)}',
      };

      final execution = await _functions.createExecution(
        functionId: _notificationFunctionId,
        body: jsonEncode(payload),
      );

      debugPrint('New order notification sent: ${execution.$id}');
    } catch (e) {
      debugPrint('Error sending notification to owner: $e');
      throw Exception('Failed to send notification: $e');
    }
  }

  Future<void> _sendNotificationToUser(Order order) async {
    try {
      final payload = {
        'type': 'order_confirmed',
        'userId': order.userId,
        'orderId': order.id,
        'totalPrice': order.totalPrice,
        'title': 'Order Confirmed! ✅',
        'body':
            'Your order has been confirmed. Total: \$${order.totalPrice.toStringAsFixed(2)}',
      };

      final execution = await _functions.createExecution(
        functionId: _notificationFunctionId,
        body: jsonEncode(payload),
      );

      debugPrint('Order confirmation notification sent: ${execution.$id}');
    } catch (e) {
      debugPrint('Error sending notification to user: $e');
      throw Exception('Failed to send notification: $e');
    }
  }
}
