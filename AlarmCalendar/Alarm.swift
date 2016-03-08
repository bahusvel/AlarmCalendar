//
//  Alarm.swift
//  AlarmCalendar
//
//  Created by denis lavrov on 24/02/16.
//  Copyright © 2016 bahus. All rights reserved.
//

import UIKit

struct AlarmPropertyKey{
    static let dateKey = "date"
    static let repeatedKey = "repeated"
    static let daysKey = "days"
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
        if alarm.isRepeated{
            AlarmManager.repeatedAlarms.append(alarm)
        } else {
            AlarmManager.alarms.append(alarm)
        }
		saveAlarms()
	}
    
    static func editAlarm(old: Alarm, new: Alarm){
        deleteAlarm(old)
        addAlarm(new)
    }
    
    static func makeNotification(alarm: Alarm) -> UILocalNotification{
        let notification = UILocalNotification()
        notification.fireDate = alarm.date
        notification.alertTitle = alarm.title
        let dateFormatter = NSDateFormatter()
        if !alarm.isRepeated {
            dateFormatter.dateFormat = "dd/MM hh:mm"
        } else {
            dateFormatter.dateFormat = "hh:mm"
            notification.repeatInterval = .WeekOfYear
        }
        notification.alertBody = dateFormatter.stringFromDate(alarm.date)
        notification.alertAction = "Dismiss"
        notification.soundName = "AlarmBell.caf"
        notification.category = "ALARM_CATEGORY"
        return notification
    }
	
    static func getNextDay(weekDay: Int) -> NSDate {
        let weekIndex = (weekDay + 1) % 7 + 1 // convert indexes to weird order calendar
        let today = NSDate()
        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        if calendar.component(.Weekday, fromDate: today) == weekIndex {
            return today
        }
        let nextDateComponent = NSDateComponents()
        nextDateComponent.weekday = weekIndex
        let date = calendar.nextDateAfterDate(today, matchingComponents: nextDateComponent, options: .MatchNextTime)
        return date!
    }
    
    static func setTimeComponent(date: NSDate, time: NSDate) -> NSDate{
        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let dateComponents = calendar.components([.Year, .Month, .Day], fromDate: date)
        let timeComponents = calendar.components([.Hour, .Minute, .Second], fromDate: time)
        dateComponents.hour = timeComponents.hour
        dateComponents.minute = timeComponents.minute
        dateComponents.second = timeComponents.second
        return calendar.dateFromComponents(dateComponents)!
    }
    
	static func scheduleAlarms(){
		let application = UIApplication.sharedApplication()
		application.cancelAllLocalNotifications()
		for alarm in AlarmManager.alarms{
                let notification = makeNotification(alarm)
                application.scheduleLocalNotification(notification)
		}
        for alarm in AlarmManager.repeatedAlarms{
            for day in alarm.repeatedDays{
                let notification = makeNotification(alarm)
                let date = getNextDay(day)
                notification.fireDate = setTimeComponent(date, time: alarm.date)
                /*
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "dd/MM hh:mm"
                print("Scheduling for " + dateFormatter.stringFromDate(notification.fireDate!))
                */
                application.scheduleLocalNotification(notification)
            }
        }
	}
	
	static func clearExpiredAlarms(){
		AlarmManager.alarms = AlarmManager.alarms.filter({(alarm) -> Bool in alarm.date.compare(NSDate()) == NSComparisonResult.OrderedDescending})
		AlarmManager.saveAlarms()
	}
	
	static func deleteAlarm(delete: Alarm){
		var from: [Alarm]? = nil
        if delete.isRepeated {
			from = AlarmManager.repeatedAlarms
        } else {
			from = AlarmManager.alarms
		}
		from = from!.filter({ (alarm1) -> Bool in
			alarm1.id != delete.id
		})
        if delete.isRepeated {
			AlarmManager.repeatedAlarms = from!
        } else {
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
    var repeatedDays = [Int]()
	
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
        aCoder.encodeObject(repeatedDays, forKey: AlarmPropertyKey.daysKey)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let date = aDecoder.decodeObjectForKey(AlarmPropertyKey.dateKey) as! NSDate
        let isRepeated = aDecoder.decodeBoolForKey(AlarmPropertyKey.repeatedKey)
        self.init(date: date, isRepeated: isRepeated)
        self.title = aDecoder.decodeObjectForKey(AlarmPropertyKey.titleKey) as? String
        self.id = aDecoder.decodeInt32ForKey(AlarmPropertyKey.idKey)
        self.repeatedDays = aDecoder.decodeObjectForKey(AlarmPropertyKey.daysKey) as! [Int]
    }
}