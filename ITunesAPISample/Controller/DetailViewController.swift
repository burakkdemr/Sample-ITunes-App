//
//  DetailViewController.swift
//  ITunesAPISample
//
//  Created by burak on 23.04.2020.
//  Copyright © 2020 burak. All rights reserved.
//

import UIKit
import AVFoundation

class DetailViewController: UIViewController {
    
    @IBOutlet weak var musicSlider: UISlider!
    @IBOutlet weak var musicName: UILabel!
    @IBOutlet weak var artistImage: UIImageView!
    @IBOutlet weak var currentTime: UILabel!
    @IBOutlet weak var totalDuration: UILabel!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var pauseBtn: UIButton!
    @IBOutlet weak var restartBtn: UIButton!
    @IBOutlet weak var artistName: UILabel!
    
    var musicDetails:Results?
    var audioPlayer = AVAudioPlayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func loadView() {
        super.loadView()
        editDetailLayout()
        
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        audioPlayer.pause()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.musicName.text = musicDetails?.trackName ?? "unknown"
        self.artistName.text = musicDetails?.artistName ?? "unknown"
        
        self.musicSlider.addTarget(self, action: #selector(_slider), for: .touchDragInside)
        
        
        if let imgUrl = URL(string: musicDetails?.artworkUrl100 ?? "unknown"){
            
            DispatchQueue.global().async {
                let data = try? Data(contentsOf: imgUrl)
                if let data = data{
                    let image = UIImage(data: data)
                    DispatchQueue.main.async {
                        self.artistImage.image = image
                    }
                }
            }
        }
        
        if let prevUrl = URL(string: musicDetails?.previewUrl ?? "unknown"){
            
            let data = try? Data(contentsOf: prevUrl)
            if let data = data{
                do{
                    self.audioPlayer = try AVAudioPlayer(data: data)
                    self.audioPlayer.prepareToPlay()
                    
                    do{
                        try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
                    }
                    catch{
                        print("playback error",error)
                    }
                }
                catch{
                    print("No data",error)
                }
                
            }
        }
    }
    
    
    
    @objc func _slider(){
        if audioPlayer.isPlaying{
            audioPlayer.stop()
            audioPlayer.currentTime = TimeInterval(musicSlider.value)
            audioPlayer.play()
        }else{
            audioPlayer.currentTime = TimeInterval(musicSlider.value)
        }
        
    }
    
    func updateTime(){
        Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
        musicSlider.maximumValue = Float(audioPlayer.duration)
        self.totalDuration.text = formattedTimeString(interval: audioPlayer.duration) as String
        
    }
    
    @objc func update(timer:Timer){
        musicSlider.value = Float(audioPlayer.currentTime)
        self.currentTime.text = formattedTimeString(interval: TimeInterval(musicSlider.value)) as String
    }
    
    func formattedTimeString(interval:TimeInterval) -> NSString{
        let time = NSInteger(interval)
        let second = time % 60
        let minute = (time / 60)
        return NSString(format: "%0.2d:%0.2d", minute,second)
    }
    
    
    @IBAction func play(_ sender: UIButton) {
        audioPlayer.play()
        updateTime()
    }
    
    @IBAction func pause(_ sender: UIButton) {
        if audioPlayer.isPlaying{
            audioPlayer.pause()
        }
    }
    
    //    restart not stop!!!
    @IBAction func stop(_ sender: UIButton) {
        if audioPlayer.isPlaying{
            audioPlayer.currentTime = 0
            updateTime()
            audioPlayer.play()
            
        }
    }
    
    func editDetailLayout(){
        artistImage.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(artistImage)
        
        
        NSLayoutConstraint.activate([
            artistImage.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            artistImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            artistImage.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.60),
            artistImage.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 1)
        ])
        
        
        musicName.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(musicName)
        NSLayoutConstraint.activate([
            musicName.topAnchor.constraint(equalTo: self.artistImage.bottomAnchor),
            musicName.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            musicName.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 32),
            musicName.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -32)
        ])
        
        artistName.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(artistName)
        NSLayoutConstraint.activate([
            artistName.topAnchor.constraint(equalTo: self.musicName.bottomAnchor, constant: 5),
            artistName.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            artistName.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 32),
            artistName.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -32)
        ])
        
        musicSlider.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(musicSlider)
        NSLayoutConstraint.activate([
            musicSlider.topAnchor.constraint(equalTo: self.artistName.bottomAnchor, constant: 20),
            musicSlider.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            musicSlider.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 32),
            musicSlider.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -32),
        ])
        
        currentTime.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(currentTime)
        NSLayoutConstraint.activate([
            currentTime.bottomAnchor.constraint(equalTo: self.musicSlider.topAnchor, constant: 10),
            currentTime.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 32),
            currentTime.widthAnchor.constraint(equalToConstant: 70)
        ])
        
        totalDuration.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(totalDuration)
        NSLayoutConstraint.activate([
            totalDuration.bottomAnchor.constraint(equalTo: self.musicSlider.topAnchor, constant: 10),
            totalDuration.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -32),
            totalDuration.widthAnchor.constraint(equalToConstant: 70)
        ])
        
        
        playBtn.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(playBtn)
        NSLayoutConstraint.activate([
            playBtn.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 100),
            playBtn.topAnchor.constraint(equalTo: self.musicSlider.bottomAnchor, constant: 10),
            playBtn.widthAnchor.constraint(equalToConstant: 30),
            playBtn.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        pauseBtn.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(pauseBtn)
        NSLayoutConstraint.activate([
            pauseBtn.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            pauseBtn.topAnchor.constraint(equalTo: self.musicSlider.bottomAnchor, constant: 10),
            pauseBtn.widthAnchor.constraint(equalToConstant: 30),
            pauseBtn.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        restartBtn.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(restartBtn)
        NSLayoutConstraint.activate([
            restartBtn.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -100),
            restartBtn.topAnchor.constraint(equalTo: self.musicSlider.bottomAnchor, constant: 10),
            restartBtn.widthAnchor.constraint(equalToConstant: 30),
            restartBtn.heightAnchor.constraint(equalToConstant: 30)
        ])
        
    }
    
}
