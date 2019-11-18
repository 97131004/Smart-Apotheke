class Helper {
  static String parseMid(String source, String delim1, String delim2,
      [int startIndex]) {
    int iDelim1 = source.indexOf(delim1, (startIndex != null) ? startIndex : 0);
    int iDelim2 = source.indexOf(delim2, iDelim1 + delim1.length);
    if (iDelim1 != -1 && iDelim2 != -1) {
      return source.substring(iDelim1 + delim1.length, iDelim2);
    }
    return '';
  }

  static bool isNumber(String pzn) {
    //dont use isNumeric(), it accepts - and + signs
    for (int i = 0; i < pzn.length; i++) {
      if (!(pzn[i].codeUnitAt(0) >= 48 && pzn[i].codeUnitAt(0) <= 57)) {
        return false;
      }
    }
    return true;
  }
}
