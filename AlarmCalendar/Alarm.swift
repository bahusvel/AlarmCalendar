//
//  Alarm.swift
//  AlarmCalendar
//
//  Created by denis lavrov on 24/02/16.
//  Copyright © 2016 bahus. All rights reserved.
//

import Foundation

class Alarm{
	let date: NSDate
	let isRepeated: Bool
	var title: String?
	
	init(date: NSDate, isRepeated: Bool){
		self.date = date
		self.isRepeated = isRepeated
	}
	
}