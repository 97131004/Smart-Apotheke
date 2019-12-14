import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:grouped_buttons/grouped_buttons.dart';
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

  bool agbIsChecked = false;
  bool offersIsChecked = false;

  @override
  initState() {
    super.initState();
    _checkData();
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
            _buildProductOverview(),
            _buildPaymentOptions(),
            _buildShippingOptions(),
            _buildConfirmationContainer(),
          ],
        ),
      ),
    );
  }

  Widget _buildProductOverview() {
    return new Container(
      child: Card(

      ),
    );
  }

  Widget _buildPaymentOptions() {
    return new Container();
  }

  Widget _buildShippingOptions() {
    return new Container(
      child: Column(
        children: <Widget>[
          Text('Liefermöglichkeiten:'),
          RadioButtonGroup(
              labels: <String>[
                'Nach Hause liefern lassen',
                'An Apotheke liefern lassen',
              ],
              onSelected: (String selected) => print(selected)
          )
        ],
      ),
    );
  }

  Widget _buildBillingAdress() {
    return new Container();
  }

  Widget _buildGooglemapsContainer() {
    return new Container();
  }

  Widget _buildConfirmationContainer() {
    return new Container(
      child: Column(
        children: <Widget>[
          Text("Confirmation"),
          CheckboxGroup(
            labels: <String>[
              'AGBs zustimmen',
              'Ich bin damit einverstanden, dass...',
            ],
            onSelected: (List<String> checked) => print(checked.toString())
          ),
        ],
      ),
    );
  }

  _checkData() {
    if(!PersonalData.isUserDataComplete()) {
      SchedulerBinding.instance.addPostFrameCallback((_) async {
        await _dataIncompleteAlert(context);
        Navigator.push(
          context,
          NoAnimationMaterialPageRoute(
              builder: (context) => Personal()),
        );
      });
    } else {
      String name = widget.item.name;
      print("data is ok. display data to verify || name: " + name);
    }
  }

  Future<void> _dataIncompleteAlert(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Daten unvollständig'),
          content: const Text('Ihre persönlichen Daten sind nicht vollständig. Bitte überprüfen und ergänzen.'),
          actions: <Widget>[
            FlatButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
