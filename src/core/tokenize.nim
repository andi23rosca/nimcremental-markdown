type TokenKind* = enum
  TkLineFeed
  TkCarriageReturn
  TkCarriageReturnLineFeed
  TkSpace
  TkTab
  TkAsterisk
  TkUnderscore
  TkTilde
  TkBacktick
  TkBackslash
  TkExclamationMark
  TkPipe
  TkMinus
  TkPlus
  TkColon
  TkGreaterThan
  TkForwardSlash
  TkDoubleQuote
  TkLessThan
  TkBracketOpen
  TkBracketClose
  TkBraceOpen
  TkBraceClose
  TkParenOpen
  TkParenClose
  TkComma
  TkDot
  TkSemicolon
  TkSlash
  TkEqual
  TkHash
  TkDigit
  TkText

type Token* = object
  start: int
  kind: TokenKind
  finish: int

proc newToken*(start: int, kind: TokenKind): Token =
  Token(start: start, kind: kind)


# proc tokenize*(input: string): seq[Token] =