//
//  AppDelegate.swift
//  TalkyClock
// com.nav.TalkyClock
//  Created by nav brar on 10/2/21.
//  Copyright © 2021 nav brar. All rights reserved.
//

import UIKit
import Foundation
import AudioToolbox
import AVFoundation
import UserNotifications
import EventKitUI


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, AVAudioPlayerDelegate, UNUserNotificationCenterDelegate{


    var window: UIWindow?
    var audioPlayer: AVAudioPlayer?
//    let alarmScheduler: AlarmSchedulerDelegate = Scheduler()
//    var alarmModel: Alarms = Alarms()
    
    var timer = Timer()
    let timeInterval:TimeInterval = 2.0
    var workout = false
    var workoutIntervalCount = 5
    var backgroundTask = 0
    var timeElapsed = 0
//    let silentPlayer = SilencePlayer()
    var notification : UNNotification!
    var alarmSet = false

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
            
            if let trailDays = UserDefaults.standard.value(forKey: "Free trail start date") as? Date{
            let interval = Date() - trailDays
             
                if interval.day! > 8 {
                    UserDefaults.standard.set(false, forKey: "Free trail is Taken")
                }else{
                    UserDefaults.standard.set(true, forKey: "Free trail is Taken")
                }
            }
            
            let notificationCenter = NotificationCenter.default
            notificationCenter.addObserver(self, selector: #selector(appMovedToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
            notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
            
            do {
                try AVAudioSession.sharedInstance().setCategory(.playAndRecord, options: [.defaultToSpeaker, .duckOthers])
                print("Playback OK")
                try AVAudioSession.sharedInstance().setActive(true)
                print("Session is Active")
            } catch {
                print(error)
            }
            
            UNUserNotificationCenter.current().delegate = self
            
    //        return ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
            
                    return true
        }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    @objc func appMovedToForeground() {
//        silentPlayer.stop()
        print("App moved to ForeGround!")
    }
    
    @objc func appMovedToBackground() {
        
//        silentPlayer.play()
        print("App moved to Background!")
    }
        func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void)
        {
            if response.notification.request.content.body == "Wake Up!"{
                UNUserNotificationCenter.current().removeAllDeliveredNotifications()
                UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let mainVC = storyboard.instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController
                self.notification = response.notification
                mainVC?.notification = response.notification
                mainVC?.isFromNotificationDelegate = true
                
                let nav = UINavigationController(rootViewController: mainVC!)
                self.window?.rootViewController = nav
                mainVC?.applicationDidBecomeActive()
                completionHandler()
            }
        }
        
        func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
        {
            UNUserNotificationCenter.current().removeAllDeliveredNotifications()
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
//            silentPlayer.stop()
            
            let userInfo = notification.request.content.userInfo
            print("Received notification with ID = \(userInfo)")
            
            var soundName: String = ""
            soundName = userInfo["soundName"] as! String
            
            playSound(soundName)
            self.notification = notification
            completionHandler([.alert,.sound])
        }
        
       func applicationWillTerminate(_ application: UIApplication) {
        
        let content = UNMutableNotificationContent()
        content.title = "Please wait"
        content.subtitle = "Keep the app in background to hear time alerts."
        content.sound = UNNotificationSound.default

        // show this notification five seconds from now
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)

        // choose a random identifier
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        // add our notification request
        UNUserNotificationCenter.current().add(request)
 
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    //receive local notification when app in foreground
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        
        //show an alert window
        UIApplication.shared.cancelAllLocalNotifications()
    }
    
    //snooze notification handler when app in background
    func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, for notification: UILocalNotification, completionHandler: @escaping () -> Void) {
        
        UIApplication.shared.cancelAllLocalNotifications()
        
        
        var index: Int = -1
        var soundName: String = ""
        var feature = false
        if let userInfo = notification.userInfo {
            soundName = userInfo["soundName"] as! String
            index = userInfo["index"] as! Int
            feature = userInfo["FeatureEnable"] as! Bool
        }
        playSound(soundName)
//        self.alarmModel = Alarms()
//        self.alarmModel.alarms[index].onSnooze = false
//        if identifier == Id.snoozeIdentifier {
//            if let snoozeTimeInt = UserDefaults.standard.value(forKey: "Snooze Time"){
//                snoozeTime = snoozeTimeInt as! Int
//            }
//
//            alarmScheduler.setNotificationForSnooze(snoozeMinute: snoozeTime - 1, soundName: soundName, index: index, feature: feature)
//            self.alarmModel.alarms[index].onSnooze = true
//        }
        
        //        applicationDidBecomeActive
        completionHandler()
    }
    
    //print out all registed NSNotification for debug
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        
        print(notificationSettings.types.rawValue)
    }
    
    //AlarmApplicationDelegate protocol
    func playSound(_ soundName: String) {
        
        NotificationCenter.default.post(name: Notification.Name("Alarm Notification Recived"), object: nil)
        //vibrate phone first
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        //        //set vibrate callback
        AudioServicesAddSystemSoundCompletion(SystemSoundID(kSystemSoundID_Vibrate),nil,
                                              nil,
                                              { (_:SystemSoundID, _:UnsafeMutableRawPointer?) -> Void in
                                                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        },
                                              nil)
        let url = URL(fileURLWithPath: Bundle.main.path(forResource: soundName, ofType: "mp3")!)
        
        var error: NSError?
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
        } catch let error1 as NSError {
            error = error1
            audioPlayer = nil
        }
        
        if let err = error {
            print("audioPlayer error \(err.localizedDescription)")
            return
        } else {
            audioPlayer?.prepareToPlay()
        }
        
        //negative number means loop infinity
        //        audioPlayer?.volume = 10.0
        audioPlayer?.numberOfLoops = -1
        audioPlayer?.play()
    }
    
    //AVAudioPlayerDelegate protocol
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        audioPlayer?.play(atTime: 0.0)
        print("Track repeating")
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        
    }

}

