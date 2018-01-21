//
//  PinViewController.swift
//  ensan
//
//  Created by Ashkan Hesaraki on 21/1/18.
//  Copyright © 2018 Ashkan Hesaraki. All rights reserved.
//

import UIKit
import Alamofire

class PinViewController: UIViewController {
	
	@IBOutlet weak var backContainer: UIStackView!
	@IBOutlet weak var pinTextField: UITextField!
	
	var enteredPin = ""
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// game is on ...
		
		self.backContainer.isUserInteractionEnabled = true
		let backTGR = UITapGestureRecognizer(target: self, action: #selector(self.back))
		self.backContainer.addGestureRecognizer(backTGR)
	}
	
	func alertWithTitle(_ viewController: UIViewController, title: String!, message: String) {
		let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
		let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel) {
			UIAlertAction in
		}
		
		alert.addAction(action)
		viewController.present(alert, animated: true, completion:nil)
	}
	
	// MARK: - Actions
	@IBAction func sendTapped(_ sender: Any) {
		if !self.isError() {
			self.verifyPin()
		}
	}
	
	func verifyPin() {
		Alamofire.request(ApiRouter.Router.verifyPin(pin: self.enteredPin)).log().validate().responseObject() {
			
			(response: DataResponse<User>) in
			
			if response.result.isSuccess {
				let _ = Helpers.getAndSaveToken(response: response.response!)
				let user = response.result.value
				if let user = user {
					User.saveUser(user)
					self.sendDeviceToken()
					for controller in self.navigationController!.viewControllers as Array {
						if controller.isKind(of: MainViewController.self) {
							self.navigationController!.popToViewController(controller, animated: true)
							break
						}
					}
				}
				
				print(user.debugDescription)
			}
		}
	}
	
	func sendDeviceToken() {
		if UserInfo.isUser() && UserInfo.getNotificationId() != nil {
			Alamofire.request(ApiRouter.Router.registerDevice()).log().validate().responseJSON() {
				response in
				
				if response.result.isSuccess {
					print("notification sent to api")
				} else {
					print(response.result.error.debugDescription)
				}
			}
		}
	}
	
	func isError() -> Bool {
		var error = false
		
		var errorMessage = ""
		self.enteredPin = self.pinTextField.text!
		
		if (self.enteredPin.isEmpty) {
			error = true
			errorMessage = ValidationErrors.fieldRequired
		}
		
		if error {
			self.alertWithTitle(self, title: MainStrings.error, message: errorMessage)
		}
		
		return error
	}
	
	func back() {
		guard let _ = (navigationController?.popViewController(animated: true)) else {
			dismiss(animated: true, completion: nil)
			return
		}
	}
}

// MARK: - TextField Delegate
extension PinViewController: UITextFieldDelegate {
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		self.view.endEditing(true)
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		if textField == self.pinTextField {
			if !self.isError() {
				self.verifyPin()
			}
		}
		
		return true
	}
}
