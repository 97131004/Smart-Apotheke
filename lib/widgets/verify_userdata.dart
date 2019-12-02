import 'package:flutter/material.dart';

class VerificationUserData extends StatefulWidget {
  final String url;

  VerificationUserData({Key key, @required this.url}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _VerificationUserDataState();
  }
}

class _VerificationUserDataState extends State<VerificationUserData> {

  @override
  void initState() {
    super.initState();
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
