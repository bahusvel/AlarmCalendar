//
//  ViewController.swift
//  AlarmCalendar
//
//  Created by denis lavrov on 24/02/16.
//  Copyright © 2016 bahus. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var settingsButton: UIBarButtonItem!
    @IBOutlet weak var addButton: UIBarButtonItem!
    
	var alarms = [Alarm]()
    var repeatedAlarms = [Alarm]()
	static let cellIdentifier = "alarmCell"
    static let documentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    static let archiveURL = documentsDirectory.URLByAppendingPathComponent("alarms")
	
	func sampleAlarms(number: Int){
		for _ in 0..<number{
			alarms.append(Alarm(date: NSDate(), isRepeated: false))
		}
	}
    
    func saveAlarms(){
        let allAlarms = ["scheduled": alarms, "repeated": repeatedAlarms]
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(allAlarms, toFile: ViewController.archiveURL.path!)
        if !isSuccessfulSave {
            print("Failed to save Alarms")
        }
    }
    
    func loadAlarms(){
        if let allAlarms = NSKeyedUnarchiver.unarchiveObjectWithFile(ViewController.archiveURL.path!) as? [String: [Alarm]]{
            alarms = allAlarms["scheduled"]!
            repeatedAlarms = allAlarms["repeated"]!
        }
        sortAlarms()
    }
    
    func sortAlarms(){
        alarms.sortInPlace({(a, b) -> Bool in a.date.compare(b.date) == NSComparisonResult.OrderedAscending})
    }
    
    func addAlarm(alarm: Alarm){
        loadAlarms()
        if !alarm.isRepeated {
            alarms = ViewController.addOrReplace(alarm, alarms: alarms)
        } else {
            repeatedAlarms = ViewController.addOrReplace(alarm, alarms: repeatedAlarms)
        }
        sortAlarms()
        saveAlarms()
        scheduleAlarm(alarm)
    }
    
    static func addOrReplace(alarm: Alarm, alarms: [Alarm]) -> [Alarm]{
		var newAlarms = deleteAlarm(alarm, from: alarms)
        newAlarms.append(alarm)
        return newAlarms
    }
	
	static func deleteAlarm(delete: Alarm, from:[Alarm]) -> [Alarm]{
		return from.filter({ (alarm1) -> Bool in
			alarm1.id != delete.id
		})
	}
	
    func clearExpiredAlarms(){
        alarms = alarms.filter({(alarm) -> Bool in alarm.date.compare(NSDate()) == NSComparisonResult.OrderedDescending})
        saveAlarms()
    }
    
    func checkNotificationSettings(){
        
    }
    
    func scheduleAlarm(alarm: Alarm){
        let notification = UILocalNotification()
        notification.fireDate = alarm.date
        notification.alertTitle = "Alarm"
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd/MM hh:mm"
        notification.alertBody = dateFormatter.stringFromDate(alarm.date)
        notification.alertAction = "Dismiss"
        notification.soundName = "AlarmBell.caf"
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
	
	override func viewDidLoad() {
		super.viewDidLoad()
        let notificationSettings = UIUserNotificationSettings(forTypes: [.Alert, .Sound], categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
		// Do any additional setup after loading the view, typically from a nib.
        loadAlarms()
        clearExpiredAlarms()
        checkNotificationSettings()
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 2
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section{
        case 0:
            return alarms.count
        case 1:
            return repeatedAlarms.count
        default:
            return 0
        }
	}
	
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section{
        case 0:
            return "Scheduled Alarms"
        case 1:
            return "Repeated Alarms"
        default:
            return "Not A section"
        }
    }
    
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier(ViewController.cellIdentifier, forIndexPath: indexPath) as! AlarmCell
        var alarm: Alarm? = nil
        switch indexPath.section{
        case 0:
            alarm = alarms[indexPath.row]
            cell.enabledSwitch.hidden = true
        case 1:
            alarm = repeatedAlarms[indexPath.row]
            cell.enabledSwitch.hidden = false
        default:
            alarm = nil
        }
		let dateFormatter = NSDateFormatter()
		dateFormatter.dateFormat = "dd/MM"
		let timeFormatter = NSDateFormatter()
		timeFormatter.dateFormat = "hh:mm"
		
		cell.dateLabel.text = dateFormatter.stringFromDate(alarm!.date)
		cell.timeLabel.text = timeFormatter.stringFromDate(alarm!.date)
		cell.alarm = alarm
        
		return cell
	}
	
	func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
		if (editingStyle == .Delete) {
			switch indexPath.section{
			case 0:
				alarms = ViewController.deleteAlarm(alarms[indexPath.row], from: alarms)
			case 1:
				repeatedAlarms = ViewController.deleteAlarm(repeatedAlarms[indexPath.row], from: repeatedAlarms)
			default:
				print("Unimplemented Case")
			}
			saveAlarms()
			tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
		}
	}
	
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let cell = sender as? AlarmCell{
            let alarmViewController = segue.destinationViewController as? AddAlarmViewController
            alarmViewController!.alarm = cell.alarm
        } else if let barButton = sender as? UIBarButtonItem {
            if barButton == addButton{
                let alarmViewController = segue.destinationViewController as? AddAlarmViewController
                alarmViewController!.alarm = nil
            }
        }
    }

}

