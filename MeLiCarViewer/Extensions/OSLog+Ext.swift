//
//  OSLog+Ext.swift
//  MeLiCarViewer
//
//  Created by David A Cespedes R on 9/25/20.
//  Copyright © 2020 David A Cespedes R. All rights reserved.
//

import Foundation
import os.log

extension OSLog {
    private static let subsystem = "com.mercadolibre.davidcespedes"

    static let pointsOfInterest = OSLog(subsystem: subsystem,
                                        category: .pointsOfInterest)
    static let meliCarViewer = OSLog(subsystem: subsystem,
                                     category: "default")

    static func meliCarViewer(_ category: String) -> OSLog {
        if meliCarViewer == .disabled { return .disabled }
        return OSLog(subsystem: subsystem, category: category)
    }
}
