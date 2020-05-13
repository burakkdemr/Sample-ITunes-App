//
//  MusicCollectionViewController.swift
//  ITunesAPISample
//
//  Created by burak on 23.04.2020.
//  Copyright © 2020 burak. All rights reserved.


import UIKit


// ,UISearchBarDelegate ekle
class MusicCollectionViewController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate {
    
    
    @IBOutlet weak var musicSearch: UISearchBar!
    @IBOutlet weak var musicCollectionView: UICollectionView!
    
    var collectionViewFLowLayout:UICollectionViewFlowLayout!
    var isSearching = false
    
    var results = [Results](){
        didSet{
            DispatchQueue.main.async {
                self.musicCollectionView.reloadData()
            }
        }
    }
    
    var filteredData = [Results](){
        didSet{
            DispatchQueue.main.async {
                self.musicCollectionView.reloadData()
            }
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setCollectionView()
        self.setColectionViewLayout()
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        self.setCollectionViewItemSize()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { (_) in
            self.setCollectionViewItemSize()
        }, completion: nil)
        
    }
    
    
    
    func setCollectionView(){
        self.musicCollectionView.dataSource = self
        self.musicCollectionView.delegate = self
        self.musicSearch.delegate = self
        self.getItunesData()
    }
    
    func setColectionViewLayout(){
        collectionViewFLowLayout = UICollectionViewFlowLayout()
        musicCollectionView.setCollectionViewLayout(collectionViewFLowLayout, animated: true)
    }
    
    
    func setCollectionViewItemSize(){
        
        if UIDevice.current.orientation.isPortrait{
            
            let numberOfItemPerRow: CGFloat = 2
            let lineSpacing: CGFloat = 4
            let interItemSpacing: CGFloat = 4
            let width = (musicCollectionView.frame.width - (numberOfItemPerRow - 1) * interItemSpacing) / numberOfItemPerRow
            let height = width
            collectionViewFLowLayout.itemSize = CGSize(width: width, height: height)
            collectionViewFLowLayout.sectionInset = UIEdgeInsets.zero
            collectionViewFLowLayout.scrollDirection = .vertical
            collectionViewFLowLayout.minimumLineSpacing = lineSpacing
            collectionViewFLowLayout.minimumInteritemSpacing = lineSpacing
            collectionViewFLowLayout.invalidateLayout()
        }
        if UIDevice.current.orientation.isLandscape{
            let numberOfItemPerRow: CGFloat = 1
            let lineSpacing: CGFloat = 2
            let interItemSpacing: CGFloat = 2
            let width = (musicCollectionView.frame.width - (numberOfItemPerRow - 1) * interItemSpacing) / numberOfItemPerRow
            let height = musicCollectionView.frame.height
            
            collectionViewFLowLayout.itemSize = CGSize(width: width, height: height)
            collectionViewFLowLayout.sectionInset = UIEdgeInsets.zero
            collectionViewFLowLayout.scrollDirection = .vertical
            collectionViewFLowLayout.minimumLineSpacing = lineSpacing
            collectionViewFLowLayout.minimumInteritemSpacing = lineSpacing
            collectionViewFLowLayout.invalidateLayout()
        }
    }
    
    
    
    
    // Get ITunes Data for MusicColletion
    func getItunesData(){
        
        let url = URL(string: "https://itunes.apple.com/search?term=music&limit=100")
        
        guard let getUrl = url else {return}
        
        URLSession.shared.dataTask(with: getUrl) { (data, response, error) in
            guard let data = data, error == nil, response != nil else {return}
            
            do{
                let jsonData = try JSONDecoder().decode(Details.self, from: data)
                self.results = jsonData.results!
                DispatchQueue.main.async {
                    self.musicCollectionView.reloadData()
                }
                
            }catch{
                print(error)
            }
            
        }.resume()
    }
    
    
    
    
    
    
    
    // MARK: UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        if isSearching{
            return filteredData.count
        }
        
        return results.count
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MusicCollectionViewCell", for: indexPath) as! MusicCollectionViewCell
        
        if isSearching{
            cell.configureCell(musicName: filteredData[indexPath.row].trackName, artistImage: filteredData[indexPath.row].artworkUrl100 ?? "nil")
        }else{
            cell.configureCell(musicName: results[indexPath.row].trackName, artistImage: results[indexPath.row].artworkUrl100 ?? "nil")
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let detailVC = self.storyboard?.instantiateViewController(identifier: "DetailViewController") as? DetailViewController{
            if isSearching {
                detailVC.musicDetails = filteredData[indexPath.row]
            }else{
                detailVC.musicDetails = results[indexPath.row]
            }
            
            self.navigationController?.pushViewController(detailVC, animated: true)
        }
    }
    
}

extension MusicCollectionViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        filteredData.removeAll(keepingCapacity: false)
        
        let keyword = searchBar.text!
        let search = keyword.replacingOccurrences(of: " ", with: "+")
        
        let itunesData = ItunesRequest(term: search)
        
        itunesData.getITunesData {[weak self] result in
            switch result{
            case .failure(let error):
                print(error)
            case .success(let responseItunesData):
                self?.results = responseItunesData
            }
        }
        
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.count == 0 {
            isSearching = false
            getItunesData()
        }
    }
}
