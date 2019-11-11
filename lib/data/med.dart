class Med {
  String name = '';
  String pzn = '00000000';
  String url = '';

  Med(String name, String pzn, [String url]) {
    this.name = name;
    while (pzn.length < 8) {
      pzn = '0' + pzn;
    }
    this.pzn = pzn;
    if (url != null && url.length > 0) {
      this.url = url;
    }
  }
}
