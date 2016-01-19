//
//  MTMoviePlayer.swift
//  MTMoviePlayer
//
//  Created by Martin on 1/13/16.
//  Copyright © 2016 MT. All rights reserved.
//

import UIKit
import AVFoundation
class MTMoviePlayer: UIView {
    required init (playerController: MTMovieController, frame: CGRect) {
        playerLayer = AVPlayerLayer(player: playerController.player)
        super.init(frame: frame)
        playerLayer.frame = frame
        self.layer.addSublayer(playerLayer)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    var playerLayer: AVPlayerLayer
}

