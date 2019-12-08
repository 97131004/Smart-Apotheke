import 'package:flutter/material.dart';
import 'package:maph_group3/util/nampr.dart';
import 'package:maph_group3/util/personaldata.dart';
import 'package:maph_group3/util/shop_items.dart';
import 'package:maph_group3/widgets/personal.dart';

class VerificationUserData extends StatefulWidget {
  final ShopItem item;

  VerificationUserData({Key key, @required this.item}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _VerificationUserDataState();
  }
}

class _VerificationUserDataState extends State<VerificationUserData> {

  @override
  void initState() {
    super.initState();
    /*if(!PersonalData.isUserDataComplete()) {
      Navigator.push(context, NoAnimationMaterialPageRoute(builder: (context) => Personal()));
    } else {
      String name = widget.item.name;
      print("data is ok. display data to verify || name: " + name);
    }*/
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Verify User Data"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
          ],
        ),
      ),
    );
  }
}
