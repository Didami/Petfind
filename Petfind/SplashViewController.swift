//
//  SplashViewController.swift
//  Petfind
//
//  Created by Didami on 13/03/22.
//

import UIKit
import AVFoundation

class SplashViewController: UIViewController {

    var player: AVPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupVideo()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private func setupVideo() {
        
        let videoURL: URL = Bundle.main.url(forResource: "splash_screen", withExtension: "mp4")!
        
        player = AVPlayer(url: videoURL)
        player?.actionAtItemEnd = .none
        player?.isMuted = true
        
        _ = try? AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: .default, options: .mixWithOthers)
        
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.backgroundColor = UIColor.white.cgColor
        playerLayer.videoGravity = .resizeAspectFill
        playerLayer.zPosition = 1
        playerLayer.frame = view.frame
        
        view.layer.addSublayer(playerLayer)
        
        player?.play()
            
        NotificationCenter.default.addObserver(self,
            selector: #selector(videoDidEnd),
            name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
            object: nil)
    }
    
    @objc func videoDidEnd() {
        
        var rootViewController = UINavigationController(rootViewController: ParentController())
        
        if currentUserUid == nil {
            rootViewController = UINavigationController(rootViewController: OnboardingController())
        }
        
        rootViewController.modalPresentationStyle = .fullScreen
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.present(rootViewController, animated: true)
        }
    }
}
