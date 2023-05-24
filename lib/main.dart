import 'package:flutter/material.dart';
import 'package:shop_app/providers/auth.dart';
import 'package:shop_app/providers/cart.dart';
import 'package:shop_app/providers/orders.dart';
import 'package:shop_app/providers/product_provider.dart';
import 'package:shop_app/screens/auth_screen.dart';
import 'package:shop_app/screens/cart_screen.dart';
import 'package:shop_app/screens/edit_product_screen.dart';
import 'package:shop_app/screens/orders_screen.dart';
import 'package:shop_app/screens/product_detail_screen.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/screens/product_overview_screen.dart';
import 'package:shop_app/screens/users_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (BuildContext context) {
            return Auth();
          }),
          ChangeNotifierProxyProvider<Auth, Products>(
            update: (ctx, auth, previousProducts) => Products(
                token: auth.token,
                userId: auth.userId,
                items: previousProducts == null ? [] : previousProducts.items),
            create: (ctx) => Products(items: []),
          ),
          ChangeNotifierProvider(create: (BuildContext context) {
            return Cart();
          }),
          ChangeNotifierProxyProvider<Auth, Orders>(
            update: (ctx, auth, previousProducts) => Orders(
                authToken: auth.token,
                userId: auth.userId,
                orders:
                    previousProducts == null ? [] : previousProducts.orders),
            create: (ctx) => Orders(),
          )
        ],
        child: Consumer<Auth>(
          builder: (ctx, auth, _) => MaterialApp(
            home: auth.isAuth
                ? ProductOverviewScreen()
                : FutureBuilder(
                    builder: (ctx, result) =>
                        result.connectionState == ConnectionState.waiting
                            ? ProductOverviewScreen()
                            : AuthScreen(),
                    future: auth.autologin()),
            routes: {
              CartScreen.routeName: (context) => const CartScreen(),
              ProductDetail.route: (context) => ProductDetail(),
              OrdersScreen.routeName: (context) => const OrdersScreen(),
              UserProducts.routeName: (context) => const UserProducts(),
              EditProductScreen.routeName: (context) =>
                  const EditProductScreen()
            },
            theme: ThemeData(
                primarySwatch: Colors.deepOrange,
                primaryColor: Colors.deepOrange,
                appBarTheme: const AppBarTheme(backgroundColor: Colors.purple)),
          ),
        ));
  }
}
