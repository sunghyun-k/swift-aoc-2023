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

  func part2() -> Any {
    let cards = cards
    var myCardsCounts = [Int](repeating: 1, count: cards.count)
    
    for (index, card) in cards.enumerated() {
      for offset in 0..<card.winCount {
        let myCards = myCardsCounts[index]
        myCardsCounts[safe: index + offset + 1]? += myCards
      }
    }
    return myCardsCounts.reduce(0, +)
  }
}

struct Card {
  var winningNumbers: Set<Int>
  var havingNumbers: [Int]
}
extension Card {
  var winCount: Int {
    havingNumbers
      .filter { winningNumbers.contains($0) }
      .count
  }
  var point: Int {
    if winCount <= 0 { return 0 }
    return (pow(2, winCount - 1) as NSDecimalNumber).intValue
  }
}

extension MutableCollection where Self: RandomAccessCollection {
  subscript(safe index: Index) -> Element? {
    get {
      if self.startIndex <= index,
         self.endIndex > index
      { self[index] }
      else { nil }
    }
    set {
      if let newValue,
         self.startIndex <= index,
         self.endIndex > index
      { self[index] = newValue }
    }
  }
}
