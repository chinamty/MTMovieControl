//
//  MTMovieEvent.swift
//  MTMoviePlayer
//
//  Created by Martin on 1/14/16.
//  Copyright © 2016 MT. All rights reserved.
//

import Foundation

enum Event {
    case ReadyToPlay(totolTime: NSTimeInterval)
    case LoadFailed
    case LoadTimeRanges(bufferedTime: Float64, bufferedRate: Float64)
    case PlaybackLikelyToKeepUp(likely: Bool)
    case BufferEmpty
    case MoviePlayDidEnd
    case Play
    case PlayTimeRanges(playedTime: NSTimeInterval, playedRate: Double)
    case UnknownError
}

protocol MTMovieEvent {
    func event(events: Event)
}