//
//  LGV_Timer_AppDelegate.swift
//  LGV_Timer
//
//  Created by Chris Marshall on 5/24/17.
//  Copyright © 2017 Little Green Viper Software Development LLC. All rights reserved.
//
/* ###################################################################################################################################### */
/**
 */

import UIKit
import WatchConnectivity

var s_g_LGV_Timer_AppDelegatePrefs = LGV_Timer_StaticPrefs.prefs

@UIApplicationMain
/* ###################################################################################################################################### */
/**
 */
class LGV_Timer_AppDelegate: UIResponder, UIApplicationDelegate, WCSessionDelegate {
    // MARK: - Static Calculated Properties
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     This is a quick way to get this object instance (it's a SINGLETON), cast as the correct class.
     */
    static var appDelegateObject: LGV_Timer_AppDelegate {
        get { return UIApplication.shared.delegate as! LGV_Timer_AppDelegate }
    }

    // MARK: - Instance Properties
    /* ################################################################################################################################## */
    var orientationLock = UIInterfaceOrientationMask.all
    var window: UIWindow?
    var currentTimer: LGV_Timer_TimerRuntimeViewController! = nil

    // MARK: - Static Class Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    class func lockOrientation(_ orientation: UIInterfaceOrientationMask) {
        if let delegate = UIApplication.shared.delegate as? LGV_Timer_AppDelegate {
            delegate.orientationLock = orientation
        }
    }
    
    /* ################################################################## */
    /**
     */
    class func lockOrientation(_ orientation: UIInterfaceOrientationMask, andRotateTo rotateOrientation:UIInterfaceOrientation) {
        self.lockOrientation(orientation)
        UIDevice.current.setValue(rotateOrientation.rawValue, forKey: "orientation")
    }
    
    /* ################################################################## */
    /**
     Displays the given error in an alert with an "OK" button.
     
     - parameter inTitle: a string to be displayed as the title of the alert. It is localized by this method.
     - parameter inMessage: a string to be displayed as the message of the alert. It is localized by this method.
     - parameter presentedBy: An optional UIViewController object that is acting as the presenter context for the alert. If nil, we use the top controller of the Navigation stack.
     */
    class func displayAlert(_ inTitle: String, inMessage: String, presentedBy inPresentingViewController: UIViewController! = nil ) {
        DispatchQueue.main.async {
            var presentedBy = inPresentingViewController
            
            if nil == presentedBy {
                if let navController = self.appDelegateObject.window?.rootViewController as? UINavigationController {
                    presentedBy = navController.topViewController
                } else {
                    if let tabController = self.appDelegateObject.window?.rootViewController as? UITabBarController {
                        if let navController = tabController.selectedViewController as? UINavigationController {
                            presentedBy = navController.topViewController
                        } else {
                            presentedBy = tabController.selectedViewController
                        }
                    }
                }
            }
            
            if nil != presentedBy {
                let alertController = UIAlertController(title: inTitle.localizedVariant, message: inMessage.localizedVariant, preferredStyle: .alert)
                
                let okAction = UIAlertAction(title: "BASIC-OK-BUTTON".localizedVariant, style: UIAlertActionStyle.cancel, handler: nil)
                
                alertController.addAction(okAction)
                
                presentedBy?.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    // MARK: - Private Instance Properties
    /* ################################################################################################################################## */
    private var _mySession = WCSession.default()
    
    // MARK: - Internal Instance Calculated Properties
    /* ################################################################################################################################## */
    var session: WCSession {
        get {
            return self._mySession
        }
    }
    
    // MARK: - Internal Instance Methods
    /* ################################################################################################################################## */
    func activateSession() {
        if WCSession.isSupported() && (self._mySession.activationState != .activated) {
            self._mySession.delegate = self
            self.session.activate()
        }
    }

    // MARK: - UIApplicationDelegate Protocol Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    func applicationWillEnterForeground(_ application: UIApplication) {
        self.sendForegroundMessage()
    }
    
    /* ################################################################## */
    /**
     */
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return self.orientationLock
    }

    /* ################################################################## */
    /**
     */
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        self.activateSession()
        return true
    }

    /* ################################################################## */
    /**
     */
    func applicationWillResignActive(_ application: UIApplication) {
        self.sendBackgroundMessage()
        s_g_LGV_Timer_AppDelegatePrefs.savePrefs()
    }

