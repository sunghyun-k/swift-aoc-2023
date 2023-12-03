import Algorithms

struct Day03: AdventDay {
  var data: String

  var schematic: EngineSchematic
  
  init(data: String) {
    self.data = data
    let matrix: [[Character]] = data
      .split(separator: "\n")
      .map { $0.map { $0 } }
    self.schematic = EngineSchematic(matrix: matrix)
  }

  func part1() -> Any {
    return schematic.parts
      .filter { $0.isEnginePart(schematic) }
      .reduce(0) { $0 + $1.partNumber }
  }
  
  func part2() -> Any {
    return schematic.starSymbols
      .lazy
      .compactMap { $0.partsIfIsGear(schematic) }
      .map { $0.reduce(1) { $0 * $1.partNumber } }
      .reduce(0, +)
  }
}

struct Point: Hashable {
  var x: Int
  var y: Int
}

class Part {
  var partNumber: Int
  var origin: Point
  var length: Int
  init(partNumber: Int, origin: Point, length: Int) {
    self.partNumber = partNumber
    self.origin = origin
    self.length = length
  }
}

extension Part: Hashable {
  static func == (lhs: Part, rhs: Part) -> Bool {
    lhs.partNumber == rhs.partNumber
    && lhs.origin == rhs.origin
    && lhs.length == rhs.length
  }
  func hash(into hasher: inout Hasher) {
    hasher.combine(partNumber)
    hasher.combine(origin)
    hasher.combine(length)
  }
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
        let char = schematic[$0],
        case .symbol(let symbol) = char,
        symbol.character != "."
      { true }
      else { false }
    }
  }
}

struct Symbol {
  var character: Character
  var point: Point
}
extension Symbol {
  var adjacents: [Point] {
    [
      .init(x: point.x - 1, y: point.y - 1),
      .init(x: point.x, y: point.y - 1),
      .init(x: point.x + 1, y: point.y - 1),
      .init(x: point.x - 1, y: point.y),
      .init(x: point.x + 1, y: point.y),
      .init(x: point.x - 1, y: point.y + 1),
      .init(x: point.x, y: point.y + 1),
      .init(x: point.x + 1, y: point.y + 1),
    ]
  }
  func partsIfIsGear(_ schematic: EngineSchematic) -> Set<Part>? {
    var parts: Set<Part> = []
    for point in adjacents {
      if let part = schematic[point]?.part{
        parts.insert(part)
      }
    }
    if parts.count == 2 {
      return parts
    }
    return nil
  }
}

enum EngineElement {
  case part(Part)
  case symbol(Symbol)
}
extension EngineElement {
  var part: Part? {
    if case .part(let part) = self { part }
    else { nil }
  }
  var isPart: Bool {
    if case .part = self { true }
    else { false }
  }
  var starSymbol: Symbol? {
    if case .symbol(let symbol) = self,
       symbol.character == "*"
    { symbol }
    else { nil }
  }
}
extension EngineElement: CustomStringConvertible {
  var description: String {
    switch self {
    case .part:
      "0"
    case .symbol(let character):
      "\(character)"
    }
  }
}
extension EngineSchematic: CustomStringConvertible {
  var description: String {
    let newLine: Character = "\n"
    var str = ""
    for line in self.rawValue {
      for element in line {
        str.append(element.description)
      }
      str.append(newLine)
    }
    return str
  }
}

struct EngineSchematic {
  private var rawValue: [[EngineElement]] = []
  
  var yCount: Int {
    rawValue.count
  }
  
  var xCount: Int {
    rawValue.first?.count ?? 0
  }
  
  init(matrix: [[Character]]) {
    for (y, string) in matrix.enumerated() {
      self.appendNewLine()
      func collectNumberIfCan(prevElement: EngineElement) {
        if let part = prevElement.part {
          part.partNumber = Int(String(string[part.origin.x ..< part.origin.x+part.length]))!
        }
      }
      
      for (x, char) in string.enumerated() {
        
        let prevElement: EngineElement? = self[Point(x: x - 1, y: y)]
        
        let element: EngineElement
        if char.isNumber {
          if let prevElement,
             let part = prevElement.part
          {
            element = prevElement
            part.length += 1
          } else {
            element = .part(.init(
              partNumber: -1,
              origin: Point(x: x, y: y),
              length: 1
            ))
          }
        } else {
          if let prevElement {
            collectNumberIfCan(prevElement: prevElement)
          }
          element = .symbol(.init(character: char, point: .init(x: x, y: y)))
        }
        self.appendToLastLine(element)
      }
      if let lastElement = self[Point(x: xCount - 1, y: y)] {
        collectNumberIfCan(prevElement: lastElement)
      }
    }
  }
  
  private mutating func appendNewLine() {
    rawValue.append([])
  }
  
  private mutating func appendToLastLine(_ element: EngineElement) {
    rawValue[yCount - 1].append(element)
  }
  
  subscript(point: Point) -> EngineElement? {
    if
      0..<yCount ~= point.y,
      0..<xCount ~= point.x
    { rawValue[point.y][point.x] }
    else { nil }
  }
  
  private var allElements: some Sequence<EngineElement> {
    rawValue.joined()
  }
  
  var parts: Set<Part> {
    var parts: Set<Part> = []
    for element in allElements {
      if let part = element.part {
        parts.insert(part)
      }
    }
    return parts
  }
  
  var starSymbols: [Symbol] {
    allElements.compactMap { $0.starSymbol }
  }
}
