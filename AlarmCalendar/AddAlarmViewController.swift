//
//  AddAlarmViewController.swift
//  AlarmCalendar
//
//  Created by denis lavrov on 25/02/16.
//  Copyright © 2016 bahus. All rights reserved.
//

import UIKit

class AddAlarmViewController: UIViewController, MultiSelectSegmentedControlDelegate {
    
    @IBOutlet weak var repeatControl: MultiSelectSegmentedControl!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var alarmTitle: UITextField!
    @IBOutlet weak var navBar: UINavigationItem!
    
    var alarm: Alarm? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        repeatControl.delegate = self
        // Do any additional setup after loading the view.
        if alarm != nil {
            navBar.title = "Edit Alarm"
            datePicker.date = alarm!.date
            alarmTitle.text = alarm!.title
            repeatControl.selectedSegmentIndexes = makeIndexSet(alarm!.repeatedDays)
        }
    }
    
    func multiSelect(multiSelecSegmendedControl: MultiSelectSegmentedControl!, didChangeValue value: Bool, atIndex index: UInt) {
        if repeatControl.selectedSegmentIndexes.count > 0 {
            datePicker.datePickerMode = .Time
            datePicker.minuteInterval = 5
        } else {
            datePicker.datePickerMode = .DateAndTime
            datePicker.minuteInterval = 5
        }
    }
    
    func makeIndexSet(from: [Int]) -> NSIndexSet{
        let indexSet = NSMutableIndexSet()
        for i in from{
            indexSet.addIndex(i)
        }
        return NSIndexSet(indexSet: indexSet)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (sender as? UIBarButtonItem == doneButton) {
            let selectedRepeats = repeatControl.selectedSegmentIndexes
            var willRepeat = false
            if selectedRepeats.count > 0 {
                willRepeat = true
            }
            let alarm1 = Alarm(date: datePicker.date, isRepeated: willRepeat)
            if selectedRepeats.count > 0 {
                alarm1.repeatedDays = selectedRepeats.sort()
            }
            alarm1.title = alarmTitle.text
            if (alarm != nil){
                alarm1.id = alarm!.id
            }
			AlarmManager.addAlarm(alarm1)
        }
    }
    
    
}
