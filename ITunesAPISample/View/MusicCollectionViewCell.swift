//
//  MusicCollectionViewCell.swift
//  ITunesAPISample
//
//  Created by burak on 23.04.2020.
//  Copyright © 2020 burak. All rights reserved.
//

import UIKit

class MusicCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var musicName: UILabel!
    @IBOutlet weak var artistImage: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    

    func configureCell(musicName:String?, artistImage:String?){
        self.musicName.text = musicName ?? "unknown"
        
        if let imgUrl = URL(string: artistImage ?? "unknown"){
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
    
        updateConstraints()
        backgroundColor = .systemGroupedBackground
    }
}






