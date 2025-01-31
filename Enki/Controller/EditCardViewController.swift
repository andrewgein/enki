//
//  EditCardViewController.swift
//  Enki
import UIKit

class EditCardViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  @IBOutlet var frontSideView: UITextView!
  @IBOutlet var backSideView: UITextView!
  var card: Card!
  var deck: Deck!
  var complition: (() -> Void)?
  var selectedSideView: UITextView?
  var selectedSide: NSMutableAttributedString?
  
  override func viewDidLoad() {
    frontSideView.attributedText = NSMutableAttributedString(card.front)
    frontSideView.textColor = UIColor(named: "FontColor")
    backSideView.attributedText = NSMutableAttributedString(card.back)
    backSideView.textColor = UIColor(named: "FontColor")
  }
  
  @IBAction func addImage() {
    let picker = UIImagePickerController()
    picker.delegate = self
    if(frontSideView.isFirstResponder) {
      selectedSideView = frontSideView
      selectedSide = NSMutableAttributedString(card.front)
    } else if (backSideView.isFirstResponder) {
      selectedSideView = backSideView
      selectedSide = NSMutableAttributedString(card.back)
    }
    present(picker, animated: true)
  }
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    guard let image = info[.originalImage] as? UIImage else { return }
    let oldWidth = image.size.width
    let scale = oldWidth / (frontSideView.frame.size.width - 70);
    let scaledImage = UIImage(cgImage: image.cgImage!, scale: scale, orientation: .up)
    let imageAttribute = NSAttributedString(attachment: NSTextAttachment(image: scaledImage))
    selectedSide?.insert(imageAttribute, at: selectedSideView!.selectedRange.location)
    selectedSideView?.attributedText = selectedSide!
    picker.dismiss(animated: true)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    card.front = AttributedString(frontSideView.attributedText)
    card.back = AttributedString(backSideView.attributedText)
    DecksStorage.shared.save()
    complition?()
  }
  
  @IBAction func deleteCard() {
    deck.cards.removeAll(where: {$0 == card})
    self.dismiss(animated: true)
  }
  
  @IBAction func done() {
    self.dismiss(animated: true)
  }
  
}
