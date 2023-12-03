import Algorithms

struct Day01: AdventDay {
  var data: String

  var entities: [String.SubSequence] {
    return data.split(separator: "\n")
  }

  func part1() -> Any {
    entities
      .map { str in
        let firstNum = str.first { $0.isNumber }!
        let lastNum = str.last { $0.isNumber }!
        return Int("\(firstNum)\(lastNum)")!
      }
      .reduce(0, +)
  }
  
  func part2() -> Any {
    let numberMap = [
      "one": 1,
      "two": 2,
      "three": 3,
      "four": 4,
      "five": 5,
      "six": 6,
      "seven": 7,
      "eight": 8,
      "nine": 9,
      "zero": 0
    ]
    let targets = numberMap.reduce([String]()) {
      $0 + [$1.key, String($1.value)]
    }
    
    return entities.map { entity in
      var firstRanges: [Range<String.Index>] = []
      var lastRanges: [Range<Substring.Index>] = []
      
      for target in targets {
        if let firstRange = entity.range(of: target) {
          firstRanges.append(firstRange)
        }
        if let lastRange = entity.range(of: target, options: .backwards) {
          lastRanges.append(lastRange)
        }
      }
      let firstRange = firstRanges.min { $0.lowerBound < $1.lowerBound }!
      let lastRange = lastRanges.max { $0.upperBound < $1.upperBound }!
      
      let firstNumber = entity[firstRange]
      let lastNumber = entity[lastRange]
      
      let firstInt = numberMap[String(firstNumber)] ?? Int(firstNumber)!
      let lastInt = numberMap[String(lastNumber)] ?? Int(lastNumber)!
      return firstInt * 10 + lastInt
    }
    .reduce(0, +)
  }
}
