import 'package:flutter/material.dart';
import '../util/med_list.dart';
import '../data/globals.dart' as globals;


class DummyMedList extends StatefulWidget {
  

  @override
  State<StatefulWidget> createState() {
    return _DummyMedListState();
  }
}

class _DummyMedListState extends State<DummyMedList> {

  
   _DummyMedListState();
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: Text('Medikamente Liste'),
        backgroundColor: Colors.green,),
     body: Stack(
       fit: StackFit.expand,
      children: <Widget>[
  
      
       
          MedList.build(context, globals.meds)
        
     
      ]
     ),
   );
          
    
    
  }

   
  }
