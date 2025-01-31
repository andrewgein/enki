import Foundation

struct SM2_Scheduler: Scheduler {
  var learningSteps: [TimeInterval] = [60, 60 * 10]
  var graduatingInterval: Int = 1
  var easyInterval: Int = 4
  var relearningSteps: [TimeInterval] = [60 * 10]
  var minInterval: Int = 1
  var maxInterval: Int = 36500
  var startingEase: Double = 2.5
  var easyBonus: Double = 1.3
  var intervalModifier: Double = 1.0
  var hardInterval: Double = 1.2
  var newInterval: Double = 0.0
  
  func reviewCard(card: Card, raiting: CardRaiting, reviewDate: Date! = Date(), reviewDuration: Double! = nil) -> (Card, CardReviewLog) {
    var reviewLog = CardReviewLog(card: card, raiting: raiting, reviewDate: reviewDate, reviewDuration: reviewDuration)
    
    /*
     calculate card's next interval
     learningSteps.count() == 0: no learning steps defined so move card to .review
     card.step > learningSteps.count: handles the edge case, when a card was originally scheduled with more
      learning steps
    */
    var card = card
    let state = card.state
    card.wasReviewed = true
    switch state {
    case .learning:
      if learningSteps.count == 0 || card.step > learningSteps.count {
        card.state = .reviewing
        card.step = nil
        card.simplicity = self.startingEase
        card.currentInterval = self.graduatingInterval
        card.due = Calendar.current.date(byAdding: .day, value: card.currentInterval, to: reviewDate)!
      } else {
        if raiting == .again {
          card.step = 0
          card.due = reviewDate.addingTimeInterval(learningSteps[card.step])
          
        } else if raiting == .hard {
          // card step stays the same
          
          if card.step == 0 && learningSteps.count == 1 {
            card.due = reviewDate.addingTimeInterval(learningSteps[card.step])
          } else if card.step == 0 && learningSteps.count >= 2 {
            card.due = reviewDate.addingTimeInterval((learningSteps[card.step] + learningSteps[card.step + 1]) / 2)
          } else {
            card.due = reviewDate.addingTimeInterval(learningSteps[card.step])
          }
          
        } else if raiting == .good {
          if card.step + 1 == learningSteps.count { // last step
            card.state = .reviewing
            card.step = nil
            card.simplicity = startingEase
            card.currentInterval = graduatingInterval
            card.due = Calendar.current.date(byAdding: .day, value: card.currentInterval, to: reviewDate)!
          } else {
            card.step += 1
            card.due = reviewDate.addingTimeInterval(learningSteps[card.step])
          }
        } else if raiting == .easy {
          card.state = .reviewing
          card.step = nil
          card.simplicity = startingEase
          card.currentInterval = easyInterval
          card.due = Calendar.current.date(byAdding: .day, value: card.currentInterval, to: reviewDate)!
        }
      }
    case .reviewing:
      if raiting == .again { // the card is "lasped"
        card.simplicity = max(1.3, card.simplicity * 0.8) // reduce ease by 20%
        let currentInterval = max(minInterval, round(Double(card.currentInterval) * newInterval * intervalModifier))
        
        card.currentInterval = getFuzzedInterval(currentInterval)
        // if there are no relearning steps (they were left blank)
        if relearningSteps.count > 0 {
          card.state = .relearning
          card.step = 0
          card.due = reviewDate.addingTimeInterval(relearningSteps[card.step])
        } else {
          card.due = Calendar.current.date(byAdding: .day, value: card.currentInterval, to: reviewDate)!
        }
        
      } else if raiting == .hard {
        card.simplicity = max(1.3, card.simplicity * 0.85) // reduce ease by 15%
        let currentInterval = min(maxInterval, round(Double(card.currentInterval) * hardInterval * intervalModifier))
        card.currentInterval = Int(getFuzzedInterval(currentInterval))
        card.due = Calendar.current.date(byAdding: .day, value: card.currentInterval, to: reviewDate)!
      } else if raiting == .good {
        //simplicity stays the same
        let daysOverdue = Calendar.current.dateComponents([.day],
                                                          from: Calendar.current.startOfDay(for: reviewDate),
                                                          to: Calendar.current.startOfDay(for: card.due)).day!
        var currentInterval: Int = 0
        if daysOverdue >= 1 {
          
          currentInterval = min(maxInterval,
                                round((Double(card.currentInterval) + Double(daysOverdue) / 2) * card.simplicity * intervalModifier))
        } else {
          currentInterval = min(maxInterval,
                                round(Double(card.currentInterval) * card.simplicity * intervalModifier))
        }
        card.currentInterval = getFuzzedInterval(currentInterval)
        card.due = Calendar.current.date(byAdding: .day, value: card.currentInterval, to: reviewDate)!
      } else if raiting == .easy {
        let daysOverdue = Calendar.current.component(.day, from: Date(timeIntervalSinceReferenceDate: (reviewDate.timeIntervalSinceReferenceDate -
                                                                                                       card.due.timeIntervalSinceReferenceDate)))
        var currentInterval: Int = 0
        if daysOverdue >= 1 {
          currentInterval = min(maxInterval,
                                round(Double(card.currentInterval + daysOverdue) * card.simplicity * easyBonus * intervalModifier))
        } else {
          currentInterval = min(maxInterval,
                                round(Double(card.currentInterval) * card.simplicity * easyBonus * intervalModifier))
        }
        card.currentInterval = getFuzzedInterval(currentInterval)
        card.simplicity = card.simplicity * 1.15
        card.due = Calendar.current.date(byAdding: .day, value: card.currentInterval, to: reviewDate)!
      }
    case .relearning:
      /*
       calculate the card's next interval
       relearningSteps == 0: no relearning steps defined so move card to Review state
       card.step > relearningSteps handles the edge-case when a card was originally scheduled with a scheduler with more
       relearning steps than the current scheduler
      */
      if relearningSteps.count == 0 || card.step > relearningSteps.count {
        card.state = .reviewing
        card.step = nil
        
        //don't update ease
        card.currentInterval = min(maxInterval, round(Double(card.currentInterval) * card.simplicity * intervalModifier))
        card.due = Calendar.current.date(byAdding: .day, value: card.currentInterval, to: reviewDate)!
      } else {
        if raiting == .again {
          card.step = 0
          card.due = reviewDate + relearningSteps[card.step]
        } else if raiting == .hard {
          // card step stay the same
          if card.step == 0 && relearningSteps.count == 1 {
            card.due = reviewDate + (relearningSteps[card.step]) * 1.5
          } else if card.step == 0 && relearningSteps.count >= 2 {
            card.due = reviewDate.addingTimeInterval((relearningSteps[card.step] + relearningSteps[card.step + 1]) / 2)
          } else {
            card.due = reviewDate.addingTimeInterval(relearningSteps[card.step])
          }
        } else if raiting == .good {
          if card.step + 1 == relearningSteps.count { // last step
            card.state = .reviewing
            card.step = nil
            card.currentInterval = min(maxInterval, round(Double(card.currentInterval) * card.simplicity * intervalModifier))
            card.due = Calendar.current.date(byAdding: .day, value: card.currentInterval, to: reviewDate)!
          } else {
            card.step += 1
            card.due = reviewDate.addingTimeInterval(relearningSteps[card.step])
          }
        } else if raiting == .easy {
          card.state = .reviewing
          card.step = nil
          // don't update ease
          card.currentInterval = min(maxInterval, round(Double(card.currentInterval) * card.simplicity * easyBonus * intervalModifier))
          card.due = Calendar.current.date(byAdding: .day, value: card.currentInterval, to: reviewDate)!
        }
      }
    }
    return (card, reviewLog)
       
  }
  
