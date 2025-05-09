import unicode

# Negative values are used to avoid conflicts with Unicode values
# They're virtual codes used to normalize the input stream
const codeTextChunk* = Rune(-7) # Special chunk for text, doesn't map to any particular character
const codeEOF* = Rune(-6)
const codeCarriageReturn* = Rune(-5)
const codeLineFeed* = Rune(-4)
const codeCarriageReturnLineFeed* = Rune(-3)
const codeHorizontalTab* = Rune(-2)
const codeVirtualSpace* = Rune(-1)

const codeBOM* = Rune(0xFEFF)
const codeNull* = Rune(0x0000)
const codeCR* = Rune(0x000D)
const codeLF* = Rune(0x000A)
const codeHT* = Rune(0x0009)
