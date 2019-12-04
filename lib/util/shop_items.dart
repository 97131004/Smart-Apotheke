import 'package:html/parser.dart' show parse;

class ShopItem {
  String name;
  String pzn;
  String brand;
  String dosage;
  String link;
  String image;
  String price;
  int priceInt;
  String crossedOutPrice;
  String pricePerUnit;
  String merchant;
  String desc = "";

  ShopItem.empty();

  ShopItem(String name, String pzn, String brand, [String dosage, String link,
    String image, String price, String crossedOutPrice, String pricePerUnit, String merchant, String desc]) {
    this.name = name;
    this.pzn = pzn;
    this.brand = brand;
    this.dosage = dosage;
    this.link = link;
    this.image = image;
    this.setPrice(price);
    this.crossedOutPrice = crossedOutPrice;
    this.pricePerUnit = pricePerUnit;
    this.merchant = merchant;
    this.desc = desc;
  }

  void setPrice(String price) {
    this.price = price;
    this.priceInt = ((double.tryParse(price.substring(0, price.length-2).replaceAll(',', '.')) ?? 0.0)*100).toInt();
  }

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();

    map["name"] = name;
    map["pzn"] = pzn;
    map["brand"] = brand;
    map["dosage"] = dosage;
    map["link"] = link;
    map["img"] = image;
    map["price"] = price;
    map["coproice"] = crossedOutPrice;
    map["pricepu"] = pricePerUnit;
    map["merchant"] = merchant;
    map["desc"] = desc;

    return map;
  }

  int compareTo(ShopItem item) {
    if(this.priceInt == item.priceInt) return 0;
    if(this.priceInt > item.priceInt) return 1;
    else return -1;
  }
}

class ShopListParser {
  static List<ShopItem> parseHtmlToShopListItemMedpex(String html) {
    List<ShopItem> resultList = new List<ShopItem>();
    var htmlDom = parse(html);
    var listElement = htmlDom.getElementById("product-list");//getElementsByTagName("div");

    for(var element in listElement.children) {
      if(element.className == "product-list-entry") {
        ShopItem item = new ShopItem.empty();
        var formElement = element.getElementsByTagName("form").first;
        // prices
        var prices = formElement.getElementsByClassName("transaction").first
            .getElementsByClassName("prices").first;
        for(var priceElement in prices.children) {
          if(priceElement.className == "normal-price") item.setPrice(priceElement.text);
          if(priceElement.className == "sp2p normal-price-crossedout") item.crossedOutPrice = priceElement.text;
          if(priceElement.className == "base-price") item.pricePerUnit = priceElement.text;
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
          var desc = description.text.split("\n");
          item.pzn = desc[4];
          item.brand = desc[3];
          item.dosage = desc[2];
        }
        item.merchant= "Medpex";
        resultList.add(item);
      }
    }

    return resultList;
  }

  static List<ShopItem> parseHtmlToShopListItemDocMorris(String html) {
    List<ShopItem> resultList = new List<ShopItem>();
    var htmlDom = parse(html);
    var listElement = htmlDom.getElementsByClassName("search__results").first;

    for(var element in listElement.children) {
      if(element.className.contains("list-item")) {
        ShopItem item = new ShopItem.empty();
        var elementData = element.children.first.children.first;
        if(elementData.attributes.containsKey("data-pzn")) {
          item.pzn = elementData.attributes["data-pzn"];
        }
        for(var productDetails in elementData.children) {
          if(productDetails.className.contains("product-image")) {
            var imageElement = productDetails.children.first;
            if(imageElement.attributes.containsKey("href")) {
              item.link = productDetails.children.first.attributes["href"];
            }
            if(imageElement.children.first.attributes.containsKey("data-src")) {
              item.image = "https://www.docmorris.de/" + imageElement.children.first.attributes["data-src"];
            }
          }
          if(productDetails.className.contains("product-description")) {
            item.name = productDetails.getElementsByTagName("h2").first.getElementsByTagName("a").first.children.first.text;
            item.dosage = productDetails.getElementsByTagName("p")[0].text;
            item.brand = productDetails.getElementsByTagName("p")[3].text;
          }
          if(productDetails.className.contains("add-to-cart-form")) {
            var priceBox = productDetails.children[1].children[3];
            for(var price in priceBox.children) {
              if(price.className == "uvp") {
                item.crossedOutPrice = price.children.first.text;
              }
              if(price.className == "price") {
                item.setPrice(price.children.first.text);
              }
              if(price.className == "additional-info basePrice") {
                item.pricePerUnit = price.text.split("\n")[1].replaceAll(" ", "");
              }
            }
          }
        }
        item.merchant = "DocMorris";
        resultList.add(item);
      }
    }
    return resultList;
  }
}