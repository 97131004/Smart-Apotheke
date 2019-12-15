import 'package:flutter/material.dart';
import 'package:carousel_pro/carousel_pro.dart';
import 'package:flutter/rendering.dart';
class Userguide extends StatefulWidget {
  

  @override
  State<StatefulWidget> createState() {
    return _UserguideState();
  }
}

class _UserguideState extends State<Userguide> {

  
   _UserguideState();
  @override
  Widget build(BuildContext context) {
    
    Widget imageCarousel=Container(
      alignment: Alignment.center,
      height: 500,
      
      child: Carousel(
       
        boxFit:  BoxFit.contain,
        images: [
          AssetImage('assets/start.PNG'),
           AssetImage('assets/scann.PNG'),
            AssetImage('assets/us.PNG'),
          AssetImage('assets/userguide2.PNG'),
           AssetImage('assets/userguide3.PNG'),
            AssetImage('assets/userguide4.PNG'),
        ],
        autoplay: true,
        indicatorBgPadding: 1.0,
         onImageTap: (imageIndex) {
                            
         }

       // autoplayDuration: Duration(milliseconds:2000),
        //animationCurve: Curves.fastOutSlowIn,
      ),
      

    );
    return  Scaffold(
      appBar: AppBar(
        title: Text('Userguide'),
        backgroundColor: Colors.green,),
     body: ListView(
       
      children: <Widget>[
       
      imageCarousel,
       
        
     
      ]
     ),
   );
          
    
  }
}