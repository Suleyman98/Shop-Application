import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'cart.dart';
import 'dart:convert';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem(
      {required this.id,
      required this.amount,
      required this.products,
      required this.dateTime});
}

class Orders with ChangeNotifier {
  List<OrderItem>? orders = [];
  final String? authToken;
  final String? userId;
  Orders({this.orders, this.authToken, this.userId});

  List<OrderItem> get getorders {
    return [...orders!];
  }

  Future<void> fetchOrders() async {
    final url = Uri.parse(
        'https://shopapp-f3252-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken');
    final response = await http.get(url);
    final List<OrderItem> loadedOrders = [];
    final extractedOrders = json.decode(response.body) as Map<String, dynamic>;
    if (extractedOrders == {}) {
      return;
    }
    extractedOrders.forEach((key, value) {
      loadedOrders.add(OrderItem(
        amount: value['amount'],
        id: key,
        dateTime: DateTime.parse(value['dateTime']),
        products: (value['products'] as List<dynamic>).map((e) {
          return CartItem(
              id: e['id'],
              title: e['title'],
              quantity: e['quantity'],
              price: e['price']);
        }).toList(),
      ));
    });
    orders = loadedOrders.reversed.toList();
    notifyListeners();
  }

  Future<void> addOrder(List<CartItem> products, double total) async {
    final url = Uri.parse(
        'https://shopapp-f3252-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken');
    final res = await http.post(url,
        body: json.encode({
          'amount': total,
          'dateTime': DateTime.now().toIso8601String(),
          'products': products
              .map((e) => {
                    'id': e.id,
                    'title': e.title,
                    'quantity': e.quantity,
                    'price': e.price,
                  })
              .toList()
        }));

    if (total > 0) {
      orders!.insert(
          0,
          OrderItem(
              id: json.decode(res.body)['name'],
              amount: total,
              dateTime: DateTime.now(),
              products: products));
      notifyListeners();
    }
  }
}
