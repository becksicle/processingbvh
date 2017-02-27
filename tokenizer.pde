class Tokenizer {
  int index;
  String content;
  boolean caseSensitive;

  Tokenizer(String content, boolean caseSensitive) {
    index = 0;
    this.content = content;
    this.caseSensitive = caseSensitive;
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
    if(!caseSensitive) token = token.toLowerCase();
    for (int i=0; i < token.length(); i++) {
      if (content.length() <= index+i) return false;
      char testChar = content.charAt(index+i);
      if(!caseSensitive) testChar = Character.toLowerCase(testChar);
      if (token.charAt(i) != testChar) return false;
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