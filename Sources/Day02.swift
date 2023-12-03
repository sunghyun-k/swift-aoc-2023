import Algorithms

struct Day02: AdventDay {
  var data: String

  var games: [Game] {
    return data.split(separator: "\n")
      .map {
        let game = $0.split(separator: ":")
        let id = Int(game[0].dropFirst(5))!
        let sets = game[1].split(separator: "; ")
          .map {
            let colors = $0.split(separator: ", ")
            var set = Game.Set()
            colors.forEach {
              let value = $0.split(separator: " ")
              let count = Int(value[0])!
              switch value[1] {
              case "red": set.red = count
              case "green": set.green = count
              case "blue": set.blue = count
              default: fatalError()
              }
            }
            return set
          }
        return Game(id: id, sets: sets)
      }
  }

  func part1() -> Any {
    // 12 red cubes, 13 green cubes, and 14 blue cubes
    let validGame = games.filter {
      for set in $0.sets {
        if
          set.red > 12
          || set.green > 13
          || set.blue > 14
        {
          return false
        }
      }
      return true
    }
    return validGame.reduce(0) { $0 + $1.id }
  }
  
  func part2() -> Any {
    return games
      .lazy
      .map {
        [$0.sets.max(of: \.red)!.red,
         $0.sets.max(of: \.green)!.green,
         $0.sets.max(of: \.blue)!.blue]
      }
      .map { $0.reduce(1, *) }
      .reduce(0, +)
  }
}

struct Game {
  struct Set {
    var red: Int = 0
    var green: Int = 0
    var blue: Int = 0
  }
  
  var id: Int
  var sets: [Set]
}

extension Sequence {
  func max(of keyPath: KeyPath<Element, some Comparable>) -> Element? {
    return self.max { $0[keyPath: keyPath] < $1[keyPath: keyPath] }
  }
}
