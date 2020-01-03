import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:maph_group3/util/nampr.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:convert';

import 'home.dart';


class Datenschutz extends StatefulWidget {
 



  @override
  State<StatefulWidget> createState() {
    return _DatenschutzState();
  }

  
}

class _DatenschutzState extends State<Datenschutz> {

WebViewController _webViewController;
String filepath='assets/files/privacy_policy.html';


   

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
     
        body: new WebView(
          initialUrl: '',
          javascriptMode: JavascriptMode.unrestricted,
          onWebViewCreated: (WebViewController webViewController) {
             _webViewController = webViewController;
              _loadHtmlFromAssets();

          },

        ),

       floatingActionButton: Container(
        
           child: RaisedButton(
            elevation: 50,
            color: Colors.green,
            shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(10.0)),
            onPressed: (){
              
                        
                            Navigator.push(
                              context,
                              NoAnimationMaterialPageRoute(builder: (context) =>Home()),
                            );
                           
              },
               child: Text('Ich stimme die Datenschutzerklärung zu'),
           )
           
       
         
       ),
         
    );
  
  }
        

 _loadHtmlFromAssets() async{
   String fileHtmlContents =await rootBundle.loadString(filepath);
   _webViewController.loadUrl(Uri.dataFromString(fileHtmlContents,
      mimeType: 'text/html', encoding: Encoding.getByName('utf-8'))
   .toString());
 }
   
  }
