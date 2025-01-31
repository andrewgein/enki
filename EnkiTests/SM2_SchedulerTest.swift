import XCTest
@testable import Enki

final class SM2_SchedulerTest: XCTestCase {
  let scheduler = SM2_Scheduler()
  var card = Card(front: AttributedString(stringLiteral: ""), back: AttributedString(stringLiteral: ""))
  var reviewLog: CardReviewLog!
  
  func testGoodLearningSteps() {
    let createAt = Date()
    var raiting = CardRaiting.good
    (card, reviewLog) = scheduler.reviewCard(card: card, raiting: raiting, reviewDate: card.due)
    
    XCTAssertTrue(card.state == .learning)
    XCTAssertTrue(card.step == 1)
    XCTAssertTrue(lround((card.due.timeIntervalSinceReferenceDate - createAt.timeIntervalSinceReferenceDate) / 100) == 6)
    
    raiting = .good
    (card, reviewLog) = scheduler.reviewCard(card: card, raiting: raiting, reviewDate: card.due)
    
    XCTAssertTrue(card.state == .reviewing)
    XCTAssertTrue(card.step == nil)
    XCTAssertTrue(lround((card.due.timeIntervalSinceReferenceDate - createAt.timeIntervalSinceReferenceDate) / 3600) == 24)
  }
  
  func testAgainLearningSteps() {
    let createAt = Date()
    let raiting = CardRaiting.again
    (card, reviewLog) = scheduler.reviewCard(card: card, raiting: raiting, reviewDate: card.due)
    
    XCTAssertTrue(card.state == .learning)
    XCTAssertTrue(card.step == 0)
    XCTAssertTrue(lround((card.due.timeIntervalSinceReferenceDate - createAt.timeIntervalSinceReferenceDate) / 10) == 6)
  }
  
  func testHardLearningSteps() {
    let createAt = Date()
    let raiting = CardRaiting.hard
    (card, reviewLog) = scheduler.reviewCard(card: card, raiting: raiting, reviewDate: card.due)
    
    XCTAssertTrue(card.state == .learning)
    XCTAssertTrue(card.step == 0)
    XCTAssertTrue(lround((card.due.timeIntervalSinceReferenceDate - createAt.timeIntervalSinceReferenceDate) / 10) == 33)
    
  }
  
  func testEasyLearningSteps() {
    let createAt = Date()
    let raiting = CardRaiting.easy
    (card, reviewLog)  = scheduler.reviewCard(card: card, raiting: raiting, reviewDate: card.due)
    
    XCTAssertTrue(card.state == .reviewing)
    XCTAssertTrue(card.step == nil)
    XCTAssertTrue(lround((card.due.timeIntervalSinceReferenceDate - createAt.timeIntervalSinceReferenceDate) / 86400) == 4)
  }
  
  func testReviewingState() {
    var raiting = CardRaiting.good
    (card, reviewLog) = scheduler.reviewCard(card: card, raiting: raiting, reviewDate: card.due)
    
    raiting = .good
    (card, reviewLog) = scheduler.reviewCard(card: card, raiting: raiting, reviewDate: card.due)
    
    XCTAssertTrue(card.state == .reviewing)
    XCTAssertTrue(card.step == nil)
    
    var prevDue = card.due
    raiting = .good
    (card, reviewLog) = scheduler.reviewCard(card: card, raiting: raiting, reviewDate: card.due)
    
    XCTAssertTrue(card.state == .reviewing)
    XCTAssertTrue(card.currentInterval == 2)
    XCTAssertTrue(lround((card.due.timeIntervalSinceReferenceDate - prevDue.timeIntervalSinceReferenceDate) / 3600) == 48)
    
    prevDue = card.due
    raiting = .again
    (card, reviewLog) = scheduler.reviewCard(card: card, raiting: raiting, reviewDate: card.due)
    
    XCTAssertTrue(card.state == .relearning)
    XCTAssertTrue(card.currentInterval == 1)
    XCTAssertTrue(lround((card.due.timeIntervalSinceReferenceDate - prevDue.timeIntervalSinceReferenceDate) / 60) == 10)
  }
  
