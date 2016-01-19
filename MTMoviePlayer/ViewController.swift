//
//  ViewController.swift
//  MTMoviePlayer
//
//  Created by Martin on 1/13/16.
//  Copyright © 2016 MT. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, MTMovieEvent {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let playC = MTMovieController()
        
        let playLayer = MTMoviePlayer(playerController: playC, frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height))
        self.player = playC
        self.view.addSubview(playLayer)

        self.view.addSubview(self.videoController)
        
        self.videoController.addSubview(prograss)
        self.videoController.addSubview(sliderBar)

        self.videoController.addSubview(playButton)
        self.player.bufferPrograss = prograss
        
        self.play()
    }
    
    func play() {
        self.player.play(playURL[0])
        self.playButton.selected = true
//        self.player.muteSound(true)
        self.player.eventHandle {[unowned self] (events) -> Void in
            switch events {
            case .ReadyToPlay(let totolTime):
                print("ready to play \(totolTime)")
                self.sliderBar.maximumValue = Float(totolTime)
            /* 
            // Dont need it, because player will controll prograss bar
            case .LoadTimeRanges(let bufferedTime, let bufferedRate):
                print("load time")
                print(bufferedTime)
                print(bufferedRate)
            */
            case .PlayTimeRanges(let playedTime, let playedRate):
                print("played time")
                print(playedTime)
                print(playedRate)
                self.sliderBar.setValue(Float(playedTime), animated: true)
            case .BufferEmpty:
                print("buffer is empty")
            case .Play:
                print("isPlaying now")
            case .MoviePlayDidEnd:
                print("Movie play did end")
            case .LoadFailed:
                print("load data failed")
            default:
                print("default")
            }
        }
    }
    
    func buttonTriger(sender: UIButton) {
        if sender.selected {
            self.player.pause()
            sender.selected = false
        }
        else {
            self.player.play()
            sender.selected = true
        }
    }
    func stop() {

        self.player.stop()
        self.player.destroyHandler()
    }
    
    func valueChangedEnd(slider: UISlider) {
        let time = Double( slider.value)
        player.seekToTime(time)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func event(events: Event) {
        switch events {
        case .ReadyToPlay:
            print("ready to play")
        case .LoadTimeRanges(let bufferedTime, let bufferedRate):
            print(bufferedTime)
            print(bufferedRate)
        default:
            print("default")
        }
    }
    var playURL = ["http://videof.ikan.cn/348b354aa88dd93c5bb7a76f966f20a2/569e308e/Disk01_6000g/20151231/F5761FA6-96CA-56B1-77D9-8972E7034CBE-720p.mp4","http://videof.ikan.cn/348b354aa88dd93c5bb7a76f966f20a2/569e308e/Disk01_6000g/20151231/F5761FA6-96CA-56B1-77D9-8972E7034CBE-720p.mp4"]
    
    var observer: AnyObject!
    var player: MTMovieController!
    lazy var videoController: UIView =  {
        let view = UIView(frame:CGRectMake(0, UIScreen.mainScreen().bounds.height - 100,UIScreen.mainScreen().bounds.width,100))
        view.backgroundColor = UIColor.blackColor()
        return view
    }()
    lazy var sliderBar : UISlider = {
        let slider = UISlider(frame: CGRectMake(80, 45,UIScreen.mainScreen().bounds.width - 100, 10))
        slider.addTarget(self, action: "valueChangedEnd:", forControlEvents: .TouchUpInside)
        return slider
    }()
    lazy var prograss: UIProgressView = {
        let prograss = UIProgressView(frame: CGRectMake(80, 50,UIScreen.mainScreen().bounds.width - 100, 2))
        prograss.progressTintColor = UIColor.blueColor()
        return prograss
    }()
    lazy var playButton : UIButton = {
        let button  = UIButton(frame: CGRectMake(10, 25, 50, 50))
        button.setBackgroundImage(UIImage(named: "play"), forState: .Normal)
        button.setBackgroundImage(UIImage(named: "pause"), forState: .Selected)
        button.addTarget(self, action: "buttonTriger:", forControlEvents: .TouchUpInside)
        return button
    }()
}

