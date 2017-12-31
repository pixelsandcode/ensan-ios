//
//  MainViewController.swift
//  ensan
//
//  Created by Ashkan Hesaraki on 30/12/17.
//  Copyright © 2017 Ashkan Hesaraki. All rights reserved.
//

import UIKit
import MessageUI
import ContactsUI

class MainViewController: UIViewController {
	
	@IBOutlet var mainView: UIView!
	@IBOutlet weak var plusButton: UIImageView!
	@IBOutlet weak var mainTitleLabel: UILabel!
	@IBOutlet weak var mainSubtitleLabel: UILabel!
	@IBOutlet weak var closeFriendListLabel: UILabel!
	@IBOutlet weak var closeFriendHintLabel: UILabel!
	@IBOutlet weak var viewImage: UIImageView!
	@IBOutlet weak var hurtImage: UIImageView!
	@IBOutlet weak var fineImage: UIImageView!
	@IBOutlet weak var actionContainer: UIStackView!
	
	var pickedContacts: [String: String] = [:]
	
	// MARK: - Lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Game is on...
		// TODO: Delete after test
		self.setupButtons()
		var a : [String: String] = [:]
		a.updateValue("09125277448", forKey: "Ashkan")
		a.updateValue("09125277448", forKey: "Keyvan")
		a.updateValue("09125277448", forKey: "Arash")
		UserInfo.setGuardians(a)
		self.handleByGuardians()
	}
	
	// MARK: - Actions
	func plusTapped() {
		self.selectContact()
	}
	
	func viewGuardianTapped() {
		self.performSegueWithIdentifier(segueIdentifier: .showGuardians, sender: self)
	}
	
	func showFine() {
		self.performSegueWithIdentifier(segueIdentifier: .showFine, sender: self)
	}
	
	func showHurt() {
		self.performSegueWithIdentifier(segueIdentifier: .showHurt, sender: self)
	}
	
	// MARK: - Message
	func configuredMessageComposeViewController(_ phoneNumbers: [String]) -> MFMessageComposeViewController {
		let messageComposeVC = MFMessageComposeViewController()
		messageComposeVC.messageComposeDelegate = self
		messageComposeVC.recipients = phoneNumbers
		messageComposeVC.body = "\(MainStrings.addGuardianText) \(MainStrings.appLink)"
		return messageComposeVC
	}
	
	func sendMessage(_ numbers: [String]) {
		let messageComposeVC = self.configuredMessageComposeViewController(numbers)
		self.present(messageComposeVC, animated: true, completion: nil)
	}
	
	// MARK: - Contacts
	func selectContact() {
		let contactPicker = CNContactPickerViewController()
		contactPicker.delegate = self
		present(contactPicker, animated: true, completion: nil)
	}
	
	// MARK: - Buttons
	func setupButtons() {
		self.plusButton.isUserInteractionEnabled = true
		let plusTGR = UITapGestureRecognizer(target: self, action: #selector(self.plusTapped))
		self.plusButton.addGestureRecognizer(plusTGR)
		
		self.viewImage.isUserInteractionEnabled = true
		let viewTGR = UITapGestureRecognizer(target: self, action: #selector(self.viewGuardianTapped))
		self.viewImage.addGestureRecognizer(viewTGR)
		
		self.fineImage.isUserInteractionEnabled = true
		let fineTGR = UITapGestureRecognizer(target: self, action: #selector(self.showFine))
		self.fineImage.addGestureRecognizer(fineTGR)
		
		self.hurtImage.isUserInteractionEnabled = true
		let hurtTGR = UITapGestureRecognizer(target: self, action: #selector(self.showHurt))
		self.hurtImage.addGestureRecognizer(hurtTGR)
	}
	
	@IBAction func viewAddedGuardiansTapped(_ sender: Any) {
		self.viewGuardianTapped()
	}
	
	
	// MARK: - Handle Guardians
	func handleByGuardians() {
		let guardiansCount = UserInfo.getGuardians().count
		self.viewImage.isHidden = false
		self.closeFriendListLabel.isHidden = false
		self.mainTitleLabel.isHidden = false
		self.mainSubtitleLabel.isHidden = false
		self.actionContainer.isHidden = true
		switch guardiansCount {
		case 0:
			self.mainView.backgroundColor = UIColor.dangerRed
			self.viewImage.isHidden = true
			self.closeFriendListLabel.isHidden = true
			self.closeFriendHintLabel.text = MainStrings.dangerFriendListHint
		case 1:
			self.mainView.backgroundColor = UIColor.dangerOrange
			self.closeFriendHintLabel.text = MainStrings.addTwoMore
		case 2:
			self.mainView.backgroundColor = UIColor.dangerBlue
			self.closeFriendHintLabel.text = MainStrings.addOneMore
		case 3:
			self.mainView.backgroundColor = UIColor.safeGreen
			self.closeFriendHintLabel.text = MainStrings.threeAdded
			self.mainTitleLabel.isHidden = true
			self.mainSubtitleLabel.isHidden = true
			self.actionContainer.isHidden = false
		default:
			self.mainView.backgroundColor = UIColor.dangerRed
		}
	}
	
	func showAlreadyAddedAlert(_ number: String) {
		let message = "\(MainStrings.guardianAlreadyAdded): \(number)"
		self.alertWithTitle(self, title: MainStrings.error, message: message)
	}
	
	func alertWithTitle(_ viewController: UIViewController, title: String!, message: String) {
		let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
		let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel) {
			UIAlertAction in
		}
		
		alert.addAction(action)
		viewController.present(alert, animated: true, completion:nil)
	}
}

// MARK: - Navigation
extension MainViewController: SegueHandlerType {
	enum SegueIdentifier: String {
		case showGuardians
		case showFine
		case showHurt
		case showSignUp
	}
}

//MARK: - MFMessageComposerDelegate Method
extension MainViewController: MFMessageComposeViewControllerDelegate {
	func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
		if result == MessageComposeResult.sent {
			controller.dismiss(animated: true) {
				finished in
				
				var guardians = UserInfo.getGuardians()
				guardians.update(other: self.pickedContacts)
				UserInfo.setGuardians(guardians)
				self.handleByGuardians()
				if !UserInfo.isUser() {
					self.performSegueWithIdentifier(segueIdentifier: .showSignUp, sender: self)
				}
			}
		} else {
			controller.dismiss(animated: true) {
				finished in
				
				self.alertWithTitle(self, title: MainStrings.error, message: MainStrings.notSent)
			}
		}
	}
}

//MARK: - CNContactPickerDelegate Method
extension MainViewController: CNContactPickerDelegate {
	func contactPicker(_ picker: CNContactPickerViewController, didSelect contacts: [CNContact]) {
		
		self.pickedContacts = [:]
		for item in contacts {
			pickedContacts.updateValue((item.phoneNumbers.first?.value.stringValue)!, forKey: item.givenName)
			print((item.phoneNumbers.first?.value.stringValue)!)
			print(item.givenName)
		}
		
		print(pickedContacts.debugDescription)
		let guardians = UserInfo.getGuardians()
		
		if guardians.count > 0 {
			for guardian in pickedContacts {
				if guardians.values.contains(guardian.value) {
					picker.dismiss(animated: true, completion: nil)
					self.showAlreadyAddedAlert(guardian.value)
					return
				}
			}
		}
		
		let phoneNumbers = Array(pickedContacts.values)
		let messageComposeVC = self.configuredMessageComposeViewController(phoneNumbers)
		picker.dismiss(animated: true) {
			completed in
			
			self.present(messageComposeVC, animated: true, completion: nil)
		}
	}
	
	func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
		print("contact picker cancelled")
	}
}
