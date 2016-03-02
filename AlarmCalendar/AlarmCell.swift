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
    
    static func indexesToText(indexes: [Int]) -> String{
        var text = ""
        let lookup = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        for index in indexes {
            text += lookup[index]+", "
        }
        return text.substringToIndex(text.endIndex.advancedBy(-2))
    }
    
    func initWithAlarm(alarm: Alarm){
        self.alarm = alarm
        if alarm.isRepeated {
            enabledSwitch.hidden = false
            dateLabel.hidden = true
            label.text = alarm.title! + ", " + AlarmCell.indexesToText(alarm.repeatedDays)
        } else {
            enabledSwitch.hidden = true
            dateLabel.hidden = false
            label.text = alarm.title! + ", Scheduled"
        }
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd/MM"
        let timeFormatter = NSDateFormatter()
        timeFormatter.dateFormat = "hh:mm"
        dateLabel.text = dateFormatter.stringFromDate(alarm.date)
        timeLabel.text = timeFormatter.stringFromDate(alarm.date)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
