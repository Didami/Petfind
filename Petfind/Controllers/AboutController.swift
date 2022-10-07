//
//  AboutController.swift
//  Petfind
//
//  Created by Didami on 12/02/22.
//

import UIKit

struct Social {
    var title: String?
    var url: String?
    var icon: UIImage?
}

class AboutController: UIViewController {
    
    let cellId = "cellId"
    
    var socials = [
        Social(title: "@app.petfind", url: "https://www.instagram.com/app.petfind/", icon: UIImage(named: "Instagram_Glyph_Gradient_RGB")),
        Social(title: "@petfind.app", url: "https://www.tiktok.com/@petfind.app/", icon: UIImage(named: "TikTok_Icon_Black_Circle")),
        Social(title: "@didami_", url: "https://twitter.com/didami_/", icon: UIImage(named: "2021 Twitter logo - blue")),
        Social(title: "Petfind Website", url: "https://petfind-2e3b9.web.app/", icon: UIImage(named: "icon"))
    ]
    
    lazy var socialCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 20
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.isScrollEnabled = false
        cv.backgroundColor = .clear
        
        cv.delegate = self
        cv.dataSource = self
        cv.register(SocialCell.self, forCellWithReuseIdentifier: cellId)
        
        return cv
    }()
    
    lazy var donateButton: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(UIImage(named: "bmc-black-button"), for: .normal)
        btn.addTarget(self, action: #selector(handleDonateButton), for: .touchUpInside)
        return btn
    }()
    
    let donateLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.textColor = .secondColor
        lbl.font = .mainFont(ofSize: 18, weight: .regular)
        lbl.text = "Buy us a coffee".localized()
        return lbl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    private func setupViews() {
        view.backgroundColor = .white
        
        // add subviews
        view.addSubview(socialCollectionView)
        view.addSubview(donateButton)
        view.addSubview(donateLabel)
        
        socialCollectionView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        socialCollectionView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50).isActive = true
        socialCollectionView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        socialCollectionView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1/3).isActive = true
        
        donateButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -25).isActive = true
        donateButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 40).isActive = true
        donateButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1/2).isActive = true
        donateButton.heightAnchor.constraint(equalTo: donateButton.widthAnchor, multiplier: 1/4).isActive = true
        
        donateLabel.bottomAnchor.constraint(equalTo: donateButton.topAnchor).isActive = true
        donateLabel.leftAnchor.constraint(equalTo: donateButton.leftAnchor).isActive = true
        donateLabel.widthAnchor.constraint(equalTo: donateButton.widthAnchor).isActive = true
        donateLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
    }
    
    @objc private func handleDonateButton() {
        openUrl("https://www.buymeacoffee.com/petfind")
    }
}

extension AboutController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return socials.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = collectionView.frame.size
        let padding: CGFloat = 20
        
        return CGSize(width: size.width / 2, height: (size.height / 4) - padding)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as? SocialCell else { return UICollectionViewCell() }
        cell.social = socials[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let url = socials[indexPath.item].url {
            openUrl(url)
        }
    }
}
