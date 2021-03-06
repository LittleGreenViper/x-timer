//
//  LGV_Timer_TimerRuntimeViewController.swift
//  LGV_Timer
//
//  Created by Chris Marshall on 6/1/17.
//  Copyright © 2017 Little Green Viper Software Development LLC. All rights reserved.
//  This is proprietary code. Copying and reuse are not allowed. It is being opened to provide sample code.
//
/* ###################################################################################################################################### */

import UIKit
import AudioToolbox

/* ###################################################################################################################################### */
/**
 */
class LGV_Timer_TimerRuntimeViewController: LGV_Timer_TimerNavBaseController {
    // MARK: - Private Instance Properties
    /* ################################################################################################################################## */
    private let _stoplightDualModeHeightFactor: CGFloat = 0.15
    private let _stoplightMaxWidthFactor: CGFloat = 0.2
    private var _originalValue: Int = 0                         ///< Tracks the last value, so we make sure we don't "blink" until we're supposed to.
    
    // MARK: - Internal Constant Instance Properties
    /* ################################################################################################################################## */
    let pauseButtonImageName = "Phone-Pause"
    let startButtonImageName = "Phone-Start"
    let offStoplightImageName = "OffLight"
    let greenStoplightImageName = "GreenLight"
    let yellowStoplightImageName = "YellowLight"
    let redStoplightImageName = "RedLight"
    
    // MARK: - Internal Instance Properties
    /* ################################################################################################################################## */
    var stoplightContainerView: UIView! = nil
    var redLight: UIImageView! = nil
    var yellowLight: UIImageView! = nil
    var greenLight: UIImageView! = nil
    var myHandler: LGV_Timer_TimerSetController! = nil
    
    // MARK: - IB Properties
    /* ################################################################################################################################## */
    @IBOutlet weak var pauseButton: UIBarButtonItem!
    @IBOutlet weak var stopButton: UIBarButtonItem!
    @IBOutlet weak var resetButton: UIBarButtonItem!
    @IBOutlet weak var endButton: UIBarButtonItem!
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var timeDisplay: LGV_Lib_LEDDisplayHoursMinutesSecondsDigitalClock!
    @IBOutlet weak var flasherView: UIView!
    @IBOutlet weak var navBarItem: UINavigationItem!
    @IBOutlet weak var myNavigationBar: UINavigationBar!

    @IBOutlet var tapRecognizer: UITapGestureRecognizer!
    @IBOutlet var resetSwipeRecognizer: UISwipeGestureRecognizer!
    @IBOutlet var endSwipeRecognizer: UISwipeGestureRecognizer!
    
    // MARK: - Private Instance Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     Bring in the setup screen.
     */
    private func _setUpDisplay() {
        if nil != self.pauseButton {
            self.pauseButton.image = UIImage(named: .Paused == self.timerObject.timerStatus ? self.startButtonImageName: self.pauseButtonImageName)
            self.pauseButton.isEnabled = (0 < self.timerObject.currentTime)
        }
        
        if nil != self.resetButton {
            self.resetButton.isEnabled = (self.timerObject.currentTime < self.timerObject.timeSet)
        }
        
        if nil != self.endButton {
            self.endButton.isEnabled = (0 < self.timerObject.currentTime)
        }
        
        if .Podium != self.timerObject.displayMode && nil != self.timeDisplay {
            if self._originalValue != self.timerObject.currentTime {
                self._originalValue = self.timerObject.currentTime
                self.timeDisplay.hours = TimeTuple(self.timerObject.currentTime).hours
                self.timeDisplay.minutes = TimeTuple(self.timerObject.currentTime).minutes
                self.timeDisplay.seconds = TimeTuple(self.timerObject.currentTime).seconds
                self.timeDisplay.setNeedsDisplay()
            }
        }
        
        if .Digital != self.timerObject.displayMode && nil != self.stoplightContainerView {
            switch self.timerObject.timerStatus {
            case .Paused:
                self.greenLight.isHighlighted = false
                self.yellowLight.isHighlighted = false
                self.redLight.isHighlighted = false
                
            case .Running:
                self.greenLight.isHighlighted = true
                self.yellowLight.isHighlighted = false
                self.redLight.isHighlighted = false
                
            case .WarnRun:
                self.greenLight.isHighlighted = false
                self.yellowLight.isHighlighted = true
                self.redLight.isHighlighted = false
                
            case .FinalRun:
                self.greenLight.isHighlighted = false
                self.yellowLight.isHighlighted = false
                self.redLight.isHighlighted = true
                
            case .Alarm:
                self.greenLight.isHighlighted = false
                self.yellowLight.isHighlighted = false
                self.redLight.isHighlighted = false
                
            default:
                break
            }
        }
    }
    
