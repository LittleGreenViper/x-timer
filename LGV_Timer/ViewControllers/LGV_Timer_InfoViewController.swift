//
//  LGV_Timer_InfoViewController.swift
//  LGV_Timer
//
//  Created by Chris Marshall on 6/4/17.
//  Copyright © 2017 Little Green Viper Software Development LLC. All rights reserved.
//
/* ###################################################################################################################################### */

import UIKit

/* ###################################################################################################################################### */
/**
 */
class LGV_Timer_InfoViewController: LGV_Timer_TimerBaseViewController {
    @IBOutlet weak var shortBlurb: UITextView!
    @IBOutlet weak var longBlurb: UITextView!
    @IBOutlet weak var lgvBlurb1Label: UILabel!
    @IBOutlet weak var lgvBlurb: UIButton!
    
    @IBAction func lgvButtonHit(_ sender: Any) {
        let openLink = NSURL(string : "LGV_TIMER-ABOUT-LGV-BLURB-URI".localizedVariant)
        UIApplication.shared.open(openLink! as URL, options: [:], completionHandler: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.shortBlurb.text = self.shortBlurb.text.localizedVariant
        self.longBlurb.text = self.longBlurb.text.localizedVariant
        self.lgvBlurb1Label.text = self.lgvBlurb1Label.text?.localizedVariant
        let buttonTitle = self.lgvBlurb.title(for: UIControlState.normal)?.localizedVariant
        self.lgvBlurb.setTitle(buttonTitle, for: UIControlState.normal)
    }
}
