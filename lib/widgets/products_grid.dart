import 'package:provider/provider.dart';
import 'package:shop_app/widgets/productView.dart';
import 'package:flutter/material.dart';
import '../providers/product_provider.dart';

class GridViewWidget extends StatelessWidget {
  final bool favor;
  const GridViewWidget({required this.favor});
  @override
  Widget build(BuildContext context) {
    final products = Provider.of<Products>(context);
    final productsFiltered = favor == true ? products.favItem : products.item;

    return GridView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: productsFiltered.length,
      itemBuilder: (context, index) => ChangeNotifierProvider.value(
        value: productsFiltered[index],
        child: ProductView(),
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3 / 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
    );
  }
}