    /* ################################################################## */
    /**
     */
    private func _playAlertSound() {
        if .Silent != self.timerObject.alertMode {
            if let soundUrl = Bundle.main.url(forResource: String(format: "Sound-%02d", self.timerObject.soundID), withExtension: "aiff") {
                var soundId: SystemSoundID = 0
                
                if .VibrateOnly != self.timerObject.alertMode {
                    AudioServicesCreateSystemSoundID(soundUrl as CFURL, &soundId)

                    AudioServicesAddSystemSoundCompletion(soundId, nil, nil, { (soundId, _) -> Void in
                        AudioServicesDisposeSystemSoundID(soundId)
                    }, nil)
                }
                
                if .Both == self.timerObject.alertMode {
                    AudioServicesPlayAlertSound(soundId)
                } else {
                    if .VibrateOnly == self.timerObject.alertMode {
                        AudioServicesAddSystemSoundCompletion(kSystemSoundID_Vibrate, nil, nil, { (_, _) -> Void in
                            AudioServicesDisposeSystemSoundID(kSystemSoundID_Vibrate)
                        }, nil)
                        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                    } else {
                        AudioServicesPlaySystemSound(soundId)
                    }
                }
            }
        }
    }
    
    // MARK: - Internal Instance Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    func pauseTimer() {
        self.flashDisplay(UIColor.red.withAlphaComponent(0.5), duration: 0.5)
        LGV_Timer_AppDelegate.appDelegateObject.timerEngine.pauseTimer()
    }
    
    /* ################################################################## */
    /**
     */
    func continueTimer() {
        if LGV_Timer_AppDelegate.appDelegateObject.timerEngine.appState.showControlsInRunningTimer {
            self.navBarItem.title = ""
        }
        
        self.flashDisplay(UIColor.green.withAlphaComponent(0.5), duration: 0.5)
        LGV_Timer_AppDelegate.appDelegateObject.timerEngine.continueTimer()
    }
    
    /* ################################################################## */
    /**
     */
    func stopTimer() {
        self.flashDisplay(UIColor.red, duration: 0.5)
        LGV_Timer_AppDelegate.appDelegateObject.timerEngine.stopTimer()
    }
    
    /* ################################################################## */
    /**
     */
    func endTimer() {
        if LGV_Timer_AppDelegate.appDelegateObject.timerEngine.appState.showControlsInRunningTimer {
            self.navBarItem.title = ""
        }
        
        LGV_Timer_AppDelegate.appDelegateObject.timerEngine.endTimer()
    }
    
    /* ################################################################## */
    /**
     */
    func resetTimer() {
        if .Paused != self.timerObject.timerStatus {
            self.flashDisplay(UIColor.red.withAlphaComponent(0.5), duration: 0.5)
        } else {
            self.flashDisplay(UIColor.white.withAlphaComponent(0.5), duration: 0.5)
        }
        
        LGV_Timer_AppDelegate.appDelegateObject.timerEngine.resetTimer()
    }
    
    /* ################################################################## */
    /**
     */
    func updateTimer() {
        self._setUpDisplay()
        
        self.timeDisplay.isHidden = (.Podium == self.timerObject.displayMode) || (.Alarm == self.timerObject.timerStatus)
        if nil != self.stoplightContainerView {
            self.stoplightContainerView.isHidden = (.Alarm == self.timerObject.timerStatus)
        }

        if .Alarm == self.timerObject.timerStatus {
            self.flashDisplay()
            self._playAlertSound()
        }
    }
    
    /* ################################################################## */
    /**
     */
    func flashDisplay(_ inUIColor: UIColor! = nil, duration: TimeInterval = 0.75) {
        DispatchQueue.main.async {
            if nil != inUIColor {
                self.flasherView.backgroundColor = inUIColor
            } else {
                switch self.timerObject.timerStatus {
                case .WarnRun:
                    self.flasherView.backgroundColor = UIColor.yellow
                case.FinalRun:
                    self.flasherView.backgroundColor = UIColor.orange
                default:
                    self.flasherView.backgroundColor = UIColor.red
                }
            }
            
            self.flasherView.isHidden = false
            self.flasherView.alpha = 1.0
            UIView.animate(withDuration: duration, animations: {
                self.flasherView.alpha = 0.0
            })
        }
    }

    // MARK: - Base Class Override Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tapRecognizer.require(toFail: resetSwipeRecognizer)
        self.tapRecognizer.require(toFail: endSwipeRecognizer)
        
        let tempRect = CGRect(origin: CGPoint.zero, size: CGSize(width: 75, height: 75))
        
        if .Digital != self.timerObject.displayMode {
            self.stoplightContainerView = UIView(frame: tempRect)
            self.stoplightContainerView.isUserInteractionEnabled = false
            
            self.greenLight = UIImageView(frame: tempRect)
            self.yellowLight = UIImageView(frame: tempRect)
            self.redLight = UIImageView(frame: tempRect)
            
            self.stoplightContainerView.addSubview(self.greenLight)
            self.stoplightContainerView.addSubview(self.yellowLight)
            self.stoplightContainerView.addSubview(self.redLight)
            
            self.greenLight.contentMode = .scaleAspectFit
            self.yellowLight.contentMode = .scaleAspectFit
            self.redLight.contentMode = .scaleAspectFit
            
            self.greenLight.image = UIImage(named: self.offStoplightImageName)
            self.yellowLight.image = UIImage(named: self.offStoplightImageName)
            self.redLight.image = UIImage(named: self.offStoplightImageName)
            self.greenLight.highlightedImage = UIImage(named: self.greenStoplightImageName)
            self.yellowLight.highlightedImage = UIImage(named: self.yellowStoplightImageName)
            self.redLight.highlightedImage = UIImage(named: self.redStoplightImageName)
            
            self.view.addSubview(self.stoplightContainerView)
        }
        
        self.timeDisplay.activeSegmentColor = LGV_Timer_AppDelegate.appDelegateObject.timerEngine.colorLabelArray[self.timerObject.colorTheme].textColor
        self.timeDisplay.inactiveSegmentColor = UIColor.white.withAlphaComponent(0.1)
        self.updateTimer()
    }
    
    /* ################################################################## */
    /**
     */
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if nil != self.stoplightContainerView {
            let verticalPadding: CGFloat = (.Dual == self.timerObject.displayMode) ? 4: 0
            var containerRect = self.view.bounds
            var maxWidth = (containerRect.size.width * self._stoplightMaxWidthFactor)
            
            if .Dual == self.timerObject.displayMode {
                maxWidth = min(maxWidth, containerRect.size.height * self._stoplightDualModeHeightFactor)
                containerRect.origin.y = containerRect.size.height - (maxWidth + (verticalPadding * 2))
                containerRect.size.height = maxWidth + (verticalPadding * 2)
            }
            
            self.stoplightContainerView.frame = containerRect
            
            let yPos = (containerRect.size.height / 2) - ((maxWidth / 2) + verticalPadding)
            let stopLightSize = CGSize(width: maxWidth, height: maxWidth)
            let greenPos = CGPoint(x: (containerRect.size.width / 4) - (maxWidth / 2), y: yPos)
            let yellowPos = CGPoint(x: (containerRect.size.width / 2) - (maxWidth / 2), y: yPos )
            let redPos = CGPoint(x: (containerRect.size.width - (containerRect.size.width / 4)) - (maxWidth / 2), y: yPos)
            
            let greenFrame = CGRect(origin: greenPos, size: stopLightSize)
            let yellowFrame = CGRect(origin: yellowPos, size: stopLightSize)
            let redFrame = CGRect(origin: redPos, size: stopLightSize)
            
            self.greenLight.frame = greenFrame
            self.yellowLight.frame = yellowFrame
            self.redLight.frame = redFrame
        }

        self._originalValue = 0
        
        self.updateTimer()
    }
    
    /* ################################################################## */
    /**
     */
    override func viewWillAppear(_ animated: Bool) {
        UIApplication.shared.isIdleTimerDisabled = true
        super.viewWillAppear(animated)
        
        if LGV_Timer_AppDelegate.appDelegateObject.timerEngine.appState.showControlsInRunningTimer {
            self.myNavigationBar.tintColor = self.view.tintColor
            self.myNavigationBar.backgroundColor = UIColor.clear
            self.myNavigationBar.barTintColor = UIColor.clear
            self.myNavigationBar.isHidden = false
        } else {
            self.myNavigationBar.isHidden = true
        }
        
        LGV_Timer_AppDelegate.appDelegateObject.currentTimer = self
        LGV_Timer_AppDelegate.appDelegateObject.timerEngine.selectedTimerUID = self.timerObject.uid
        LGV_Timer_AppDelegate.appDelegateObject.timerEngine.startTimer()
    }
    
    /* ################################################################## */
    /**
     */
    override func viewWillDisappear(_ animated: Bool) {
        self.myHandler.runningTimer = nil
        if let navController = self.navigationController {
            navController.navigationBar.isHidden = false
        }
        
        super.viewWillDisappear(animated)
        
        LGV_Timer_AppDelegate.appDelegateObject.currentTimer = nil
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    // MARK: - IB Action Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    @IBAction func stopButtonHit(_ sender: Any) {
        self.stopTimer()
    }
    
    /* ################################################################## */
    /**
     */
    @IBAction func endButtonHit(_ sender: Any) {
        if .Alarm == self.timerObject.timerStatus {
            self.resetTimer()
        } else {
            self.endTimer()
        }
    }
    
    /* ################################################################## */
    /**
     */
    @IBAction func resetButtonHit(_ sender: Any) {
        if (.Paused == self.timerObject.timerStatus) && (self.timerObject.timeSet == self.timerObject.currentTime) {
            self.stopTimer()
        } else {
            self.resetTimer()
        }
    }
    
    /* ################################################################## */
    /**
     */
    @IBAction func pauseButtonHit(_ sender: Any) {
        if .Paused == self.timerObject.timerStatus {
            self.continueTimer()
        } else {
            self.pauseTimer()
        }
    }
    
    /* ################################################################## */
    /**
     */
    @IBAction func tapInView(_ sender: Any) {
        if .Alarm == self.timerObject.timerStatus {
            self.resetTimer()
        } else {
            if .Paused == self.timerObject.timerStatus {
                self.continueTimer()
            } else {
                self.pauseTimer()
            }
        }
    }
}
