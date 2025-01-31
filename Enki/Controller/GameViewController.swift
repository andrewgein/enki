import UIKit

class GameViewController: UIViewController {
  var deck: Deck!
  var scheduler: SM2_Scheduler = SM2_Scheduler()
  @IBOutlet var stack: UIStackView!
  @IBOutlet var buttonsStack: UIStackView!
  @IBOutlet var showAnswerButton: UIButton!
  @IBOutlet var editButton: UIButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    showQuestion()
  }
  
  func showQuestion() {
    guard deck.currentCard != nil else {
      showEndScreen()
      return
    }
    let question = getTextView(text: deck.currentCard.front)
    stack.addArrangedSubview(question)
    for view in buttonsStack.arrangedSubviews {
      view.isHidden = (view != showAnswerButton)
    }
    
  }
  
  @IBAction func showAnswer() {
    let answer = getTextView(text: deck.currentCard.back)
    let separator = UIView()
    stack.distribution = .fill
    stack.addArrangedSubview(separator)
    stack.addArrangedSubview(answer)

    separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
    answer.heightAnchor.constraint(equalTo: stack.arrangedSubviews[0].heightAnchor).isActive = true
    separator.backgroundColor = UIColor(named: "FontColor")
        //separator.heightAnchor.constraint(equalTo: stack.heightAnchor, multiplier: 0.6).isActive = true
    for view in buttonsStack.arrangedSubviews {
      view.isHidden = (view == showAnswerButton)
    }
  }
  
  func showEndScreen() {
    let title = getTextView(text: "Congratulations! You have finished this deck for now.")
    title.font = UIFont.systemFont(ofSize: 30)
    stack.addArrangedSubview(title)
    for view in buttonsStack.arrangedSubviews {
      view.isHidden = true
    }
    editButton.isEnabled = false
  }
  
  func getTextView(text: AttributedString) -> UITextView {
    let view = UITextView()
    view.isEditable = false
    view.attributedText = NSAttributedString(text)
    view.font = UIFont.systemFont(ofSize: 20)
    view.textColor = UIColor(named: "FontColor")
    view.backgroundColor = UIColor(named: "BackgroundColor2")
    view.textAlignment = .center
    return view
  }
  
  @IBAction func exit() {
    self.dismiss(animated: true)
  }
  
  
  @IBAction func reviewCard(_ sender: UIButton) {
    var raiting: CardRaiting
    switch sender.titleLabel!.text! {
    case "Again":
      raiting = .again
    case "Hard":
      raiting = .hard
    case "Good":
      raiting = .good
    case "Easy":
      raiting = .easy
    default:
      return
    }
    let (card,_) = scheduler.reviewCard(card: deck.currentCard, raiting: raiting)
    print("scheduled to \(card.due), state is \(card.state)")
    deck.currentCard = card
    for view in stack.arrangedSubviews{
      view.removeFromSuperview()
    }
    showQuestion()
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "toEditScreen" {
      let nextViewController = segue.destination as! EditCardViewController
      nextViewController.card = deck.currentCard
      nextViewController.deck = deck
      nextViewController.complition = { [self] in
        if self.stack.arrangedSubviews.count == 3 {
          (stack.arrangedSubviews[0] as! UITextView).attributedText = getTextView(text: deck.currentCard.front).attributedText
          (stack.arrangedSubviews[2] as! UITextView).attributedText = getTextView(text: deck.currentCard.back).attributedText
        } else if self.stack.arrangedSubviews.count == 1 {
          (stack.arrangedSubviews[0] as! UITextView).attributedText = getTextView(text: deck.currentCard.front).attributedText
        }
        
      }
    }
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    DecksStorage.shared.save()
  }
  
}
