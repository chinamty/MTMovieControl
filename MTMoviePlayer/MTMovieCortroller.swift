//
//  TestStruct.swift
//  MTMoviePlayer
//
//  Created by Martin on 1/14/16.
//  Copyright © 2016 MT. All rights reserved.
//

import UIKit
import AVFoundation
class MTMovieController: NSObject, MTLog {
    
    var player: AVPlayer
    var playItem: AVPlayerItem!
    
    // There are two way to get play status, clousure or delegate.
    var playObserver: AnyObject!
    var delegate: MTMovieEvent?
    
    // define clousure
    typealias MTMovieEventsHandler = ((Event) -> Void)
    var eventHandler: MTMovieEventsHandler!
    
    //buffer bar prograss
    var bufferPrograss: UIProgressView?
    override init() {
        player = AVPlayer()
        super.init()
    }
    
    // MARK: - Movie control method
    // call play() to play current item.
    func play(url: String? = nil) {
        //if url is nil play current item. else play new item
        if url != nil {
            let item = AVPlayerItem(URL: NSURL(string: url!)!)
            playItem = item
            player.replaceCurrentItemWithPlayerItem(playItem)
        }
        
        if self.observerAdded  {
            self.removeOberserver()
        }
        self.registerObserver()
        
        self.player.play()
    }
    func pause() {
        self.player.pause()
    }
    func stop() {
        self.player.pause()
        self.player.currentItem?.cancelPendingSeeks()
        self.player.currentItem?.asset.cancelLoading()
        self.removeOberserver()
    }
    
    func muteSound(mute: Bool) {
        self.player.muted = mute
    }
    func setVolume(volume: Float) {
        self.player.volume = volume
    }
    func seekToRate(rate: Double) {
        let seconds = CMTimeGetSeconds((self.player.currentItem?.duration)!) *  rate
        
        self.seekToTime(seconds)
    }
    func seekToTime(seconds: Double) {
        let time = CMTime(seconds: round(seconds), preferredTimescale: 1)
        self.player.currentItem?.seekToTime(time)
    }
    
    // MARK: - Destroy clousure 
    
    func destroyHandler() {
        self.eventHandler = nil
    }
    // MARK: - event observer
    func eventHandle(handle: MTMovieEventsHandler) {
        eventHandler = handle
    }
    private func registerObserver() {
        self.observerAdded = true
        player.currentItem!.addObserver(self, forKeyPath: "status", options: .New, context: nil)
        player.currentItem!.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: .New, context: nil)
        player.currentItem!.addObserver(self, forKeyPath: "loadedTimeRanges", options: .New, context: nil)
        player.currentItem!.addObserver(self, forKeyPath: "playbackBufferEmpty", options: .New, context: nil)
        player.addObserver(self, forKeyPath: "rate", options: .New, context: nil)
        self.playObserver = player.addPeriodicTimeObserverForInterval(CMTimeMake(1, 1), queue: nil) { (time) -> Void in
            
            let currentTime = CMTimeGetSeconds(self.playItem.currentTime())
            let durationRate = currentTime / CMTimeGetSeconds(self.playItem.duration)
            let playTimeEvent = Event.PlayTimeRanges(playedTime: NSTimeInterval(currentTime), playedRate: durationRate)
            self.delegate?.event(playTimeEvent)
            self.eventHandler?(playTimeEvent)
        }
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "moviePlayDidEnd", name: AVPlayerItemDidPlayToEndTimeNotification, object: nil)
    }
    private func removeOberserver() {
        self.observerAdded = false
        player.currentItem?.removeObserver(self, forKeyPath: "status")
        player.currentItem?.removeObserver(self, forKeyPath: "playbackLikelyToKeepUp")
        player.currentItem?.removeObserver(self, forKeyPath: "loadedTimeRanges")
        player.currentItem?.removeObserver(self, forKeyPath: "playbackBufferEmpty")
        player.removeObserver(self, forKeyPath: "rate")
        player.removeTimeObserver(self.playObserver)
    }
    
    
    // MARK: - Notification
    func moviePlayDidEnd( notification: NSNotification) {
        self.delegate?.event(Event.MoviePlayDidEnd)
        self.eventHandler?(Event.MoviePlayDidEnd)
    }
    // MARK: - KVO event
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        func bufferTimeAndRate() -> (NSTimeInterval, Double) {
            let range = playItem.loadedTimeRanges.first
            let value = range?.CMTimeRangeValue
            let duration = CMTimeGetSeconds((value?.duration)!)
            let startTime = CMTimeGetSeconds((value?.start)!)
            let durationRate = (duration + startTime) / CMTimeGetSeconds(self.playItem.duration)
            return (NSTimeInterval( duration + startTime) , durationRate)
        }
        switch keyPath! {
        case "status":
            switch object!.status as AVPlayerItemStatus {
            case AVPlayerItemStatus.ReadyToPlay:
                let time = NSTimeInterval( CMTimeGetSeconds((self.playItem.duration)))
                delegate?.event(.ReadyToPlay(totolTime: time))
                eventHandler?(.ReadyToPlay(totolTime: time))
            case AVPlayerItemStatus.Failed:
                delegate?.event(.LoadFailed)
                eventHandler?(.LoadFailed)
            default:
                delegate?.event(.UnknownError)
                eventHandler?(.UnknownError)
            }
        case "playbackLikelyToKeepUp":
            let item = object as! AVPlayerItem
            delegate?.event(Event.PlaybackLikelyToKeepUp(likely: item.playbackLikelyToKeepUp))
            eventHandler?(Event.PlaybackLikelyToKeepUp(likely: item.playbackLikelyToKeepUp))
        case "loadedTimeRanges":
            let (buffertime, bufferRate) = bufferTimeAndRate()
            let loadTimeRangeEvent = Event.LoadTimeRanges(bufferedTime: buffertime, bufferedRate: bufferRate)
            // if there is a buffer prograss initialed, set buffer prograss directly.
            if self.bufferPrograss != nil {
                self.bufferPrograss?.setProgress(Float( bufferRate), animated: true)
            }
            else {
                delegate?.event(loadTimeRangeEvent)
                eventHandler?(loadTimeRangeEvent)
            }
        case "playbackBufferEmpty":
            delegate?.event(Event.BufferEmpty)
            eventHandler?(.BufferEmpty)
        case "rate":
            self.debugPrint("\(self.player.rate)")
            if self.player.rate == 1.0 {
                delegate?.event(Event.Play)
                eventHandler?(.Play)
            }
        default:
            true
        }
    }

    // MARK: - private variable 
    private var observerAdded: Bool = false
}

