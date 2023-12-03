import Algorithms

struct Day03: AdventDay {
  var data: String

  var schematic: EngineSchematic {
    var schematic = EngineSchematic()
    schematic.appendNewLine()
    for char in data {
      switch char {
      case "\n":
        schematic.appendNewLine()
      default:
        schematic.appendToLastLine(char)
      }
    }
    if schematic.last?.isEmpty == true {
      schematic.removeLast()
    }
    return schematic
  }
  
  func parts(schematic: EngineSchematic) -> [Part] {
    var parts: [Part] = []
    for (line, string) in schematic.enumerated() {
      var startX: Int?
      func collect(endX: Int) {
        let partNumber = Int(String(string[startX!...endX]))!
        parts.append(.init(
          partNumber: partNumber,
          origin: .init(x: startX!, y: line),
          length: endX - startX! + 1
        ))
        startX = nil
      }
      for (x, char) in string.enumerated() {
        if char.isNumber {
          if startX == nil { startX = x }
        } else {
          if startX != nil { collect(endX: x - 1) }
        }
      }
      if startX != nil {
        collect(endX: string.count - 1)
      }
    }
    return parts
  }

  func part1() -> Any {
    let schematic = schematic
    return parts(schematic: schematic)
      .filter { $0.isEnginePart(schematic) }
      .reduce(0) { $0 + $1.partNumber }
  }
  
  func part2() -> Any {
    return 0
  }
}

struct Point {
  var x: Int
  var y: Int
}

struct Part {
  var partNumber: Int
  var origin: Point
  var length: Int
}
extension Part {
  
  var adjacents: [Point] {
    var result: [Point] = []
    for x in origin.x-1 ... origin.x+length {
      result += [
        .init(x: x, y: origin.y - 1),
        .init(x: x, y: origin.y + 1)
      ]
    }
    result += [
      .init(x: origin.x - 1, y: origin.y),
      .init(x: origin.x + length, y: origin.y)
    ]
    return result
  }
  
  func isEnginePart(_ schematic: EngineSchematic) -> Bool {
    return self.adjacents.contains {
      if
        let char = schematic[point: $0],
        char != ".",
        !char.isNumber
      { true }
      else { false }
    }
  }
}

typealias EngineSchematic = [[Character]]

extension EngineSchematic {
  
  mutating func appendNewLine() {
    self.append([])
  }
  
  mutating func appendToLastLine(_ char: Character) {
    self[self.count - 1].append(char)
  }
  
  subscript(point point: Point) -> Character? {
    guard
      0..<self.count ~= point.y,
      0..<self[0].count ~= point.x
    else { return nil }
    return self[point.y][point.x]
  }
}
