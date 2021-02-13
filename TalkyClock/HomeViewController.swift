//
//  ViewController.swift
//  TalkyClock
//
//  Created by nav brar on 10/2/21.
//  Copyright © 2021 nav brar. All rights reserved.
//

import UIKit
import Foundation
import AudioToolbox
import AVFoundation
import UserNotifications
import EventKitUI


class HomeViewController: UIViewController, AVAudioPlayerDelegate, UITableViewDelegate, UITableViewDataSource {
    

        @IBOutlet weak var topLeftButton: UIBarButtonItem!
        @IBOutlet weak var lbl_Time: UILabel!
        @IBOutlet weak var lbl_Seconds: UILabel!
        @IBOutlet weak var lbl_DayNight: UILabel!
        @IBOutlet weak var view_DayNight: UIView!
        @IBOutlet weak var alarmsButton: UIButton!
        @IBOutlet weak var tableView: UITableView!
        var alarmModel: Alarms = Alarms()
        var reminderDate = Date()
        var repeatWeekdays: [Int] = [1,2,3,4,5,6,7]
        let alarm_time_array = ["00:00:00","01:30:00","12:05:00","14:01:00","20:29:00","21:00:00"]

        let alarmCellIdentifier = "alarmCell"
        var timer: Timer?
        var showSeconds = true
        var changeto24HrsFormat = true
        var isFromNotificationDelegate = false
        var isSnooze: Bool = false
        var soundName: String = ""
        var index: Int = -1
        var audioStr = ""
        var voiceRecorededStr = ""
        var isFeatureEnabled = false
        var repeatSet = false
  
        var notification : UNNotification!
        let formatter: DateFormatter = {
            let tmpFormatter = DateFormatter()
            tmpFormatter.dateFormat = "h:mm:ss a"
            return tmpFormatter
        }()
        
        let fullDayformatter: DateFormatter = {
            let tmpFormatter = DateFormatter()
            tmpFormatter.dateFormat = "HH:mm:ss"
            return tmpFormatter
        }()

     override func viewDidLoad() {
            super.viewDidLoad()
            self.allowNotificationPermission()
            let notificationCenter = NotificationCenter.default
            notificationCenter.addObserver(self, selector: #selector(alarmNotificationRecived), name: Notification.Name("Alarm Notification Recived"), object: nil)
        lbl_Time.text = ""
        lbl_Seconds.text = ""
        lbl_DayNight.text = ""
        self.topLeftButton.isEnabled = false
        self.topLeftButton.tintColor    = UIColor.clear
        self.topLeftButton.customView?.isHidden = true
        alarmsButton.isHidden = false
        view_DayNight.isHidden = false
        tableView.isHidden = true

        self.alarmModel.alarms.removeAll()
        if alarmModel.alarms.count == 0
        {
            self.saveAlarms()
        }

        self.tableView.reloadData()
//            tableView.allowsSelectionDuringEditing = true
        }
        
        @objc func alarmNotificationRecived(notificaiont: Notification) {
            self.applicationDidBecomeActive()
        }

      func applicationDidBecomeActive() {
        }
        
        override func viewWillAppear(_ animated: Bool) {
            self.navigationController?.setNavigationBarHidden(false, animated: animated)
            self.title = "Talking Clock"
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.getTimeOfDate), userInfo: nil, repeats: true)
        }
        
        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            timer?.invalidate()
        }
    @objc func getTimeOfDate() {
           let curDate = Date()
           
           var currentTime = ""
           
           if let isShowSec = UserDefaults.standard.value(forKey: "Show Seconds") {
               showSeconds = isShowSec as! Bool
           }
           
           if let change24HrsFormat = UserDefaults.standard.value(forKey: "Change 24 hrs Format") {
               changeto24HrsFormat = change24HrsFormat as! Bool
           }
           
           if showSeconds{
               self.lbl_Seconds.isHidden = false
           }else{
               self.lbl_Seconds.isHidden = true
           }
           if changeto24HrsFormat{
               self.view_DayNight.isHidden = true
               currentTime = fullDayformatter.string(from: curDate)
               let currentTimeStr = currentTime.components(separatedBy: ":")
               self.lbl_Time.text = "\(currentTimeStr[0]):\(currentTimeStr[1])"
               self.lbl_Seconds.text = "\(currentTimeStr[2])"
               self.lbl_DayNight.text = ""
           }else{
               self.view_DayNight.isHidden = false
               currentTime = formatter.string(from: curDate)
               let currentTimeStr = currentTime.components(separatedBy: ":")
               let currentDayNight = currentTimeStr.last!.components(separatedBy: " ")
               self.lbl_Time.text = "\(currentTimeStr[0]):\(currentTimeStr[1])"
               self.lbl_Seconds.text = "\(currentDayNight[0])"
               self.lbl_DayNight.text = "\(currentDayNight.last!.uppercased())"
           }
        let currentTimeStr = currentTime.components(separatedBy: ":")
        let time = "\(currentTimeStr[0]):\(currentTimeStr[1]):\(currentTimeStr[2])"

        var timeStr = ""
        print(time)
        if alarm_time_array .contains(time)
        {
            print("SAME TIME SPEAK")

            let currentTimeSpell = formatter.string(from: curDate)
            let currentTimeForSpellStr = currentTimeSpell.components(separatedBy: ":")
            let currentDayNightSpell = currentTimeForSpellStr.last!.components(separatedBy: " ")
            
            let Hrs = Int("\(currentTimeForSpellStr[0])") ?? 0
            let minutes = Int("\(currentTimeForSpellStr[1])") ?? 0
            let amOrPm = "\(currentDayNightSpell.last!.uppercased())"
            
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = NumberFormatter.Style.spellOut
            let spellOutHrsText = numberFormatter.string(for: Hrs)!
            let spellOutMinutesText = numberFormatter.string(for: minutes)!
            var timeSpelloutText = ""
            if minutes == 0
            {
                timeSpelloutText = "\(spellOutHrsText)"
            }
            else if minutes < 10
            {
                timeSpelloutText = "\(spellOutHrsText) oh \(spellOutMinutesText)"
            }
            else{
                timeSpelloutText = "\(spellOutHrsText) \(spellOutMinutesText)"
            }
            timeStr = "It's \(timeSpelloutText) \(amOrPm)"
            print(timeStr) // prints: two thousand eighteen

        }
//        switch time {
//        case "00:00:00":
//            timeStr = "It's twelve am"
//        case "01:30:00":
//            timeStr = "It's one thirty am"
//        case "12:05:00":
//            timeStr = "It's twelve oh five pm"
//        case "14:01:00":
//            timeStr = "It's two oh one pm"
//        case "20:29:00":
//            timeStr = "It's eight twenty nine pm"
//        case "21:00:00":
//            timeStr = "It's nine pm"
//        default:
//            return
//        }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers, .allowAirPlay])
            print("Playback OK")
            try AVAudioSession.sharedInstance().setActive(true)
            print("Session is Active")
        } catch {
            print(error)
        }
        
        let utterance = AVSpeechUtterance(string: timeStr)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-GB")
        utterance.rate = 0.4

        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speak(utterance)
       }
    @objc func saveAlarms(){
        
        let date = Date()
        let tmpFormatter = DateFormatter()
        tmpFormatter.dateFormat = "yyyy-MM-dd'"
        let currentDate = tmpFormatter.string(from: date)
        var isoDate = "2021-02-11 00:00:00"
    
        for timeValue in alarm_time_array
        {
            let lbl_DayNight = "\(currentDate) \(timeValue)"
            isoDate = lbl_DayNight
            // Convert String to Date
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            dateFormatter.dateFormat = "yyyy-MM-dd' 'HH:mm:ss"
            let date1 = dateFormatter.date(from:isoDate)!

            reminderDate = date1
            var tempAlarm = Alarm()
            tempAlarm.date = reminderDate
            tempAlarm.enabled = true
            tempAlarm.snoozeEnabled = false
            tempAlarm.repeatWeekdays = repeatWeekdays
            tempAlarm.uuid = UUID().uuidString
            tempAlarm.onSnooze = false
            alarmModel.alarms.append(tempAlarm)
        }
        self.tableView.reloadData()
        self.navigationController?.popViewController(animated: true)
    }
    
    func allowNotificationPermission(){
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                print("All set!")
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
    }
      @IBAction func alarmListTapped(_ sender: Any) {
            if tableView.isHidden == true {
                tableView.isHidden = false
                self.topLeftButton.isEnabled = true
                self.topLeftButton.customView?.isHidden = false
            }else{
                tableView.isHidden = true
                self.topLeftButton.isEnabled = false
                self.topLeftButton.customView?.isHidden = true
            }
    }
    @IBAction func topLeftButtonTapped(_ sender: Any) {
        tableView.isHidden = true
        self.topLeftButton.isEnabled = false
        self.topLeftButton.customView?.isHidden = true
    }
}

