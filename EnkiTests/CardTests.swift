import XCTest
@testable import Enki

final class CardTests: XCTestCase {
  let card = Card(front: AttributedString(stringLiteral: ""), back: AttributedString(stringLiteral: ""))
  func test() {
    XCTAssertTrue(card.state == .learning)
    XCTAssertTrue(card.step == 0)
  }
  
  func testSerialize() {
    let archived = try! PropertyListEncoder().encode(card)
    let url = try! FileManager.default.url(for: .applicationDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathExtension("test.card")
    try! archived.write(to: url, options: .atomic)
    let unarchivedData = try! Data(contentsOf: url)
    let unarchived = try! PropertyListDecoder().decode(Card.self, from: unarchivedData)
    XCTAssertTrue(card == unarchived)
  }
}
