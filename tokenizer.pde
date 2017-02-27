class Tokenizer {
  int index;
  String content;

  Tokenizer(String content) {
    index = 0;
    this.content = content;
    consumeWhitespace();
  }

  void consumeWhitespace() {
    if (eof()) return;

    char c = content.charAt(index);
    while (isWhitespace(c)) {
      index++;
      if (eof()) return;
      c = content.charAt(index);
    }
  }

  boolean isWhitespace(char c) {
    return c == ' ' || c == '\t' || c == '\n' || c == '\r';
  }

  void consume(String token) throws Exception {
    if (!peek(token)) throw new Exception("Next token is not: "+token);
    index = index + token.length();
    consumeWhitespace();
    //print("Consumed "+token);
  }

  boolean peek(String token) {
    for (int i=0; i < token.length(); i++) {
      if (content.length() <= index+i) return false; 
      if (token.charAt(i) != content.charAt(index+i)) return false;
    }
    //print("peeked "+token);
    return true;
  }

  boolean eof() {
    return index >= content.length();
  }

  String nextToken() {
    if (eof()) return null;
    String token = "";
    char c = content.charAt(index);

    while (!isWhitespace(c) && !eof()) {
      index++;
      token += c;
      c = content.charAt(index);
    }
    //print("next token: "+token);
    consumeWhitespace();
    return token;
  }
}