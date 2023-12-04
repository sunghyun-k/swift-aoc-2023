import Algorithms
import Foundation

struct Day04: AdventDay {
  var data: String
  
  var cards: [Card] {
    let cards = data
      .split(separator: "\n")
      .lazy
      .map { line -> Substring in line.split(separator: ":")[1] }
      .map { line -> [[Int]] in
        line.split(separator: " | ")
          .map { numbers in
            numbers.split(separator: " ").map { Int($0)! }
          }
      }
      .map { values -> Card in
        Card(winningNumbers: Set(values[0]),
             havingNumbers: values[1])
      }
    return Array(cards)
  }

  func part1() -> Any {
    return cards
      .reduce(0) { $0 + $1.point }
  }

//  func part2() -> Any {
//    
//  }
}

struct Card {
  var winningNumbers: Set<Int>
  var havingNumbers: [Int]
}
extension Card {
  var point: Int {
    let count = havingNumbers
      .filter { winningNumbers.contains($0) }
      .count
    if count <= 0 { return 0 }
    return (pow(2, count - 1) as NSDecimalNumber).intValue
  }
}