extension AppDelegate {
    func startBackgroundTask() {
        NotificationCenter.default.addObserver(self, selector: #selector(interruptedAudio), name: AVAudioSession.interruptionNotification, object: AVAudioSession.sharedInstance())
        self.playSound("Bell")
    }
    
    func stopBackgroundTask() {
        NotificationCenter.default.removeObserver(self, name: AVAudioSession.interruptionNotification, object: nil)
        self.audioPlayer?.pause()
    }
    
    @objc fileprivate func interruptedAudio(_ notification: Notification) {
        if notification.name == AVAudioSession.interruptionNotification && notification.userInfo != nil {
            var info = notification.userInfo!
            var intValue = 0
            (info[AVAudioSessionInterruptionTypeKey]! as AnyObject).getValue(&intValue)
            if intValue == 1 {
                self.playSound("Bell")
                
            }
        }
    }
}

extension AppDelegate {
    func ckeckNotificationRecived() {
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            print("timer running")
            UNUserNotificationCenter.current().getDeliveredNotifications { (alarmNotifications) in
                
                for notification in alarmNotifications{
                    if notification.request.content.body == "Wake Up!"{
                        let userInfo = notification.request.content.userInfo
//                        self.silentPlayer.stop()
                        print("Received notification with ID = \(userInfo)")
                        
                        var soundName: String = ""
                        
                        soundName = userInfo["soundName"] as! String
                        
                        self.notification = notification
                        self.playSound(soundName)
                        timer.invalidate()
                        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
                    }
                }
            }
        }
    }
}
extension Date {

    static func -(recent: Date, previous: Date) -> (month: Int?, day: Int?, hour: Int?, minute: Int?, second: Int?) {
        let day = Calendar.current.dateComponents([.day], from: previous, to: recent).day
        let month = Calendar.current.dateComponents([.month], from: previous, to: recent).month
        let hour = Calendar.current.dateComponents([.hour], from: previous, to: recent).hour
        let minute = Calendar.current.dateComponents([.minute], from: previous, to: recent).minute
        let second = Calendar.current.dateComponents([.second], from: previous, to: recent).second
        return (month: month, day: day, hour: hour, minute: minute, second: second)
    }

}
