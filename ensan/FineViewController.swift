//
//  FineViewController.swift
//  ensan
//
//  Created by Ashkan Hesaraki on 31/12/17.
//  Copyright © 2017 Ashkan Hesaraki. All rights reserved.
//

import UIKit

class FineViewController: UIViewController {
	
	@IBOutlet weak var descriptionLabel: UILabel!
	@IBOutlet weak var fineImageView: UIImageView!
	
	// MARK: - Lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Game is on ...
		let guardiansCount = UserInfo.getGuardians().filter({$0.state == "joined"}).count
		self.descriptionLabel.text = "\(guardiansCount) \(MainStrings.notifiedFine)"
	}
	
	@IBAction func imageTapped(_ sender: Any) {
		guard let _ = (navigationController?.popViewController(animated: true)) else {
			dismiss(animated: true, completion: nil)
			return
		}
	}
}
