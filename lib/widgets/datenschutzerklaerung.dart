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
                  child: new Text('MaphGruppe3 gmbH baute die Smart Apotheke App als a CommercialApp Dieser SERVICE wird bereitgestellt von MaphGruppe3 gmbH und ist so zu verwenden, wie es ist. '+
                  'Diese Seite wird verwendet, um Website-Besucher über unsere Richtlinien zur Datasammlung zu informieren, Verwendung und Offenlegung personenbezogener Daten, wenn sich jemand dafür entschieden hat our Bedienung.'+
                  'Wenn Sie sich entscheiden zu verwenden our Service, dann stimmen Sie der Sammlung und Verwendung von Informationen in Bezug auf diese Politik zu. Die persönlichen Informationen, die we collect wird zur Bereitstellung und Verbesserung des Service verwendet.We Ihre Informationen nicht mit anderen Personen verwenden oder teilen, außer wie in dieser Datenschutzrichtlinie beschrieben.'+
                  'Die in dieser Datenschutzerklärung verwendeten Begriffe haben die gleiche Bedeutung wie in unseren Allgemeinen Geschäftsbedingungen, auf die unter http://www.microsoft.com zugegriffen werden kann Smart Apotheke sofern nicht anders in dieser Datenschutzrichtlinie definiert.',style: new TextStyle(
                  fontSize: 16.0, color: Colors.black,fontWeight:FontWeight.bold
                ),),
        
      ),
     )
        ]
        ),
      

    );


  
          
    
    
  }

   
  }
