//
//  Alarm.swift
//  AlarmCalendar
//
//  Created by denis lavrov on 24/02/16.
//  Copyright © 2016 bahus. All rights reserved.
//

import Foundation
import UIKit

struct AlarmPropertyKey{
    static let dateKey = "date"
    static let repeatedKey = "repeated"
    static let titleKey = "title"
    static let idKey = "id"
}

class AlarmManager{
	static let documentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
	static let archiveURL = documentsDirectory.URLByAppendingPathComponent("alarms")
	static var alarms = [Alarm]()
	static var repeatedAlarms = [Alarm]()
	
	static func saveAlarms(){
		sortAlarms()
		let allAlarms = ["scheduled": AlarmManager.alarms, "repeated": AlarmManager.repeatedAlarms]
		let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(allAlarms, toFile: AlarmManager.archiveURL.path!)
		if !isSuccessfulSave {
			print("Failed to save Alarms")
		}
		scheduleAlarms()
	}
	
	static func loadAlarms(){
		if let allAlarms = NSKeyedUnarchiver.unarchiveObjectWithFile(AlarmManager.archiveURL.path!) as? [String: [Alarm]]{
			AlarmManager.alarms = allAlarms["scheduled"]!
			AlarmManager.repeatedAlarms = allAlarms["repeated"]!
		}
		sortAlarms()
	}
	
	static func sortAlarms(){
		AlarmManager.alarms.sortInPlace({(a, b) -> Bool in a.date.compare(b.date) == NSComparisonResult.OrderedAscending})
	}
	
	static func addAlarm(alarm: Alarm){
		if alarm.isRepeated {
			AlarmManager.addOrReplace(alarm, alarmType: .REPEATED)
		} else {
			AlarmManager.addOrReplace(alarm, alarmType: .SCHEDULED)
		}
		saveAlarms()
	}
	
	static func scheduleAlarms(){
		let application = UIApplication.sharedApplication()
		application.cancelAllLocalNotifications()
		for alarm in AlarmManager.alarms{
			let notification = UILocalNotification()
			notification.fireDate = alarm.date
			notification.alertTitle = "Alarm"
			let dateFormatter = NSDateFormatter()
			dateFormatter.dateFormat = "dd/MM hh:mm"
			notification.alertBody = dateFormatter.stringFromDate(alarm.date)
			notification.alertAction = "Dismiss"
			notification.soundName = "AlarmBell.caf"
			notification.category = "ALARM_CATEGORY"
			application.scheduleLocalNotification(notification)
		}
	}
	
	static func clearExpiredAlarms(){
		AlarmManager.alarms = AlarmManager.alarms.filter({(alarm) -> Bool in alarm.date.compare(NSDate()) == NSComparisonResult.OrderedDescending})
		AlarmManager.saveAlarms()
	}
	
	static func addOrReplace(alarm: Alarm, alarmType: AlarmType){
		deleteAlarm(alarm, alarmType: alarmType)
		switch alarmType{
		case .REPEATED:
			AlarmManager.repeatedAlarms.append(alarm)
		case .SCHEDULED:
			AlarmManager.alarms.append(alarm)
		}
		AlarmManager.saveAlarms()
	}
	
	static func deleteAlarm(delete: Alarm, alarmType: AlarmType){
		var from: [Alarm]? = nil
		switch alarmType{
		case .REPEATED:
			from = AlarmManager.repeatedAlarms
		case .SCHEDULED:
			from = AlarmManager.alarms
		}
		from = from!.filter({ (alarm1) -> Bool in
			alarm1.id != delete.id
		})
		switch alarmType{
		case .REPEATED:
			AlarmManager.repeatedAlarms = from!
		case .SCHEDULED:
			AlarmManager.alarms = from!
		}
		AlarmManager.saveAlarms()
	}
	
	static func clearAll(){
		do {
			try NSFileManager().removeItemAtPath(AlarmManager.archiveURL.path!)
			AlarmManager.alarms = []
			AlarmManager.repeatedAlarms = []
		} catch{
			
		}
	}
}

enum AlarmType{
	case SCHEDULED
	case REPEATED
}

class Alarm: NSObject, NSCoding{
	let date: NSDate
	let isRepeated: Bool
    var id: Int32
	var title: String?
	
	init(date: NSDate, isRepeated: Bool){
		self.date = date
		self.isRepeated = isRepeated
		self.id = Int32(bitPattern: arc4random())
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