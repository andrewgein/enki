import Foundation

protocol Scheduler {
  func reviewCard(card: Card, raiting: CardRaiting, reviewDate: Date!, reviewDuration: Double!) -> (Card, CardReviewLog)
}
