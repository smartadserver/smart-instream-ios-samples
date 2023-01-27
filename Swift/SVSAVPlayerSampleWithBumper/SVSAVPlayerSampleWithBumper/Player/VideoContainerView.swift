//
//  VideoContainerView.swift
//  SVSAVPlayerSample
//
//  Created by Loïc GIRON DIT METAZ on 28/08/2019.
//  Copyright © 2019 Equativ. All rights reserved.
//

import UIKit
import AVFoundation

class VideoContainerView: UIView {
    
    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    
    var player: AVPlayer {
        get {
            return (layer as! AVPlayerLayer).player!
        }
        set {
            (layer as! AVPlayerLayer).player = newValue
        }
    }
    
}