    /* ################################################################## */
    /**
     */
    func applicationDidEnterBackground(_ application: UIApplication) {
        self.sendBackgroundMessage()
        s_g_LGV_Timer_AppDelegatePrefs.savePrefs()
    }
    
    /* ################################################################## */
    /**
     */
    func applicationWillTerminate(_ application: UIApplication) {
        self.sendBackgroundMessage()
        s_g_LGV_Timer_AppDelegatePrefs.savePrefs()
    }
    
    // MARK: - WCSessionDelegate Sender Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    func sendUpdateMessage() {
        if (nil != currentTimer) && (.activated == self.session.activationState) {
            let seconds = currentTimer.currentTimeInSeconds
            let updateMsg = [LGV_Timer_Messages.s_timerListUpdateTimerMessageKey:seconds]
            self.session.sendMessage(updateMsg, replyHandler: nil, errorHandler: nil)
        }
    }
    
    /* ################################################################## */
    /**
     */
    func sendSelectMessage(timerUID: String = "") {
        if .activated == self.session.activationState {
            let selectMsg = [LGV_Timer_Messages.s_timerListSelectTimerMessageKey:timerUID]
            self.session.sendMessage(selectMsg, replyHandler: nil, errorHandler: nil)
        }
    }
    
    /* ################################################################## */
    /**
     */
    func sendStartMessage(timerUID: String) {
        if .activated == self.session.activationState {
            let selectMsg = [LGV_Timer_Messages.s_timerListStartTimerMessageKey:timerUID]
            self.session.sendMessage(selectMsg, replyHandler: nil, errorHandler: nil)
        }
    }
    
    /* ################################################################## */
    /**
     */
    func sendStopMessage(timerUID: String) {
        if .activated == self.session.activationState {
            let selectMsg = [LGV_Timer_Messages.s_timerListStopTimerMessageKey:timerUID]
            self.session.sendMessage(selectMsg, replyHandler: nil, errorHandler: nil)
        }
    }
    
    /* ################################################################## */
    /**
     */
    func sendPauseMessage(timerUID: String) {
        if .activated == self.session.activationState {
            let selectMsg = [LGV_Timer_Messages.s_timerListPauseTimerMessageKey:timerUID]
            self.session.sendMessage(selectMsg, replyHandler: nil, errorHandler: nil)
        }
    }
    
    /* ################################################################## */
    /**
     */
    func sendEndMessage(timerUID: String) {
        if .activated == self.session.activationState {
            let selectMsg = [LGV_Timer_Messages.s_timerListEndTimerMessageKey:timerUID]
            self.session.sendMessage(selectMsg, replyHandler: nil, errorHandler: nil)
        }
    }
    
    /* ################################################################## */
    /**
     */
    func sendResetMessage(timerUID: String) {
        if .activated == self.session.activationState {
            let selectMsg = [LGV_Timer_Messages.s_timerListResetTimerMessageKey:timerUID]
            self.session.sendMessage(selectMsg, replyHandler: nil, errorHandler: nil)
        }
    }
    
    /* ################################################################## */
    /**
     */
    func sendAlarmMessage(timerUID: String) {
        if .activated == self.session.activationState {
            let selectMsg = [LGV_Timer_Messages.s_timerListAlarmMessageKey:timerUID]
            self.session.sendMessage(selectMsg, replyHandler: nil, errorHandler: nil)
        }
    }
    
    /* ################################################################## */
    /**
     */
    func sendActiveTimerMessage(timerUID: String) {
        if .activated == self.session.activationState {
            let selectMsg = [LGV_Timer_Messages.s_timerRequestActiveTimerUIDMessageKey:timerUID]
            self.session.sendMessage(selectMsg, replyHandler: nil, errorHandler: nil)
        }
    }
    
    /* ################################################################## */
    /**
     */
    func sendBackgroundMessage() {
        let selectMsg = [LGV_Timer_Messages.s_timerAppInBackgroundMessageKey:""]
        self.session.sendMessage(selectMsg, replyHandler: nil, errorHandler: nil)
    }
    
    /* ################################################################## */
    /**
     */
    func sendForegroundMessage() {
        let selectMsg = [LGV_Timer_Messages.s_timerAppInForegroundMessageKey:""]
        self.session.sendMessage(selectMsg, replyHandler: nil, errorHandler: nil)
    }
    
    /* ################################################################## */
    /**
     */
    func sendAppStateMessage() {
        if .activated == self.session.activationState {
            self.sendForegroundMessage()
        } else {
            self.sendBackgroundMessage()
        }
    }
    
    // MARK: - WCSessionDelegate Protocol Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    }
    
    /* ################################################################## */
    /**
     */
    func sessionDidBecomeInactive(_ session: WCSession) {
        type(of:self).displayAlert("iOS App: LGV_Timer_AppDelegate.sessionDidBecomeInactive", inMessage: "")
    }
    
    /* ################################################################## */
    /**
     */
    func sessionDidDeactivate(_ session: WCSession) {
        type(of:self).displayAlert("iOS App: LGV_Timer_AppDelegate.sessionDidDeactivate", inMessage: "")
    }
    
    /* ################################################################## */
    /**
     */
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]){
        type(of:self).displayAlert("iOS App: LGV_Timer_AppDelegate.session(_:,didReceiveApplicationContext:)", inMessage: "\(applicationContext)")
    }
    
    /* ################################################################## */
    /**
     */
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        for key in message.keys {
            switch key {
            case    LGV_Timer_Messages.s_timerListHowdyMessageKey:
                var timerArray:[[String:Any]] = []
                var index = 1
                for timer in s_g_LGV_Timer_AppDelegatePrefs.timers {
                    var timerDictionary:[String:Any] = [:]
                    timerDictionary[LGV_Timer_Data_Keys.s_timerDataTimeSetKey] = timer.timeSet
                    timerDictionary[LGV_Timer_Data_Keys.s_timerDataTimeSetWarnKey] = timer.timeSetPodiumWarn
                    timerDictionary[LGV_Timer_Data_Keys.s_timerDataTimeSetFinalKey] = timer.timeSetPodiumFinal
                    timerDictionary[LGV_Timer_Data_Keys.s_timerDataDisplayModeKey] = timer.displayMode.rawValue
                    timerDictionary[LGV_Timer_Data_Keys.s_timerDataUIDKey] = timer.uid
                    timerDictionary[LGV_Timer_Data_Keys.s_timerDataTimerNameKey] = String(format: "LGV_TIMER-TIMER-TITLE-FORMAT".localizedVariant, index)
                    index += 1
                    let colorIndex = timer.colorTheme
                    let pickerPepper = LGV_Timer_StaticPrefs.prefs.pickerPepperArray[colorIndex]
                    // This awful hack is because colors read from IB don't seem to transmit well to Watch. Pretty sure it's an Apple bug.
                    if let color = pickerPepper.textColor {
                        if let destColorSpace: CGColorSpace = CGColorSpace(name: CGColorSpace.sRGB) {
                            if let newColor = color.cgColor.converted(to: destColorSpace, intent: CGColorRenderingIntent.perceptual, options: nil) {
                                timerDictionary[LGV_Timer_Data_Keys.s_timerDataColorKey] = UIColor(cgColor: newColor)
                            }
                        }
                    }
                    timerArray.append(timerDictionary)
                }
                
                let timerData = NSKeyedArchiver.archivedData(withRootObject: timerArray)
                let responseMessage = [LGV_Timer_Messages.s_timerListHowdyMessageValue:timerData]
                
                session.sendMessage(responseMessage, replyHandler: nil, errorHandler: nil)
                
            case    LGV_Timer_Messages.s_timerRequestAppStatusMessageKey:
                self.sendAppStateMessage()
                
            case    LGV_Timer_Messages.s_timerRequestActiveTimerUIDMessageKey:
                if .active == UIApplication.shared.applicationState {
                    var activeTimerUID: String = ""
                    
                    if nil != self.currentTimer {
                        activeTimerUID = self.currentTimer.timerObject.uid
                    }
                    self.sendActiveTimerMessage(timerUID: activeTimerUID)
                } else {
                    self.sendBackgroundMessage()
                }
                
            case    LGV_Timer_Messages.s_timerListSelectTimerMessageKey:
                if let tabController = self.window?.rootViewController as? LGV_Timer_MainTabController {
                    if let uid = message[key] as? String {
                        DispatchQueue.main.async {
                            if !uid.isEmpty {
                                let timerIndex = LGV_Timer_StaticPrefs.prefs.getIndexOfTimer(uid) + 1
                                DispatchQueue.main.async {
                                    if timerIndex != tabController.selectedIndex {
                                        if 0 < timerIndex {
                                            tabController.selectedViewController = tabController.viewControllers?[timerIndex]
                                        } else {
                                            tabController.selectedViewController = tabController.viewControllers?[0]
                                        }
                                    }
                                }
                            } else {
                                tabController.selectedViewController = tabController.viewControllers?[0]
                            }
                        }
                    }
                }
                
            case    LGV_Timer_Messages.s_timerListStartTimerMessageKey:
                if let tabController = self.window?.rootViewController as? LGV_Timer_MainTabController {
                    if let uid = message[key] as? String {
                        DispatchQueue.main.async {
                            if !uid.isEmpty {
                                if let theController = tabController.selectedViewController as? LGV_Timer_TimerNavController {
                                    if let timerController = theController.topViewController as? LGV_Timer_TimerSetController {
                                        timerController.startTimer()
                                    } else {
                                        if let timerController = theController.topViewController as? LGV_Timer_TimerRuntimeViewController {
                                            timerController.continueTimer()
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
            case    LGV_Timer_Messages.s_timerListPauseTimerMessageKey:
                if let tabController = self.window?.rootViewController as? LGV_Timer_MainTabController {
                    if let uid = message[key] as? String {
                        if let _ = LGV_Timer_StaticPrefs.prefs.getTimerPrefsForUID(uid) {
                            let timerIndex = LGV_Timer_StaticPrefs.prefs.getIndexOfTimer(uid)
                            DispatchQueue.main.async {
                                if tabController.selectedIndex == (timerIndex + 1) {
                                    if nil != self.currentTimer {
                                        self.currentTimer.pauseTimer()
                                    }
                                }
                            }
                        }
                    }
                }

            case    LGV_Timer_Messages.s_timerListStopTimerMessageKey:
                if let tabController = self.window?.rootViewController as? LGV_Timer_MainTabController {
                    if let uid = message[key] as? String {
                        if let _ = LGV_Timer_StaticPrefs.prefs.getTimerPrefsForUID(uid) {
                            let timerIndex = LGV_Timer_StaticPrefs.prefs.getIndexOfTimer(uid)
                            DispatchQueue.main.async {
                                if tabController.selectedIndex == (timerIndex + 1) {
                                    if nil != self.currentTimer {
                                        self.currentTimer.stopTimer()
                                        self.currentTimer.navigationController?.popToRootViewController(animated: false)
                                    }
                                }
                            }
                        }
                    }
                }

            case    LGV_Timer_Messages.s_timerListResetTimerMessageKey:
                if let tabController = self.window?.rootViewController as? LGV_Timer_MainTabController {
                    if let uid = message[key] as? String {
                        if let _ = LGV_Timer_StaticPrefs.prefs.getTimerPrefsForUID(uid) {
                            let timerIndex = LGV_Timer_StaticPrefs.prefs.getIndexOfTimer(uid)
                            DispatchQueue.main.async {
                                if tabController.selectedIndex == (timerIndex + 1) {
                                    if nil != self.currentTimer {
                                        self.currentTimer.resetTimer()
                                    }
                                }
                            }
                        }
                    }
                }

            case    LGV_Timer_Messages.s_timerListEndTimerMessageKey:
                if let tabController = self.window?.rootViewController as? LGV_Timer_MainTabController {
                    if let uid = message[key] as? String {
                        if let _ = LGV_Timer_StaticPrefs.prefs.getTimerPrefsForUID(uid) {
                            let timerIndex = LGV_Timer_StaticPrefs.prefs.getIndexOfTimer(uid)
                            DispatchQueue.main.async {
                                if tabController.selectedIndex == (timerIndex + 1) {
                                    if nil != self.currentTimer {
                                        self.currentTimer.endTimer()
                                    }
                                }
                            }
                        }
                    }
                }
                
            default:
                if let uid = message[key] as? String {
                    print(uid)
                }
                type(of:self).displayAlert("iOS App: LGV_Timer_AppDelegate.session(_:,didReceiveMessage:)", inMessage: "\(message)")
            }
        }
    }
}

