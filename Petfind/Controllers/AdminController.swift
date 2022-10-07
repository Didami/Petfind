//
//  AdminController.swift
//  Petfind
//
//  Created by Didami on 25/01/22.
//

import UIKit

class AdminController: UIViewController {
    
    var users = [User]() {
        didSet {
            
            // TODO: - Use reloadRowsAtIndexPaths:withRowAnimation: method as use of paginated downloads
//            collectionView.reloadData()
            collectionView.reloadItems(at: getIndexArray(firstIndex: lastPresentedUsers, lastIndex: presentedUsers))
            
            UIView.animate(withDuration: 0.3) {
                self.collectionView.alpha = 1
            } completion: { [weak self] _ in
                self?.isFetchingMore = false
            }
        }
    }
    
    var lastFetchedUserId: String?
    var isFetchingMore = false
    
    var presentedUsers = 0
    var lastPresentedUsers = 0
    
    let cellId = "cellId"
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 25
        layout.minimumInteritemSpacing = 25
        layout.sectionInset = UIEdgeInsets(top: 25, left: 0, bottom: 25, right: 0)
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.showsVerticalScrollIndicator = false
        cv.backgroundColor = .clear
        cv.alpha = 0
        
        cv.delegate = self
        cv.dataSource = self
        cv.register(UserManageCell.self, forCellWithReuseIdentifier: cellId)
        
        return cv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        fetchUsers()
    }
    
    private func fetchUsers() {
        
        FirestoreManager.shared.fetchUsersStarting(with: lastFetchedUserId, limit: 5) { [weak self] result in
            
            switch result {
            case .success(var users):
                
                guard let strongSelf = self else {
                    return
                }
                
                if strongSelf.users.contains(where: { $0.userId == users.first?.userId }) == true {
                    print("done fetching")
                    users.removeAll()
                    return
                }
                
                strongSelf.lastPresentedUsers = strongSelf.presentedUsers
                strongSelf.presentedUsers += users.count
                
                strongSelf.users.append(contentsOf: users)
                strongSelf.lastFetchedUserId = users.last?.userId
                
            case .failure(let err):
                print(err.localizedDescription)
            }
        }
        
//        DatabaseManager.shared.fetchUsersStarting(with: lastFetchedUserId, limit: 5) { [weak self] result in
//        }
    }
    
    func getIndexArray(firstIndex: Int, lastIndex: Int) -> [IndexPath] {
        
        var array = [IndexPath]()
        
        for x in firstIndex ... lastIndex {
            array.append(IndexPath(item: x, section: 0))
        }
        
        return array
    }
    
    @objc private func handleSwitch(_ sender: UISwitch) {
        
        guard let uid = users[sender.tag].userId else { return }
        FirestoreManager.shared.setUserAdmin(sender.isOn, userId: uid)
//        DatabaseManager.shared.setUserAdmin(sender.isOn, userId: uid)
    }
    
    private func setupViews() {
        view.backgroundColor = .white
        
        // add subviews
        view.addSubview(collectionView)
        
        // x, y, w, h
        collectionView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        collectionView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        collectionView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        collectionView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        
    }
}

extension AdminController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func reloadCollectionView(collectionView: UICollectionView, index: IndexPath) {
        
        let contentOffset = collectionView.contentOffset
        collectionView.reloadData()
        collectionView.layoutIfNeeded()
        collectionView.setContentOffset(contentOffset, animated: false)
        collectionView.scrollToItem(at: index, at: .centeredHorizontally, animated: false)
     }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return users.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = collectionView.frame.size
        let padding: CGFloat = 25
        
        return CGSize(width: size.width - 30, height: (size.height - padding) / 5)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as? UserManageCell else { return UICollectionViewCell() }
        cell.user = users[indexPath.item]
        cell.boolSwitch.tag = indexPath.item
        cell.boolSwitch.addTarget(self, action: #selector(handleSwitch), for: .valueChanged)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let email = users[indexPath.item].email else { return }
        let alert = UIAlertController(title: email, message: nil, preferredStyle: .actionSheet)
        
        alert.view.tintColor = .secondColor
        
        alert.addAction(UIAlertAction(title: "Disable", style: .destructive, handler: { _ in
            print("DISABLE")
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView == collectionView {
            
            let offsetY = scrollView.contentOffset.y
            let contentHeight = scrollView.contentSize.height
            
            if offsetY > contentHeight - scrollView.frame.height - 50 {
                // Bottom of the screen is reached
                if !isFetchingMore {
                    isFetchingMore = true
                    fetchUsers()
                }
            }
        }
    }
}
