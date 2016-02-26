//
//  AddAlarmViewController.swift
//  AlarmCalendar
//
//  Created by denis lavrov on 25/02/16.
//  Copyright © 2016 bahus. All rights reserved.
//

import UIKit

class AddAlarmViewController: UIViewController {
    
    @IBOutlet weak var repeatControl: UISegmentedControl!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var alarmTitle: UITextField!
    @IBOutlet weak var navBar: UINavigationItem!
    
    var alarm: Alarm? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if alarm != nil {
            navBar.title = "Edit Alarm"
            datePicker.date = alarm!.date
            alarmTitle.text = alarm!.title
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (sender as? UIBarButtonItem == doneButton) {
            let alarm1 = Alarm(date: datePicker.date, isRepeated: false)
            alarm1.title = alarmTitle.text
            if (alarm != nil){
                alarm1.id = alarm!.id
            }
            let mainViewController = segue.destinationViewController as? ViewController
            mainViewController!.addAlarm(alarm1)
        }
    }
    
    
}
