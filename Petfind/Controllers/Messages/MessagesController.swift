//
//  MessagesController.swift
//  Petfind
//
//  Created by Didami on 06/02/22.
//

import UIKit

class MessagesController: UIViewController {
    
    let cellId = "cellId"
    
    var messagesHavePresented = false
    
    var messages = [Message]() {
        didSet {
            collectionView.reloadData()
        }
    }
    
    lazy var navBar: UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .mainColor.withAlphaComponent(0.4)
        
        let icon = UIImageView(image: UIImage(named: "glyph"))
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.tintColor = .secondColor
        icon.contentMode = .scaleAspectFit
        
        let leftButton = UIButton(type: .system)
        leftButton.translatesAutoresizingMaskIntoConstraints = false
        leftButton.tintColor = .secondColor
        leftButton.setImage(UIImage(systemName: "arrow.left"), for: .normal)
        leftButton.addTarget(self, action: #selector(handleLeftButton), for: .touchUpInside)
        
        container.addSubview(icon)
        container.addSubview(leftButton)
        
        icon.centerXAnchor.constraint(equalTo: container.centerXAnchor).isActive = true
        icon.topAnchor.constraint(equalTo: container.safeAreaLayoutGuide.topAnchor, constant: 8).isActive = true
        icon.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -20).isActive = true
        icon.widthAnchor.constraint(equalTo: icon.heightAnchor).isActive = true
        
        leftButton.leftAnchor.constraint(equalTo: container.leftAnchor, constant: 8).isActive = true
        leftButton.topAnchor.constraint(equalTo: icon.topAnchor).isActive = true
        leftButton.bottomAnchor.constraint(equalTo: icon.bottomAnchor).isActive = true
        leftButton.widthAnchor.constraint(equalTo: icon.widthAnchor).isActive = true
        
        return container
    }()
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 25
        layout.minimumInteritemSpacing = 25
        layout.sectionInset = UIEdgeInsets(top: 30, left: 0, bottom: 30, right: 0)
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        
        cv.delegate = self
        cv.dataSource = self
        cv.register(MessageCell.self, forCellWithReuseIdentifier: cellId)
        
        return cv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        fetchMessages()
    }
    
    private func setupViews() {
        view.backgroundColor = .white
        
        // add subviews
        view.addSubview(navBar)
        view.addSubview(collectionView)
        
        // x, y, w, h
        navBar.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        navBar.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        navBar.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        navBar.heightAnchor.constraint(equalToConstant: 160).isActive = true
        
        collectionView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: navBar.bottomAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        collectionView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
    }
    
    func fetchMessages() {
        
        messages.removeAll()
        
        guard let uid = currentUserUid else { return }
        DatabaseManager.shared.fetchMessages(for: uid) { [weak self] result in
            
            switch result {
            case .success(let messagesDict):
                
                var messages = Array(messagesDict.values)
                
                messages.sort { message1, message2 in
                    guard let timestamp1 = message1.timestamp?.intValue, let timestamp2 = message2.timestamp?.intValue else { return false }
                    return timestamp1 > timestamp2
                }
                
                self?.messages = messages
                
            case .failure(let err):
                print(err.localizedDescription)
            }
        }
    }
    
    @objc private func handleLeftButton() {
        navigationController?.popViewController(animated: true)
    }
}

extension MessagesController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if messages.count == 0 {
            collectionView.setEmptyMessage("There are not messages.".localized())
        } else {
            collectionView.restore()
        }
        
        return messages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width - 30 , height: 110)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if messagesHavePresented {
            return
        }
        
        cell.alpha = 0
        
        UIView.animate(withDuration: 0.8) {
            cell.alpha = 1
        } completion: { [weak self] _ in
            self?.messagesHavePresented = true
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as? MessageCell else { return UICollectionViewCell() }
        cell.message = messages[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let chatPartnerId = messages[indexPath.item].chatPartnerId() else {
            return
        }
        
        FirestoreManager.shared.getUserInfoFrom(chatPartnerId) { [weak self] user in
            
            let chatLogController = ChatLogController()
            chatLogController.user = user
            self?.navigationController?.pushViewController(chatLogController, animated: true)
        }
    }
}

/*
  _____       _____
 /( )   \=== /     \----------------.
|       |   |       |--------------  \
|       |   |       |              \_/
 \_____/     \_____/
 
 */
