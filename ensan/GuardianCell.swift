//
//  GuardianCell.swift
//  ensan
//
//  Created by Ashkan Hesaraki on 31/12/17.
//  Copyright © 2017 Ashkan Hesaraki. All rights reserved.
//

import UIKit

class GuardianCell: UITableViewCell {
	
	@IBOutlet weak var statusImageView: UIImageView!
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var mobileLabel: UILabel!
	@IBOutlet weak var statusLabel: UILabel!
	
	override func awakeFromNib() {
		super.awakeFromNib()
		// Initialization code
	}
	
	override func setSelected(_ selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
		
		// Configure the view for the selected state
	}
}
