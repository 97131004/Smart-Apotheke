import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' show parse;

class ShopListItem {
  String name;
  String description;
  String link;
  String image;
  String price;
  String crossedOutPrice;
  String pricePerUnit;
  //String shippingLink;

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();

    map["name"] = name;
    map["desc"] = description;
    map["link"] = link;
    map["img"] = image;
    map["price"] = price;
    map["coproice"] = crossedOutPrice;
    map["pricepu"] = pricePerUnit;

    return map;
  }
}

class ShopListParser {
  static List<ShopListItem> parseHtmlToShopListItem(String html) {
    List<ShopListItem> resultList = new List<ShopListItem>();
    var htmlDom = parse(html);
    var listElement = htmlDom.getElementById("product-list");//getElementsByTagName("div");

    for(var element in listElement.children) {
      if(element.className == "product-list-entry") {
        ShopListItem item = new ShopListItem();
        var formElement = element.getElementsByTagName("form").first;
        // prices
        var prices = formElement.getElementsByClassName("transaction").first
            .getElementsByClassName("prices").first;
        for(var priceElement in prices.children) {
          if(priceElement.className == "normal-price") item.price = priceElement.text;
          if(priceElement.className == "sp2p normal-price-crossedout") item.crossedOutPrice = priceElement.text;
          if(priceElement.className == "base-price") item.pricePerUnit = priceElement.text;
          /*if(priceElement.className == "small") {
            if(priceElement.firstChild.attributes.containsKey("href")) {
              item.shippingLink = priceElement.firstChild.attributes["href"];
            }
          }*/
        }
        // image
        var image = formElement.getElementsByClassName("clearfix").first
            .getElementsByClassName("image").first
            .getElementsByTagName("a").first;
        if(image != null) {
          if(image.attributes.containsKey("href")) {
            item.link = image.attributes["href"];
          }
          if(image.attributes.containsKey("title")) {
            item.name = image.attributes["title"];
          }
          if(image.firstChild.attributes.containsKey("src")) {
            item.image = image.firstChild.attributes["src"];
          }
        }
        var description = formElement.getElementsByClassName("clearfix").first
            .getElementsByClassName("description").first;
        if(description != null) {
          var desc = description.text;
          if(desc.endsWith(")")) {
            desc.replaceFirst(new RegExp("([0-9]*)"), "");
          }
          item.description = desc;
        }
        resultList.add(item);
      }
    }

    return resultList;
  }
}