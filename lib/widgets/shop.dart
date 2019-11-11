import 'package:flutter/material.dart';

import '../data/med.dart';

class Shop extends StatefulWidget {
  final Med med;

  Shop({Key key, @required this.med}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ShopState();
  }
}

class _ShopState extends State<Shop> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bestellen'),
      ),
      body: Text('${widget.med.name} (PZN: ${widget.med.pzn})' +
          '\n\nHier Preise für lokale/online-Apotheken auflisten und irgendwie visuell trennen?'),
    );
  }
}
