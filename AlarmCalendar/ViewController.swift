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

	static let cellIdentifier = "alarmCell"
    
    func checkNotificationSettings(){
        
    }
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
        AlarmManager.loadAlarms()
		AlarmManager.clearExpiredAlarms()
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
            return AlarmManager.alarms.count
        case 1:
            return AlarmManager.repeatedAlarms.count
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
            alarm = AlarmManager.alarms[indexPath.row]
        case 1:
            alarm = AlarmManager.repeatedAlarms[indexPath.row]
        default:
            alarm = nil
        }
        cell.initWithAlarm(alarm!)
		return cell
	}
	
	func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
		if (editingStyle == .Delete) {
			switch indexPath.section{
			case 0:
				AlarmManager.deleteAlarm(AlarmManager.alarms[indexPath.row])
			case 1:
				AlarmManager.deleteAlarm(AlarmManager.repeatedAlarms[indexPath.row])
			default:
				print("Unimplemented Case")
			}
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