  private func getFuzzedInterval(_ interval: Int) -> Int {
    /*
     Takes the current calculated interval and adds a small amount of random fuzz to it.
     For example, a card that would've been due in 50 days, after fuzzing, might be due in 49, or 51 days.
    */
    if interval < 3 {
      return interval
    }
    
    let (minInterval, maxInterval) = getFuzzedRange(interval)
    var fuzzedInterval = min(Int.random(in: minInterval...maxInterval), self.maxInterval)
    return fuzzedInterval
    
  }
  
  private func getFuzzedRange(_ interval: Int) -> (Int, Int) {
    /*
     Helper function that computes the possible upper and lower bounds of the interval after fuzzing.
     */
    let FUZZ_RANGES = [
      [ "start": 2.5, "end": 7.0, "factor": 0.15 ],
      [ "start": 7.0, "end": 20.0, "factor": 0.1],
      [ "start": 20.0, "end": Double.infinity, "factor": 0.05]
    ]

    var delta = 1.0
    for fuzzRange in FUZZ_RANGES {
      delta += fuzzRange["factor"]! * max(min(Double(interval), fuzzRange["end"]!) - fuzzRange["start"]!, 0.0)
    }
    var minInterval = round(Double(interval) - delta)
    var maxInterval = round(Double(interval) + delta)
    
    // make sure the minInterval and maxInterval fall into a valid range
    minInterval = max(2, minInterval)
    maxInterval = min(maxInterval, self.maxInterval)
    minInterval = min(minInterval, maxInterval)
      
    return (minInterval, maxInterval)
  }
  
  private func round(_ num: Double) -> Int {
    Int(num.rounded(.toNearestOrEven))
  }
  
}

