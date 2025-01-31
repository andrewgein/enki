import UIKit

enum CardState: String {
  case learning
  case reviewing
  case relearning
}

enum CardRaiting {
  case again
  case hard
  case good
  case easy
}

class Card: Codable, Equatable {
  var front: AttributedString
  var back: AttributedString
  var id: Int
  var state: CardState
  var step: Int!
  var simplicity: Double! // rename to simplicity
  var due: Date
  var currentInterval: Int!
  var wasReviewed: Bool = false
  
  enum CodingKeys: String, CodingKey {
    case front
    case back
    case id
    case state
    case step
    case simplicity
    case due
    case currentInterval
    case wasReviewed
  }
  
  init(front: AttributedString, back: AttributedString,
       id: Int? = nil,
       state: CardState? = nil,
       step: Int? = nil,
       simplicity: Double? = nil,
       due: Date? = nil,
       currentInterval: Int? = nil) {
    self.front = front
    self.back = back
    
    if id == nil {
      self.id = Int(Date().timeIntervalSince1970 * 1000)
    } else {
      self.id = id!
    }
    
    if state == nil {
      self.state = .learning
      self.step = 0
    } else {
      self.state = state!
      self.step = step!
    }
    self.simplicity = simplicity
    
    if due == nil {
      self.due = Date()
    } else {
      self.due = due!
    }
    self.currentInterval = currentInterval
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(front, forKey: .front)
    try container.encode(back, forKey: .back)
    try container.encode(id, forKey: .id)
    try container.encode(state.rawValue, forKey: .state)
    try container.encode(step, forKey: .step)
    try container.encode(simplicity, forKey: .simplicity)
    try container.encode(due, forKey: .due)
    try container.encode(currentInterval, forKey: .currentInterval)
    try container.encode(wasReviewed, forKey: .wasReviewed)
  }
  
  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    front = try container.decode(AttributedString.self, forKey: .front)
    back = try container.decode(AttributedString.self, forKey: .back)
    id = try container.decode(Int.self, forKey: .id)
    state = CardState(rawValue: try container.decode(String.self, forKey: .state))!
    step = try container.decode(Int?.self, forKey: .step)
    simplicity = try container.decode(Double?.self, forKey: .simplicity)
    due = try container.decode(Date.self, forKey: .due)
    currentInterval = try container.decode(Int?.self, forKey: .currentInterval)
    wasReviewed = try container.decode(Bool.self, forKey: .wasReviewed)
  }
  
 static func == (lhs: Card, rhs: Card) -> Bool {
    lhs.front == rhs.front &&
    lhs.back == rhs.back &&
    lhs.id == rhs.id &&
    lhs.state == rhs.state &&
    lhs.step == rhs.step &&
    lhs.simplicity == rhs.simplicity &&
    lhs.due == rhs.due &&
    lhs.currentInterval == rhs.currentInterval &&
    lhs.wasReviewed == rhs.wasReviewed
  }
}

struct CardReviewLog {
  var card: Card
  var raiting: CardRaiting
  var reviewDate: Date
  var reviewDuration: Double!
}
