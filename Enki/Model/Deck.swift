import Foundation

extension Date {

    static func -(recent: Date, previous: Date) -> (month: Int?, day: Int?, hour: Int?, minute: Int?, second: Int?) {
        let day = Calendar.current.dateComponents([.day], from: previous, to: recent).day
        let month = Calendar.current.dateComponents([.month], from: previous, to: recent).month
        let hour = Calendar.current.dateComponents([.hour], from: previous, to: recent).hour
        let minute = Calendar.current.dateComponents([.minute], from: previous, to: recent).minute
        let second = Calendar.current.dateComponents([.second], from: previous, to: recent).second

        return (month: month, day: day, hour: hour, minute: minute, second: second)
    }

}

class Deck: Codable {
  var name: String
  var cards: [Card] {
    didSet {
      cards = cards.sorted(by: {$0.due < $1.due})
    }
  }
  var scheduler: SM2_Scheduler
  var learningCards: [Card] {
    cards.filter{ ($0.due - Date()).day! <= 0 }
  }
  enum CodingKeys: String, CodingKey {
    case name
    case cards
  }
  
  var currentCard: Card! {
    get {
      let filtered = cards.filter{ ($0.due - Date()).day! <= 0 }
      if filtered.count > 0 {
        return filtered[0]
      }
      return nil
    }
    set {
      let filtered = cards.filter{ ($0.due - Date()).day! <= 0 }
      if filtered.count > 0 {
        return cards[0] = newValue
      }
    }
  }
 
  var new: [Card] {
    get {
      cards.filter {
        !$0.wasReviewed
      }
    }
  }
  
  var learn: [Card] {
    get {
      cards.filter {
        ($0.state == .learning && $0.wasReviewed)
      }
    }
  }
  
  var due: [Card] {
    get {
      cards.filter {
        ($0.due < Date() && $0.wasReviewed)
      }
    }
  }
  
  init(name: String, cards: [Card], scheduler: SM2_Scheduler) {
    self.name = name
    self.cards = cards
    self.scheduler = scheduler
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(name, forKey: .name)
    try container.encode(cards, forKey: .cards)
  }
  
  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    name = try container.decode(String.self, forKey: .name)
    cards = try container.decode([Card].self, forKey: .cards)
    scheduler = SM2_Scheduler()
  }
  
}
