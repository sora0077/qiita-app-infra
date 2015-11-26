//
//  TimeHelper.swift
//  QiitaInfra
//
//  Created by 林達也 on 2015/11/26.
//  Copyright © 2015年 jp.sora0077. All rights reserved.
//

import Foundation

extension Int {
    
    var minutes: Int {
        return self * 60
    }
    
    var hours: Int {
        return self.minutes * 60
    }
}

extension Double {
    
    var minutes: Double {
        return self * 60
    }
    
    var hours: Double {
        return self.minutes * 60
    }
}
