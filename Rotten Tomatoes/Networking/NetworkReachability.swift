//
//  NetworkReachability.swift
//  Rotten Tomatoes
//
//  Created by Marcel Molina on 9/18/15.
//  Copyright © 2015 Marcel Molina. All rights reserved.
//

import Foundation
import SystemConfiguration

class NetworkReachability {
  class func isConnectedToNetwork() -> Bool {
    var zeroAddress = sockaddr_in()
    zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
    zeroAddress.sin_family = sa_family_t(AF_INET)

    guard let defaultRouteReachability = withUnsafePointer(&zeroAddress, {
      SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
    }) else {
      return false
    }

    var flags: SCNetworkReachabilityFlags = []

    if SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) == false {
      return false
    }

    let isReachable     = flags.contains(.Reachable)
    let needsConnection = flags.contains(.ConnectionRequired)

    return isReachable && !needsConnection
  }
}