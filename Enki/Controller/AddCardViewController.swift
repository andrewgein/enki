import UIKit

class AddCardViewController: UIViewController {
  @IBOutlet var cardTypeMenuButton: UIButton!
  @IBOutlet var deckMenuButton: UIButton!
  @IBOutlet var frontSideView: UITextView!
  @IBOutlet var backSideView: UITextView!
  
  var destinationDeck: Deck = DecksStorage.shared.get(id: 0)
  
  var callback: (() -> Void)!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    var children = [UIMenuElement]()
    for deck in DecksStorage.shared.getAll() {
      children.append(UIAction(title: deck.name, handler: {(action: UIAction) in
        self.destinationDeck = DecksStorage.shared.getAll().first(where: {$0.name == deck.name})!
      }))
    }
    deckMenuButton.menu = UIMenu(options: .displayInline,  children: children)
    cardTypeMenuButton.menu = UIMenu(options: .displayInline, children: [
      UIAction(title: "Basic"){_ in}
    ])
  }
  
  @IBAction func add() {
    let card = Card(front: AttributedString(frontSideView.attributedText),
                    back: AttributedString(backSideView.attributedText))
    destinationDeck.cards.append(card)
    DecksStorage.shared.save()
    dismiss(animated: true)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    callback()
  }

}
