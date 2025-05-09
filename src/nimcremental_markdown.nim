import strformat, strutils, unicode, math
import core/constants, core/codes

type TokenKind* = enum
  tkBOM # Byte order mark
  tkVSpace # Virtual space
  tkEOL # End of line
  tkEOF # End of file
  tkCR # Carriage return
  tkLF # Line feed
  tkCRLF # Carriage return line feed
  tkHT # Horizontal tab
  tkRC # Replacement character
  tkText

# Only the text token has a proper start and length
type Token* = object
  offset*: int
  kind*: TokenKind


type Tokenizer* = object
  column*: int
  offset*: int
  textOffset*: int
  input*: string
  chunks*: seq[Token]

proc newTokenizer*(): Tokenizer =
  Tokenizer(
    column: 1,
    input: "",
    chunks: @[],
    offset: 0,
    textOffset: 0
  )

### Looks for the first occurrence of a null, CR, LF, or HT character.
### Returns the index of the character if found, otherwise -1.
proc search*(input: string, startPosition: int): int =
  let length = input.runeLen
  var i = startPosition
  while i < length:
    let r = input.runeAt(i).ord
    if r == codeNull or r == codeCR or r == codeLF or r == codeHT:
      return i
    i += 1
  if i == length:
    return -1
  else:
    return i

proc pushToken*(tokenizer: var Tokenizer, kind: TokenKind, offset: int) =
  tokenizer.chunks.add(Token(offset: offset, kind: kind))


proc tokenize*(t: var Tokenizer, input: string, finish: bool = false) =
  t.input = t.input & input
  let runesInput = input.toRunes()
  for partialIndex, r in runesInput:
    let i = t.offset + partialIndex

    if i == 0 and r.ord == codeBOM:
      t.pushToken(tkBOM, 0)
      t.textOffset = 1
      continue
    

    case r.ord:
    of codeCR:
      if t.textOffset < i:
        t.pushToken(tkText, t.textOffset)
        t.textOffset = i + 1

      t.pushToken(tkCR, i)
      continue
    of codeLF:
      if t.textOffset < i:
        t.pushToken(tkText, t.textOffset)
        t.textOffset = i + 1

      if i > 0 and t.chunks[t.chunks.len - 1].kind == tkCR:
        t.chunks[t.chunks.len - 1].kind = tkCRLF
      else:
        t.pushToken(tkLF, i)
      continue
    of codeHT:
      if t.textOffset < i:
        t.pushToken(tkText, t.textOffset)
        t.textOffset = i + 1
      let next = int(ceil(t.column / tabSize)) * tabSize
      t.pushToken(tkHT, i)
      t.column += 1
      while t.column < next:
        t.pushToken(tkVSpace, i)
        t.column += 1
      continue
    else:
      discard

  t.offset += runesInput.len

  if finish:
    echo t.textOffset, " ", t.offset
    if t.textOffset < t.offset:
      t.pushToken(tkText, t.textOffset)
  t.pushToken(tkEOF, t.offset)

when isMainModule:
  var tokenizer = newTokenizer()
  tokenize(tokenizer, "\uFEFFHello\nworld", true)
  echo tokenizer.chunks