  func testNoLearningSteps() {
    var scheduler = SM2_Scheduler(learningSteps: [])
    let createdAt = Date()
    (card, reviewLog) = scheduler.reviewCard(card: card, raiting: .again, reviewDate: createdAt)
    
    XCTAssertTrue(card.state == .reviewing)
    //XCTAssertTrue(Calendar.current.dateComponents([.day], from: card.due, to: createdAt).day! >= 1)
  }
  
  func testNoRelearnSteps() {
    let scheduler = SM2_Scheduler(relearningSteps: [])
    let createdAt = Date()
    (card, reviewLog) = scheduler.reviewCard(card: card, raiting: .good, reviewDate: createdAt)
    
    XCTAssertTrue(card.state == .learning)
    
    (card, reviewLog) = scheduler.reviewCard(card: card, raiting: .good, reviewDate: card.due)
    
    XCTAssertTrue(card.state == .reviewing)
    
    let prevDue = card.due
    (card, reviewLog) = scheduler.reviewCard(card: card, raiting: .good, reviewDate: card.due)
    
    XCTAssertTrue(card.state == .reviewing)
    //XCTAssertTrue(Calendar.current.dateComponents([.day], from: card.due, to: prevDue).day! >= 1)
  }
  
  func testMultipleSchedulers() {
    let schedulerTwoLearningSteps = SM2_Scheduler(learningSteps: [2 * 60.0, 10 * 60.0])
    let schedulerNoLearningSteps = SM2_Scheduler(learningSteps: [])
    (card, reviewLog) = schedulerTwoLearningSteps.reviewCard(card: card, raiting: .good, reviewDate:  Date())
    
    XCTAssertTrue(card.state == .learning)
    XCTAssertTrue(card.step == 1)
    
    (card, reviewLog) = schedulerNoLearningSteps.reviewCard(card: card, raiting: .again, reviewDate: Date())
    
    XCTAssertTrue(card.state == .reviewing)
    XCTAssertTrue(card.step == nil)
    
    let schedulerThreeRelearningSteps = SM2_Scheduler(relearningSteps: [60.0, 10 * 60.0, 15 * 60.0])
    let schedulerNoRelearningSteps = SM2_Scheduler(relearningSteps: [])
    
    (card, reviewLog) = schedulerThreeRelearningSteps.reviewCard(card: card, raiting: .again, reviewDate: Date())
    
    XCTAssertTrue(card.state == .relearning)
    XCTAssertTrue(card.step == 0)
    
    (card, reviewLog) = schedulerThreeRelearningSteps.reviewCard(card: card, raiting: .good, reviewDate: Date())
    
    XCTAssertTrue(card.state == .relearning)
    XCTAssertTrue(card.step == 1)
    
    (card, reviewLog) = schedulerThreeRelearningSteps.reviewCard(card: card, raiting: .good, reviewDate: Date())
    
    XCTAssertTrue(card.state == .relearning)
    XCTAssertTrue(card.step == 2)
    
    (card, reviewLog) = schedulerNoRelearningSteps.reviewCard(card: card, raiting: .again, reviewDate: Date())
    
    XCTAssertTrue(card.state == .reviewing)
    XCTAssertTrue(card.step == nil)
    
  }
  
  func testMaximumInterval() {
    let scheduler = SM2_Scheduler(maxInterval: 100)
  
    for _ in 0...5 {
      var prevDue = card.due
      (card, reviewLog) = scheduler.reviewCard(card: card, raiting: .easy, reviewDate: card.due)
      
      XCTAssertTrue(Calendar.current.dateComponents([.day], from: card.due, to: prevDue).day! <= scheduler.maxInterval)
      
    }
  }
  
}
