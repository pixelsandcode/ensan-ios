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
	@IBOutlet var mainView: UIView!
	
	// MARK: - Lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Game is on ...
		let guardiansCount = UserInfo.getGuardians().filter({$0.state == "joined"}).count
		self.descriptionLabel.text = "\(guardiansCount) \(MainStrings.notifiedFine)"
		let backTGR = UITapGestureRecognizer(target: self, action: #selector(self.back))
		self.mainView.addGestureRecognizer(backTGR)
	}
	
	@IBAction func imageTapped(_ sender: Any) {
		self.back()
	}
}