extension HomeViewController {
    // MARK: - Table view data source
    
     func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
     func numberOfSections(in tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        if alarmModel.count == 0 {
            tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        }
        else {
            tableView.separatorStyle = UITableViewCell.SeparatorStyle.singleLine
        }
        return alarmModel.count
    }
    
    
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: self.alarmCellIdentifier)
        if (cell == nil) {
            cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: self.alarmCellIdentifier)
        }
        //cell text
        cell!.selectionStyle = .none
        cell!.tag = indexPath.row
        let alarm: Alarm = alarmModel.alarms[indexPath.row]
        let amAttr: [NSAttributedString.Key : Any] = [NSAttributedString.Key(rawValue: NSAttributedString.Key.font.rawValue) : UIFont.systemFont(ofSize: 20.0)]
        let str = NSMutableAttributedString(string: alarm.formattedTime, attributes: amAttr)
        let timeAttr: [NSAttributedString.Key : Any] = [NSAttributedString.Key(rawValue: NSAttributedString.Key.font.rawValue) : UIFont.systemFont(ofSize: 45.0)]
        str.addAttributes(timeAttr, range: NSMakeRange(0, str.length-2))

        if alarm.featureEnabled{
            let imageAttachment =  NSTextAttachment()
            imageAttachment.image = #imageLiteral(resourceName: "initialRed")
            let imageOffsetY:CGFloat = -20;
            imageAttachment.bounds = CGRect(x: 0, y: imageOffsetY, width: 30, height: 30)
            let attachmentString = NSAttributedString(attachment: imageAttachment)

            str.append(attachmentString)
        }
        cell!.textLabel?.attributedText = str
        if alarm.enabled {
            appDelegate.alarmSet = true
            cell!.backgroundColor = UIColor.white
            cell!.textLabel?.alpha = 1.0
            cell!.detailTextLabel?.alpha = 1.0
        } else {
            cell!.backgroundColor = UIColor.systemGroupedBackground
            cell!.textLabel?.alpha = 0.5
            cell!.detailTextLabel?.alpha = 0.5
        }
        //delete empty seperator line
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        return cell!
    }
}
extension UIViewController {
    var appDelegate: AppDelegate {
    return UIApplication.shared.delegate as! AppDelegate
   }
}
