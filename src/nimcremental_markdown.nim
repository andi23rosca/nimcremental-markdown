import core/preprocess
import unicode

when isMainModule:
  var preprocessor = newPreprocessor()
  preprocess(preprocessor, "\thi")
  preprocessor.printChunks()
