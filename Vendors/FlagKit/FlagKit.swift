//
//  UIImage+FlagKit.swift
//  FlagKit
//
//  Created by Simon Blommegård on 22/09/15.
//  Copyright © 2015 Bowtie. All rights reserved.
//

import Foundation

public class FlagKit {
  public enum SpecialFlag: String {
    case World = "WW"
    case EuropeanUnion = "EU"
    case NorthAmerica = "CNA"
    case SouthAmerica = "CSA"
    case Europe = "CEU"
    case Africa = "CAF"
    case Asia = "CAS"
    case Oceania = "COC"
  }

  public class var assetBundle: NSBundle {
    get {
      return NSBundle(forClass: FlagKit.self)
    }
  }
}
