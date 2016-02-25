//
//  ViewController.swift
//  AlarmCalendar
//
//  Created by denis lavrov on 24/02/16.
//  Copyright © 2016 bahus. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
	var alarms = [Alarm]()
	let cellIdentifier = "alarmCell"
	
	func sampleAlarms(number: Int){
		for _ in 0..<number{
			alarms.append(Alarm(date: NSDate(), isRepeated: false))
		}
	}
    
    func addAlarm(alarm: Alarm){
        alarms.append(alarm)
        scheduleAlarm(alarm)
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
        checkNotificationSettings()
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return alarms.count
	}
	
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! AlarmCell
		let alarm = alarms[indexPath.row]
		let dateFormatter = NSDateFormatter()
		dateFormatter.dateFormat = "dd/MM"
		let timeFormatter = NSDateFormatter()
		timeFormatter.dateFormat = "hh:mm"
		
		cell.dateLabel.text = dateFormatter.stringFromDate(alarm.date)
		cell.timeLabel.text = timeFormatter.stringFromDate(alarm.date)
		
		return cell
	}

}

