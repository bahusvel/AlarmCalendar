//
//  Alarm.swift
//  AlarmCalendar
//
//  Created by denis lavrov on 24/02/16.
//  Copyright © 2016 bahus. All rights reserved.
//

import Foundation

struct AlarmPropertyKey{
    static let dateKey = "date"
    static let repeatedKey = "repeated"
    static let titleKey = "title"
    static let idKey = "id"
}

class Alarm: NSObject, NSCoding{
	let date: NSDate
	let isRepeated: Bool
    var id: Int32
	var title: String?
	
	init(date: NSDate, isRepeated: Bool){
		self.date = date
		self.isRepeated = isRepeated
        self.id = rand()
	}
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(date, forKey: AlarmPropertyKey.dateKey)
        aCoder.encodeBool(isRepeated, forKey: AlarmPropertyKey.repeatedKey)
        aCoder.encodeObject(title, forKey: AlarmPropertyKey.titleKey)
        aCoder.encodeInt(id, forKey: AlarmPropertyKey.idKey)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let date = aDecoder.decodeObjectForKey(AlarmPropertyKey.dateKey) as! NSDate
        let isRepeated = aDecoder.decodeBoolForKey(AlarmPropertyKey.repeatedKey)
        let title = aDecoder.decodeObjectForKey(AlarmPropertyKey.titleKey) as? String
        self.init(date: date, isRepeated: isRepeated)
        self.title = title
        let id = aDecoder.decodeInt32ForKey(AlarmPropertyKey.idKey)
        self.id = id
    }
}