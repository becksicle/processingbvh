/* 
 Provides parsing and tokenization on an input string.
 */

class Tokenizer {
  // where we are in the content
  int index;
  // the input string we are tokenizing
  String content;
  // whether or not we should ignore casing differences
  boolean caseSensitive;

  Tokenizer(String content, boolean caseSensitive) {
    index = 0;
    this.content = content;
    this.caseSensitive = caseSensitive;
    // move to first non whitespace character
    consumeWhitespace();
  }

  /*
    Moves index to next non whitespace character.
   */
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
    return Character.isWhitespace(c);
  }

  /*
    Advances index past input token in the content.
   If the token isn't the next series of characters in the
   content, will throw an exception.
   */
  void consume(String token) throws Exception {
    if (!peek(token)) throw new Exception("Next token is not: "+token);
    index = index + token.length();
    consumeWhitespace();
  }

  /*
    Returns true if next series of characters in the content matches 
   the input token. 
   */
  boolean peek(String token) {
    if (!caseSensitive) token = token.toLowerCase();
    for (int i=0; i < token.length(); i++) {
      if (content.length() <= index+i) return false;
      char testChar = content.charAt(index+i);
      if (!caseSensitive) testChar = Character.toLowerCase(testChar);
      if (token.charAt(i) != testChar) return false;
    }
    return true;
  }

  boolean eof() {
    return index >= content.length();
  }

  /*
    Returns next series of characters up to the next whitespace.
   */
  String nextToken() {
    if (eof()) return null;
    String token = "";
    char c = content.charAt(index);

    while (!isWhitespace(c) && !eof()) {
      index++;
      token += c;
      c = content.charAt(index);
    }
    consumeWhitespace();
    return token;
  }
}