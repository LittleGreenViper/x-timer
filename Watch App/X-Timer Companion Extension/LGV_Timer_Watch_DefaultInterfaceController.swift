//
//  LGV_Timer_Watch_DefaultInterfaceController.swift
//  LGV_Timer
//
//  Created by Chris Marshall on 6/23/17.
//  Copyright © 2017 Little Green Viper Software Development LLC. All rights reserved.
//  This is proprietary code. Copying and reuse are not allowed. It is being opened to provide sample code.
//

import WatchKit

/* ###################################################################################################################################### */
/**
 */
class LGV_Timer_Watch_DefaultInterfaceController: WKInterfaceController {
    static var screenID: String { return "DefaultScreen" }
    
    @IBOutlet var topLabel: WKInterfaceLabel!
    @IBOutlet var bottomLabel: WKInterfaceLabel!
    
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        LGV_Timer_Watch_ExtensionDelegate.delegateObject.timerControllers = []
        self.topLabel.setText("LGV_TIMER-WATCH-NOT-ACTIVE-TOP-MESSAGE".localizedVariant)
        self.bottomLabel.setText("LGV_TIMER-WATCH-NOT-ACTIVE-BOTTOM-MESSAGE".localizedVariant)
    }
}
