//
//  PetInfoController.swift
//  Petfind
//
//  Created by Didami on 31/01/22.
//

import UIKit
import CoreLocation

class PetInfoController: UIViewController {
    
    var pet: Pet? {
        didSet {
            
            petInfoView.pet = self.pet
            
            if let type = pet?.type, let breed = pet?.breed, let gender = pet?.gender, let age = pet?.age, let userId = pet?.userId {
                
                petData.append(PetData(title: "Type", subtitle: type))
                petData.append(PetData(title: "Breed", subtitle: breed))
                petData.append(PetData(title: "Gender", subtitle: gender))
                petData.append(PetData(title: "Age", subtitle: age))
                
                FirestoreManager.shared.getUserInfoFrom(userId) { [weak self] user in
                    
                    if let username = user?.username, let location = user?.location {
                        self?.petData.append(PetData(title: "Location", subtitle: location))
                        self?.petData.append(PetData(title: "Owner", subtitle: "@\(username)"))
                    }
                }
                
//                DatabaseManager.shared.getUserInfoFrom(userId) { [weak self] user in
//                }
            }
        }
    }
    
    var petData = [PetData]() {
        didSet {
            dataCollection.reloadData()
        }
    }
    
    var attributedText: NSAttributedString? {
        didSet {
            petInfoView.attributedText = self.attributedText
        }
    }
    
    let petImageCellId = "petImageCellId"
    let petDataCellId = "petDataCellId"
    
    lazy var contentViewSize = CGSize(width: self.view.frame.width, height: Screen.height * 1.4)
    
    lazy var scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.backgroundColor = .white
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.contentSize = contentViewSize
        sv.showsVerticalScrollIndicator = false
        sv.delegate = self
        return sv
    }()
    
    lazy var containerView: UIView = {
        let view = UIView()
        view.frame.size = contentViewSize
        view.backgroundColor = .clear
        return view
    }()
    
    let petInfoView: PetInfoView = {
        let petInfoView = PetInfoView()
        petInfoView.translatesAutoresizingMaskIntoConstraints = false
        return petInfoView
    }()
    
    lazy var dataCollection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.showsVerticalScrollIndicator = false
        cv.showsHorizontalScrollIndicator = false
        cv.isScrollEnabled = false
        cv.backgroundColor = .clear
        
        cv.delegate = self
        cv.dataSource = self
        cv.register(PetDataCell.self, forCellWithReuseIdentifier: petDataCellId)
        
        return cv
    }()
    
    lazy var closeButton: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.backgroundColor = .black.withAlphaComponent(0.4)
        btn.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        btn.tintColor = .white
        btn.layer.masksToBounds = true
        btn.layer.cornerRadius = 15
        btn.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        return btn
    }()
    
    let mapViewController = MapViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    private func setupViews() {
        view.backgroundColor = .white
        
        // add subviews
        view.addSubview(scrollView)
        scrollView.addSubview(containerView)
        
        containerView.addSubview(petInfoView)
        containerView.addSubview(dataCollection)
        containerView.addSubview(closeButton)
        
        // x, y, w, h
        scrollView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        scrollView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        scrollView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        scrollView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        
        petInfoView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        petInfoView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        petInfoView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        petInfoView.heightAnchor.constraint(equalToConstant: (Screen.height * 0.75) + 12).isActive = true
        
        dataCollection.centerXAnchor.constraint(equalTo: petInfoView.centerXAnchor).isActive = true
        dataCollection.topAnchor.constraint(equalTo: petInfoView.bottomAnchor, constant: 8).isActive = true
        dataCollection.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8).isActive = true
        dataCollection.widthAnchor.constraint(equalTo: containerView.widthAnchor, constant: -20).isActive = true
        
        closeButton.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 12).isActive = true
        closeButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12).isActive = true
        closeButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        closeButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
    }
    
    @objc private func handleDismiss() {
        dismiss(animated: true)
    }
}

extension PetInfoController: UIScrollViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView == self.scrollView {
            scrollView.bounces = scrollView.contentOffset.y > 100
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionView == dataCollection ? petData.count : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = collectionView.frame.size
        let padding: CGFloat = 10
        
        return collectionView == dataCollection ? CGSize(width: (size.width - padding) / 2, height: (size.height - padding) / 3) : .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == dataCollection {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: petDataCellId, for: indexPath) as? PetDataCell else { return UICollectionViewCell() }
            cell.petData = petData[indexPath.item]
            return cell
        }
        
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView == dataCollection {
            
            if let petDataType = petData[indexPath.item].title?.lowercased(), let petDataValue = petData[indexPath.item].subtitle?.lowercased() {
                
                if petDataType == "location" {
                    mapViewController.locationName = petDataValue
                    present(UINavigationController(rootViewController: mapViewController), animated: true, completion: nil)
                }
            }
        }
    }
}
