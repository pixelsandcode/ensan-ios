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
	@IBOutlet weak var buttonContainerBottomConst: NSLayoutConstraint!
	
	var enteredPin = ""
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// game is on ...
		
		self.backContainer.isUserInteractionEnabled = true
		let backTGR = UITapGestureRecognizer(target: self, action: #selector(self.back))
		self.backContainer.addGestureRecognizer(backTGR)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		self.registerForKeyboardNotifications()
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		self.deregisterFromKeyboardNotifications()
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
		
		if !Reachability.connectedToNetwork() {
			Helpers.alertWithTitle(self, title: MainStrings.error, message: MainStrings.networkError)
			return
		}
		
		Helpers.showLoading()
		Alamofire.request(ApiRouter.Router.verifyPin(pin: self.enteredPin)).log().validate().responseObject() {
			
			(response: DataResponse<User>) in
			Helpers.hideLoading()
			if response.result.isSuccess {
				let _ = Helpers.getAndSaveToken(response: response.response!)
				let user = response.result.value
				if let user = user {
				UserInfo.setUsername(user.name)
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
			} else if response.response?.statusCode == 403 {
				self.alertWithTitle(self, title: MainStrings.error, message: MainStrings.wrongPin)
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
	
	// MARK: - Keyboard Helpers
	func registerForKeyboardNotifications() {
		//Adding notifies on keyboard appearing
		NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardNotification(_:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
	}
	
	func deregisterFromKeyboardNotifications() {
		//Removing notifies on keyboard appearing
		NotificationCenter.default.removeObserver(self)
	}
	
	func keyboardNotification(_ notification: Foundation.Notification) {
		if let userInfo = notification.userInfo {
			let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
			let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
			let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
			let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions().rawValue
			let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
			if let endFrameHeight = endFrame?.origin.y, endFrameHeight >= UIScreen.main.bounds.size.height {
				self.buttonContainerBottomConst?.constant = 0.0
			} else {
				self.buttonContainerBottomConst?.constant = endFrame!.size.height
			}
			UIView.animate(withDuration: duration,
										 delay: TimeInterval(0),
										 options: animationCurve,
										 animations: { self.view.layoutIfNeeded() },
										 completion: nil)
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
