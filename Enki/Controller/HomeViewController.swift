import UIKit

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  @IBOutlet var table: UITableView!
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return DecksStorage.shared.getAll().count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "DeckCell", for: indexPath) as! DeckCellView
    let deck = DecksStorage.shared.get(id: indexPath.row)
    cell.nameLabel.text = String(deck.name)
    cell.newLabel.text = String(deck.new.count)
    cell.learnLabel.text = String(deck.learn.count)
    cell.dueLabel.text = String(deck.due.count)
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let viewController = storyboard.instantiateViewController(withIdentifier: "GameViewController") as! GameViewController
    viewController.deck = DecksStorage.shared.get(id: indexPath.row)
    viewController.modalPresentationStyle = .fullScreen
    self.present(viewController, animated: true)
  }
  
  @IBAction func createDeck() {
    var alert = UIAlertController(title: "New deck name:", message: nil, preferredStyle: .alert)
    alert.addTextField() { (textField) -> Void in
      textField.placeholder = "Name"
    }
    
    alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak alert] (action) -> Void in
      let textField = alert!.textFields![0] as UITextField
      guard let name = textField.text else {
        return
      }
      DecksStorage.shared.put(deck: Deck(name: name, cards: [], scheduler: SM2_Scheduler()))
      self.table.reloadData()
    })
    
    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
    
    self.present(alert, animated: true)
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard segue.identifier == "toAddCardViewController" else { return }
    let destination = segue.destination as! AddCardViewController
    destination.callback = {
      self.table.reloadData()
    }
  }
  
  func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    
    let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, sourceView, completionHandler) in
      DecksStorage.shared.remove(id: indexPath.row)
      completionHandler(true)
      self.table.reloadData()
    }
    
    let editAction = UIContextualAction(style: .normal, title: "Edit") { (action, sourceView, completion) in
      let storyboard = UIStoryboard(name: "Main", bundle: nil)
      let viewController = storyboard.instantiateViewController(withIdentifier: "EditDeckViewController") as! EditDeckViewController
      viewController.deck = DecksStorage.shared.get(id: indexPath.row)
      self.present(viewController, animated: true)
    }
    
    let swipeActionConfiguration = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
    return swipeActionConfiguration
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    table.reloadData()
  }
  
  @IBAction func resetDecks() {
    DecksStorage.shared.reset()
    DecksStorage.shared.save()
    table.reloadData()
  }
  
}
