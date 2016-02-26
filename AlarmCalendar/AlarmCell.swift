//
//  AlarmCell.swift
//  AlarmCalendar
//
//  Created by denis lavrov on 24/02/16.
//  Copyright © 2016 bahus. All rights reserved.
//

import UIKit

class AlarmCell: UITableViewCell {
	@IBOutlet weak var dateLabel: UILabel!
	@IBOutlet weak var timeLabel: UILabel!
	@IBOutlet weak var label: UILabel!
	@IBOutlet weak var enabledSwitch: UISwitch!
    var alarm: Alarm? = nil

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
