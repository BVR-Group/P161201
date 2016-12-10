//
//  AVAudioTime.swift
//  P161201
//
//  Created by Dylan Wreggelsworth on 12/9/16.
//  Copyright © 2016 Dylan Wreggelsworth. All rights reserved.
//

import Foundation
import AVFoundation

extension AVAudioTime {
    convenience init(from time: TimeInterval) {
        let now = mach_absolute_time()
        let delay = AVAudioTime.hostTime(forSeconds: time)
        self.init(hostTime: now + delay)
    }
}
