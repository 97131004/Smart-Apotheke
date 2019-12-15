import 'package:flutter/material.dart';
import '../util/med_list.dart';
import '../data/globals.dart' as globals;
import 'package:maph_group3/data/med.dart';
import '../util/nampr.dart';
import 'scanner.dart';

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
    
  
      
       
         
        body: (globals.meds.length > 0)
          ? MedList.build(
              context,
              globals.meds,
              true,
              medItemOnLongPress,
              medItemOnSwipe,
            )
          : Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Keine Medikamente vorhanden. ' +
                      'Scannen Sie ein Rezept über den Knopf unten rechts.',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        foregroundColor: Colors.white,
        child: Icon(Icons.camera_alt),
        onPressed: () {
          Navigator.push(
            context,
            NoAnimationMaterialPageRoute(builder: (context) => Scanner()),
          );
        },
      ),
    );
  }

  void medItemOnLongPress(Med med, Offset tapPosition) {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject();
    showMenu(
      items: <PopupMenuEntry>[
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: <Widget>[
              Icon(Icons.delete),
              Text("Delete"),
            ],
          ),
        )
      ],
      context: context,
      position: RelativeRect.fromRect(
          tapPosition & Size.zero, Offset.zero & overlay.size),
    ).then((value) {
      if (value == 'delete') {
        medItemDelete(med);
      }
    });
  }

  void medItemOnSwipe(Med med) {
    medItemDelete(med);
  }

  void medItemDelete(Med med) {
    setState(() {
      globals.meds.remove(med);
    });
  }
}
     
    
   
  
