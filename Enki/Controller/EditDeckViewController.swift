import UIKit

class EditDeckViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  var deck: Deck!
  @IBOutlet var table: UITableView!
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return deck.cards.count
  }
  
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return "\(deck.name)"
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "CardCell") as! CardCellView
    cell.name.text = String(deck.cards[indexPath.row].front.characters)
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let viewController = storyboard.instantiateViewController(withIdentifier: "EditCardViewController") as! EditCardViewController
    viewController.deck = self.deck
    viewController.card = self.deck.cards[indexPath.row]
    viewController.complition = { [self] in
      self.table.reloadRows(at: [indexPath], with: .automatic)
    }
    self.present(viewController, animated: true)
  }
  
  func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, sourceView, completionHandler) in
      self.deck.cards.remove(at: indexPath.row)
      completionHandler(true)
      self.table.reloadData()
    }
    
    let editAction = UIContextualAction(style: .normal, title: "Edit") { (action, sourceView, completion) in
      let storyboard = UIStoryboard(name: "Main", bundle: nil)
      let viewController = storyboard.instantiateViewController(withIdentifier: "EditCardViewController") as! EditCardViewController
      viewController.deck = self.deck
      viewController.card = self.deck.cards[indexPath.row]
      viewController.complition = { [self] in
        self.table.reloadRows(at: [indexPath], with: .automatic)
      }
      self.present(viewController, animated: true)
      completion(true)
    }
    let swipeConfiguration = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
    return swipeConfiguration
  }
}
