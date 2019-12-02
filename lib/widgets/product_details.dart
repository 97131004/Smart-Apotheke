import 'package:flutter/material.dart';
import 'package:maph_group3/util/shop_items.dart';

class ProductDetails extends StatefulWidget {
  final String url;

  ProductDetails({Key key, @required this.url}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ProductDetailsState();
  }
}

class _ProductDetailsState extends State<ProductDetails> {

  ShopItem itemToDisplay;

  @override
  void initState() {
    super.initState();

    loadMedProductDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Produktinfo"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            buildImageContainer(),
            buildScrollView(),
            buildOrderCompleteContainer(),
          ],
        ),
      ),
    );
  }

  Widget buildImageContainer() {
    return Center(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.4,
        width: MediaQuery.of(context).size.width,
        decoration: new BoxDecoration (
          borderRadius: new BorderRadius.horizontal(),
          border: Border.all(color: Colors.black54),
        ),
        padding: EdgeInsets.all(15),
        child: Image.asset(itemToDisplay.image),
      ),
    );
  }

  Widget buildScrollView() {
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(10),
          child: Text(itemToDisplay.name, style: TextStyle(fontSize: 30),),
        ),
        Container(
          child: Column(
            children: <Widget>[
              Text("Beschreibung", textAlign: TextAlign.right, style: TextStyle(fontSize: 15),),
              Text(itemToDisplay.desc),
              Text("STDHEHKDKE"),
            ],
          ),
        )
      ],
    );
  }

  Widget buildOrderCompleteContainer() {
    return Row(
      children: <Widget>[
        Padding(padding: EdgeInsets.all(20),),
        new Flexible(
          child: Container(
            padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
            child: TextField(
              decoration: new InputDecoration(
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black54)
                  ),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.green, width: 2)
                  )
              ),
            ),
          ),
        ),
        Padding(padding: EdgeInsets.all(10),),
        new Flexible(
          child: RaisedButton(
            onPressed: null,
            child: Text("Jetzt kaufen", style: TextStyle(color: Colors.green),),
          ),
        ),
        Padding(padding: EdgeInsets.all(20),),
      ],
    );
  }

  Future loadMedProductDetails() async {
    itemToDisplay = new ShopItem.empty();
    itemToDisplay.name = 'Ibuprofen ratiopharm 400mg';
    itemToDisplay.pzn = '';
    itemToDisplay.image = 'assets/dummy_med.png';
    itemToDisplay.desc = 'Bei leichten bis mäßig starken Schmerzen wie Kopf-, Zahn-, Regelschmerzen und Fieber\n Ibuprofen, der Wirkstoff von IBU ratiopharm 400 mg akut, ist ein bewährtes Mittel bei leichten bis mäßigen Kopfschmerzen, Fieber und anderen Alltagsschmerzen. Mit 400 mg des Wirkstoffes enthalten die Tabletten die höchste rezeptfreie Dosierung von Ibuprofen. Die Tabletten sollten immer mit einem Glas Wasser eingenommen werden. \n'
        'Hilft gut verträglich gegen Schmerzen: Ibu-ratiopharm 400mg akut Die Ibu-ratiopharm 400mg akut-Tabletten wirken gegen Schmerzen und Fieber. Jeder kennt es und jeder wird zweifellos im Laufe seines Lebens mehrmals daran leiden: Ein Pochen im Kopf, ein Schlappheitsgefühl und Gliederschmerzen. Schmerzen und Fieber sind häufige Leiden, die in jedem Alter auftreten können. Kopfschmerzen und Erkältungsschmerzen können jeden aus der Bahn werfen und den Alltag mitunter negativ beeinflussen. '
        'Auch Fieber ist nicht selten Begleiterscheinung von Erkältungen oder anderen Erkrankungen. Schmerz- und fiebersenkende Mittel wie die Ibu-ratiopharm 400mg akut Tabletten können akute Beschwerden lindern und so den Alltag erleichtern. Auch bei plötzlich auftretenden Kopfschmerzen auf Reisen oder im Büro eignen sich die Tabletten aufgrund ihrer Wirkung und der guten Verträglichkeit.\nIbuprofen gehört zu den Klassikern unter den Schmerzmitteln.'
        'Das liegt vor allem an der guten Verträglichkeit, die das Medikament auszeichnet. Der Wirkstoff zählt außerdem zu den sogenannten „sauren“ Schmerzmitteln. Dank dieser Eigenschaft wirkt Ibuprofen nicht nur schmerz- sondern zudem auch entzündungshemmend. Aus diesem Grund wird Ibuprofen auch häufig bei rheumatischen Beschwerden und bei entzündungsbedingten Schmerzen angewandt, um einerseits die akuten Schmerzen zu lindern und andererseits die Entzündung '
        'als Ursache für die Schmerzen zu hemmen. \n\nEntzündungshemmende und schmerzstillende Wirkung \n Der Wirkstoff Ibuprofen bewirkt, dass die Bildung der sogenannten Prostaglandine, die sich entzündungsfördernd, schmerzauslösend und fiebersteigernd auf den Körper auswirken, vermindert wird. Eingesetzt wird der Wirkstoff vorwiegend zur Senkung akuter Schmerzen, bei rheumatischen Gelenkbeschwerden und zur Linderung von Entzündungen und Schwellungen. '
        'Auch im Rahmen von Sportverletzungen können die Ibu-ratiopharm 400mg akut-Tabletten helfen, die damit einhergehenden Schmerzen zu mindern und die entzündeten Muskeln und Gelenke zu beruhigen. Die Schmerztabletten helfen überdies auch, Zahn- oder Regelschmerzen wieder in den Griff zu bekommen und zeichnen sich durch eine entzündungslindernde Wirkung und eine gute Verträglichkeit aus.';
  }
}
