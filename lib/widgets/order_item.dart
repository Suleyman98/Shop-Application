import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import '../providers/orders.dart';

class OrderItems extends StatefulWidget {
  final OrderItem order;

  const OrderItems({super.key, required this.order});

  @override
  State<OrderItems> createState() => _OrderItemsState();
}

class _OrderItemsState extends State<OrderItems> {
  var _isExpanded = false;
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      margin: const EdgeInsets.all(10),
      child: Column(children: [
        ListTile(
          title: Text('\$ ${widget.order.amount.toStringAsFixed(2)}'),
          subtitle: Text(
              DateFormat('dd MM yyyy hh:mm').format(widget.order.dateTime)),
          trailing: IconButton(
            onPressed: () {
              _isExpanded = !_isExpanded;
              setState(() {});
            },
            icon: Icon(
                _isExpanded == true ? Icons.expand_more : Icons.expand_less),
          ),
        ),
        if (_isExpanded == true)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
            height: min(widget.order.products.length * 20 + 10, 180),
            child: ListView(children: [
              ...widget.order.products
                  .map((e) => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            e.title,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text('${e.quantity}x\$${e.price}',
                              style: const TextStyle(
                                  fontSize: 18, color: Colors.grey))
                        ],
                      ))
                  .toList()
            ]),
          )
      ]),
    );
  }
}
