import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'product.dart';
import 'dart:convert';

class Products with ChangeNotifier {
  List<Product> items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];
  var showFavorites = false;
  final String? token;
  final String? userId;

  Products({this.userId, this.token, required this.items});
  List<Product> get item {
    return [...items];
  }

  List<Product> get favItem {
    return items.where((element) => element.isFavorite).toList();
  }

  Future<void> fetchProducts([bool filterByUser = false]) async {
    final filterString =
        filterByUser ? 'orderBy="userId"&equalTo="$userId"' : '';
    var url = Uri.parse(
        'https://shopapp-f3252-default-rtdb.firebaseio.com/products.json?auth=$token&$filterString');

    try {
      final res = await http.get(url);

      final data = json.decode(res.body) as Map<String, dynamic>;
      final List<Product> loadedProducts = [];
      url = Uri.parse(
          'https://shopapp-f3252-default-rtdb.firebaseio.com/userFav/$userId.json?auth=$token');
      final userFavorite = await http.get(url);
      final favData = json.decode(userFavorite.body);
      print('Fav Data: $favData');

      data.forEach((id, dataFetched) {
        loadedProducts.add(Product(
            title: dataFetched['title'],
            description: dataFetched['description'],
            price: dataFetched['price'],
            imageUrl: dataFetched['imageUrl'],
            isFavorite: favData == null ? false : favData[id] ?? false,
            id: id.toString()));
      });
      items = loadedProducts;
      notifyListeners();
    } catch (error) {
      print(error);
      rethrow;
    }
  }

  Future<void> addProduct(Product product) async {
    final url = Uri.parse(
        'https://shopapp-f3252-default-rtdb.firebaseio.com/products.json?auth=$token');
    try {
      final res = await http.post(url,
          body: json.encode({
            'title': product.title,
            'description': product.description,
            'price': product.price,
            'imageUrl': product.imageUrl,
            'userId': userId,
          }));
      items.add(Product(
          id: json.decode(res.body)['name'],
          title: product.title,
          description: product.description,
          price: product.price,
          imageUrl: product.imageUrl));
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  editProduct(String id, Product product) {
    final index = items.indexWhere((element) => element.id == id);
    if (index >= 0) {
      items[index] = product;
      notifyListeners();
    }
  }

  deleteProduct(String id) {
    final url = Uri.parse(
        'https://shopapp-f3252-default-rtdb.firebaseio.com/products/$id.json?auth=$token');
    final existingIndex = items.indexWhere((element) => element.id == id);
    var existingItem = items[existingIndex];
    items.removeAt(existingIndex);
    notifyListeners();
    http.delete(url).then((value) {
      if (value.statusCode >= 400) {
        throw Exception(value.statusCode);
      }
      existingItem =
          Product(id: '', title: '', description: '', price: 0, imageUrl: '');
    }).catchError((error) {
      items.insert(existingIndex, existingItem);
      notifyListeners();
    });
  }

  Product findById(String id) {
    return items.firstWhere((element) => element.id == id);
  }
}
