import 'package:flutter/material.dart';



class Datenschutz extends StatefulWidget {
  

  @override
  State<StatefulWidget> createState() {
    return _DatenschutzState();
  }
}

class _DatenschutzState extends State<Datenschutz> {

  
   _DatenschutzState();
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: Text('Datenschutzerklärung'),
        backgroundColor: Colors.green,),
        body: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
 
        new Expanded(
                flex: 1,
                child: new SingleChildScrollView(
                  padding: EdgeInsets.all(8.0),
                  child: new Text('Die HTW Berlin AI Master Group2019 hat die SmartApotheke App als kostenlose App erstellt. Dieser SERVICE wird von der HTW Berlin AI Master Group 2019 kostenlos zur Verfügung gestellt und ist für den bestimmungsgemäßen Gebrauch bestimmt'+
                  'Diese Seite wird verwendet, um Website-Besucher über unsere Richtlinien zur Datasammlung zu informieren, Verwendung und Offenlegung personenbezogener Daten, wenn sich jemand dafür entschieden hat our Bedienung.'+
                  'Wenn Sie sich entscheiden zu verwenden our Service, dann stimmen Sie der Sammlung und Verwendung von Informationen in Bezug auf diese Politik zu.  Die von uns erfassten personenbezogenen Daten werden zur Bereitstellung und Verbesserung des Dienstes verwendet. Wir werden Ihre Daten nur wie in dieser Datenschutzerklärung beschrieben verwenden oder an Dritte weitergeben.'+
                  'Die in dieser Datenschutzerklärung verwendeten Begriffe haben die gleiche Bedeutung wie in unseren Allgemeinen Geschäftsbedingungen, die bei SmartApotheke zugänglich sind, sofern in dieser Datenschutzerklärung nichts anderes festgelegt ist.',style: new TextStyle(
                  fontSize: 16.0, color: Colors.black,fontWeight:FontWeight.bold
                ),),
        
      ),
     )
        ]
        ),
      

    );


  
          
    
    
  }

   
  }
