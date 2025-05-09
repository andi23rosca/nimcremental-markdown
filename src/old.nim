# This is just an example to get you started. A typical hybrid package
# uses this file as the main entry point of the application.
import strutils
import nimcremental_markdown/submodule


type BlockKind* = enum
  bkParagraph
  bkHeading1
  bkUnorderedList
  bkOrderedList
  bkListItem
  bkIndentedCodeBlock
  bkFencedCodeBlock
  bkBlockQuote

type Block* = ref object
  kind*: BlockKind
  children*: seq[Block]
  lineStart*: int
  lineEnd*: int
  offset*: int
  length*: int
  open*: bool
  leaf*: bool

type Document* = ref object
  children*: seq[Block]

type Parser* = ref object
  input*: string
  pos*: int
  line*: int
  doc*: Document
  lastBlock*: Block


proc newParser*(): Parser =
  var doc = Document(children: @[])
  Parser(input: "", pos: 0, line: 0, doc: doc)

proc parseBlockContinuation*(parser: var Parser) =
  echo "parseBlockContinuation"

proc parseBlockStart*(parser: var Parser) =
  echo "parseBlockStart"

proc debugString*(str: string): string =
  str.replace("\n", "\\n").replace("\r", "\\r").replace("\r\n", "\\r\\n")

proc isNewlineToken*(parser: var Parser, i: int): int =
  if parser.input[i] == '\n':
    return 1
  if parser.input[i] == '\r':
    if i + 1 < parser.input.len and parser.input[i + 1] == '\n':
      return 2
    return 1
  return 0

type LineResult = object
  start: int
  finish: int
  newline: bool
proc newLineResult*(start: int, finish: int, newline: bool): LineResult =
  LineResult(start: start, finish: finish, newline: newline)

proc getLines*(parser: var Parser): seq[LineResult] =
  var i = parser.pos
  while i < parser.input.len:
    var newline = isNewlineToken(parser, i)
    if newline > 0:
      if i != parser.pos:
        result.add(newLineResult(parser.pos, i - 1, false))
        # echo parser.input[parser.pos..i - 1].debugString
      result.add(newLineResult(i, i + newline - 1, true))
      # echo parser.input[i..i + newline - 1].debugString
      parser.pos = i + newline
    i += newline + 1
  
  if parser.pos != i:
    result.add(newLineResult(parser.pos, parser.input.len - 1, false))
    # echo parser.input[parser.pos..parser.input.len - 1].debugString
    parser.pos = parser.input.len

proc push*(parser: var Parser, input: string) =
  parser.input.add(input)
  # echo input.debugString

  let lines = parser.getLines()


  parser.parseBlockContinuation()
  parser.parseBlockStart()


when isMainModule:
  var p = newParser()
  p.push("# Hell")
  p.push("o\nit works")
  # echo(p.input)
