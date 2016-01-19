MTMovieControl
=======

A video played base AVPlayer

Usage
------

####Initial

initial controller 

```Let player = MTMovieController()```

initial player layer

```let playLayer = MTMoviePlayer(playerController: player, frame:frame)```

####play movie

It can play local file and streaming file
```player.play(url: urlString)```

#### Add observer

There are two way to add an observer.   

##### clousure  
    self.player.eventHandle {[unowned self] (events) -> Void in
        switch events {
            case .ReadyToPlay(let totolTime):
                print("ready to play \(totolTime)")
            /*
            // buffer time and rate 
            // Dont need it, if you want video controller to control buffer prograss bar
            case .LoadTimeRanges(let bufferedTime, let bufferedRate):
                print(bufferedTime)
                print(bufferedRate)
            */
            //Current played time and rate 
            case .PlayTimeRanges(let playedTime, let playedRate):
                print(playedTime)
                print(playedRate)
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


##### Protocol delegate   

set delegate  

    player.delegate = self

. add delegate method

    func event(events: Event) {
        switch events {
            case .ReadyToPlay(let totolTime):
                print("ready to play \(totolTime)")
            /*
            // buffer time and rate 
            // Dont need it, if you want video controller to control buffer prograss bar
            case .LoadTimeRanges(let bufferedTime, let bufferedRate):
                print(bufferedTime)
                print(bufferedRate)
            */
            //Current played time and rate 
            case .PlayTimeRanges(let playedTime, let playedRate):
                print(playedTime)
                print(playedRate)
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

