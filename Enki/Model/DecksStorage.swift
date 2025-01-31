import Foundation

class DecksStorage {
  static var shared: DecksStorage = DecksStorage()
  var decks: [Deck] = [] {
    didSet {
      decks.sort {
        $0.name < $1.name
      }
    }
  }
  func put(deck: Deck) {
    decks.append(deck)
    save()
  }
  func get(id: Int) -> Deck {
    return decks[id]
  }
  
  func getAll() -> [Deck] {
    return decks
  }
  
  func remove(id: Int) {
    let url = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("decks/\(decks[id].name).deck")
    try? FileManager.default.removeItem(atPath: url.path)
    decks.remove(at: id)
  }
  
  
  func load() {
    let url = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("decks")
    do {
      let files = try FileManager.default.contentsOfDirectory(atPath: url.path)
      for file in files {
        do {
          let data = try Data(contentsOf: url.appendingPathComponent(file))
          decks.append(try PropertyListDecoder().decode(Deck.self, from: data))
          print("reading \(file)")
        } catch {}
      }
    } catch {
      print(error.localizedDescription)
    }
  }
  
  func save() {
    let url = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("decks")
    try! FileManager.default.createDirectory(atPath: url.path, withIntermediateDirectories: true)
    for deck in getAll() {
      let archivedData = try! PropertyListEncoder().encode(deck)
      let deckUrl = url.appendingPathComponent("\(deck.name.sanitized().whitespaceCondenced()).deck")
      try! archivedData.write(to: deckUrl, options: .atomic)
      print("writing \(deck.name).deck")
    }
  }
  
  func reset() {
    decks = [
      Deck(name: "Deck1", cards: [
        Card(front: AttributedString(stringLiteral: "front1"), back: AttributedString(stringLiteral: "back1")),
        Card(front: AttributedString(stringLiteral: "front2"), back: AttributedString(stringLiteral: "back2")),
        Card(front: AttributedString(stringLiteral: "front3"), back: AttributedString(stringLiteral: "back3"))
      ], scheduler: SM2_Scheduler()),
      
      Deck(name: "Deck2", cards: [
        Card(front: AttributedString(stringLiteral: "front1"), back: AttributedString(stringLiteral: "back1")),
        Card(front: AttributedString(stringLiteral: "front2"), back: AttributedString(stringLiteral: "back2")),
        Card(front: AttributedString(stringLiteral: "front3"), back: AttributedString(stringLiteral: "back3")),
        Card(front: AttributedString(stringLiteral: "front4"), back: AttributedString(stringLiteral: "back4"))
      ], scheduler: SM2_Scheduler())
    ]
    save()
  }
}
