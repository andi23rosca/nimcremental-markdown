import strformat, strutils, unicode, math
import constants, codes

# Only the text token has a proper start and length
type Chunk* = object
  offset*: int
  kind*: Rune


type Preprocessor* = object
  column*: int
  offset*: int
  textOffset*: int
  input*: string
  chunks*: seq[Chunk]

proc newPreprocessor*(): Preprocessor =
  Preprocessor(
    column: 1,
    input: "",
    chunks: @[],
    offset: 0,
    textOffset: 0
  )

template print(s: varargs[string, `$`]) =
  for x in s:
    stdout.write x

proc printChunks*(preprocessor: Preprocessor) =
  var kind = ""
  for chunk in preprocessor.chunks:
    case chunk.kind:
    of codeCarriageReturn:
      kind = "CR"
    of codeLineFeed:
      kind = "LF"
    of codeHorizontalTab:
      kind = "HT"
    of codeVirtualSpace:
      kind = "VSpace"
    of codeEOF:
      kind = "EOF"
    of codeTextChunk:
      kind = "Text"
    else:
      kind = $chunk.kind
    print chunk.offset, ":", kind, " "
  print "\n"

proc pushChunk*(preprocessor: var Preprocessor, kind: Rune, offset: int) =
  preprocessor.chunks.add(Chunk(offset: offset, kind: kind))


proc preprocess*(p: var Preprocessor, input: string, finish: bool = false) =
  p.input = p.input & input
  let runesInput = input.toRunes()
  for partialIndex, r in runesInput:
    let i = p.offset + partialIndex

    if i == 0 and r == codeBOM:
      p.textOffset = 1
      continue

    case r:
    of codeCR:
      if p.textOffset < i:
        p.pushChunk(codeTextChunk, p.textOffset)
      p.textOffset = i + 1
      p.pushChunk(codeCarriageReturn, i)
      continue
    of codeLF:
      if p.textOffset < i:
        p.pushChunk(codeTextChunk, p.textOffset)
      p.textOffset = i + 1
      if i > 0 and p.chunks[p.chunks.len - 1].kind == codeCarriageReturn:
        p.chunks[p.chunks.len - 1].kind = codeCarriageReturnLineFeed
      else:
        p.pushChunk(codeLineFeed, i)
      continue
    of codeHT:
      if p.textOffset < i:
        p.pushChunk(codeTextChunk, p.textOffset)
      p.textOffset = i + 1
      let next = int(ceil(p.column / tabSize)) * tabSize
      p.pushChunk(codeHorizontalTab, i)
      while p.column < next:
        p.pushChunk(codeVirtualSpace, i)
        p.column += 1
      continue
    else:
      discard

  p.offset += runesInput.len

  if p.textOffset < p.offset:
    p.pushChunk(codeTextChunk, p.textOffset)
  if finish:
    p.pushChunk(codeEOF, p.offset)
