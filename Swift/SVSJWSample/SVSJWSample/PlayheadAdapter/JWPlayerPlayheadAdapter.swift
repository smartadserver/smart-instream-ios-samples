//
//  JWPlayerPlayheadAdapter.swift
//  SVSJWSample
//
//  Created by Loïc GIRON DIT METAZ on 30/08/2019.
//  Copyright © 2019 Smart AdServer. All rights reserved.
//

import UIKit
import SVSVideoKit

class JWPlayerPlayheadAdapter: NSObject, SVSContentPlayerPlayHead {
    
    private let playerController: JWPlayerController
    private let infiniteDuration: Bool
    
    // MARK: - Object lifecycle
    
    init(playerController: JWPlayerController, infiniteDuration: Bool) {
        self.playerController = playerController
        self.infiniteDuration = infiniteDuration
        
        super.init()
    }
    
    // MARK: - Content Player Playhead methods
    
    func contentPlayerCurrentTime() -> TimeInterval {
        return TimeInterval(self.playerController.position)
    }

    func contentPlayerTotalTime() -> TimeInterval {
        if infiniteDuration {
            return TimeInterval(kSVSContentPlayerTotalDurationInfinite)
        } else {
            return TimeInterval(playerController.duration)
        }
    }

    func contentPlayerVolumeLevel() -> Float {
        return Float(playerController.volume)
    }

    func contentPlayerIsPlaying() -> Bool {
        return playerController.state == JWPlayerState.playing
    }

}
