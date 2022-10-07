//
//  ProfileController.swift
//  Petfind
//
//  Created by Didami on 25/01/22.
//

import UIKit
import MapKit

class ProfileController: UIViewController {
    
    enum ProfileTabIndex: Int {
        case firstChild = 0
        case secondChild = 1
    }
    
    var parentController: ParentController?
    
    var currentController: UIViewController?
    
    let userDataController = UserDataController()
    let likedController = LikedController()
    
    var selectedIndex = 0 {
        didSet {
            
            switchToTab(selectedIndex)
            
            if selectedIndex == 0 {
                
                selectedViewLeft?.isActive = true
                selectedViewRight?.isActive = false
                
                UIView.animate(withDuration: 0.3) {
                    self.view.layoutIfNeeded()
                }
                
            } else {
                
                selectedViewLeft?.isActive = false
                selectedViewRight?.isActive = true
                
                UIView.animate(withDuration: 0.3) {
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    
    var selectedViewLeft: NSLayoutConstraint?
    var selectedViewRight: NSLayoutConstraint?
    
    lazy var segmentedControl: UISegmentedControl = {
        let sc = PlainSegmentedControl(items: ["My data".localized(), "My likes".localized()])
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.selectedSegmentIndex = 0
        sc.selectedSegmentTintColor = .clear
        sc.setBackgroundImage(UIImage(), for: .normal, barMetrics: .default)
        sc.setDividerImage(UIImage(), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
        sc.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.mainGray.withAlphaComponent(0.4), NSAttributedString.Key.font: UIFont.mainFont(ofSize: 18, weight: .regular)], for: .normal)
        sc.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.secondColor, NSAttributedString.Key.font: UIFont.mainFont(ofSize: 18, weight: .medium)], for: .selected)
        
        let topView = UIView()
        topView.translatesAutoresizingMaskIntoConstraints = false
        topView.backgroundColor = .mainGray.withAlphaComponent(0.4)
        
        sc.addSubview(topView)
        
        topView.centerXAnchor.constraint(equalTo: sc.centerXAnchor).isActive = true
        topView.topAnchor.constraint(equalTo: sc.topAnchor).isActive = true
        topView.heightAnchor.constraint(equalToConstant: 2).isActive = true
        topView.widthAnchor.constraint(equalTo: sc.widthAnchor).isActive = true
        
        let selectedView = UIView()
        selectedView.translatesAutoresizingMaskIntoConstraints = false
        selectedView.backgroundColor = .secondColor
        
        topView.addSubview(selectedView)
        
        selectedView.topAnchor.constraint(equalTo: topView.topAnchor).isActive = true
        selectedView.heightAnchor.constraint(equalToConstant: 2).isActive = true
        selectedView.widthAnchor.constraint(equalTo: topView.widthAnchor, multiplier: 1/2).isActive = true
        
        selectedViewLeft = selectedView.leftAnchor.constraint(equalTo: topView.leftAnchor)
        selectedViewRight = selectedView.rightAnchor.constraint(equalTo: topView.rightAnchor)

        selectedViewLeft?.isActive = true
        selectedViewRight?.isActive = false
        
        sc.addTarget(self, action: #selector(handleSegmentedControl(_:)), for: .valueChanged)
        
        return sc
    }()
    
    lazy var contentView: UIView = {
        let cv = UIView()
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        displayCurrentTab(ProfileTabIndex.firstChild.rawValue, completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let currentViewController = currentController {
            currentViewController.viewWillDisappear(animated)
        }
    }
    
    private func switchToTab(_ tabIndex: Int) {
        
        if viewControllerForSelectedSegmentIndex(tabIndex) == currentController {
            return
        }
        
        UIView.animate(withDuration: 0.5) {
            self.contentView.alpha = 0
        } completion: { _ in
            
            self.currentController!.view.removeFromSuperview()
            self.currentController!.removeFromParent()
            
            self.displayCurrentTab(tabIndex) {
                
                UIView.animate(withDuration: 0.5) {
                    self.contentView.alpha = 1
                }
            }
        }
    }
    
    private func displayCurrentTab(_ tabIndex: Int, completion: (() -> Void)?) {
        
        if let vc = viewControllerForSelectedSegmentIndex(tabIndex) {
            
            self.addChild(vc)
            vc.didMove(toParent: self)
            vc.view.frame = self.contentView.bounds
            self.contentView.addSubview(vc.view)
            self.currentController = vc
            
            if completion != nil {
                completion!()
            }
        }
    }
    
    private func viewControllerForSelectedSegmentIndex(_ index: Int) -> UIViewController? {
            
        var vc: UIViewController?
            
        switch index {
        case ProfileTabIndex.firstChild.rawValue:
            vc = userDataController
        case ProfileTabIndex.secondChild.rawValue:
            vc = likedController
        default:
            return nil
        }
        
        return vc
    }
    
    private func setupViews() {
        view.backgroundColor = .white
        navigationController?.navigationBar.isHidden = true
        
        userDataController.profileController = self
        likedController.profileController = self
        
        // add subviews
        view.addSubview(segmentedControl)
        view.addSubview(contentView)
        
        // x, y, w, h
        segmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        segmentedControl.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        segmentedControl.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        segmentedControl.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        contentView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        contentView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        contentView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    @objc private func handleSegmentedControl(_ sender: UISegmentedControl) {
        selectedIndex = sender.selectedSegmentIndex
    }
}

// MARK: - User data controller
class UserDataController: UIViewController {
    
    var profileController: ProfileController?
    
    let bioPlaceholder = "Tell us about what you are looking for.".localized()
    var lastBio = ""
    
    var currentUser: User? {
        didSet {
            
            if let username = currentUser?.username, let email = currentUser?.email, let locationName = currentUser?.location {
                
                let attrString = NSMutableAttributedString(string: "@\(username)\n", attributes: [NSAttributedString.Key.font: UIFont.mainFont(ofSize: 22, weight: .semibold), NSAttributedString.Key.foregroundColor: UIColor.secondColor])
                
                attrString.append(NSAttributedString(string: email, attributes: [NSAttributedString.Key.font: UIFont.mainFont(ofSize: 20, weight: .semibold), NSAttributedString.Key.foregroundColor: UIColor.mainGray]))
                
                dataTextView.attributedText = attrString
                
                UIView.animate(withDuration: 0.3) {
                    self.dataTextView.alpha = 1
                }
                
                if currentUser?.bio != nil {
                    lastBio = (currentUser?.bio)!
                    bioTextView.text = currentUser?.bio
                }
                
                getLocation(forPlaceCalled: locationName) { [weak self] location in
                    self?.location = location
                }
            }
        }
    }
    
    var location: CLLocation? {
        didSet {
            
            if let location = location {
                mapView.centerToLocation(location)
            }
        }
    }
    
    let dataTextView: UITextView = {
        let tf = UITextView()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.isEditable = false
        tf.isSelectable = false
        tf.isScrollEnabled = false
        tf.backgroundColor = .clear
        tf.alpha = 0
        return tf
    }()
    
    let mapView: MKMapView = {
        let mv = MKMapView()
        mv.translatesAutoresizingMaskIntoConstraints = false
        mv.layer.masksToBounds = true
        return mv
    }()
    
    let bioLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.textColor = .secondColor
        lbl.font = .mainFont(ofSize: 18, weight: .semibold)
        lbl.text = "About you:".localized()
        return lbl
    }()
    
    lazy var bioTextView: UITextView = {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = .clear
        tv.font = .mainFont(ofSize: 14, weight: .regular)
        tv.isEditable = true
        tv.isScrollEnabled = true
        tv.showsVerticalScrollIndicator = false
        tv.text = bioPlaceholder
        tv.textColor = .mainGray
        tv.delegate = self
        return tv
    }()
    
    lazy var bioButton: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("Publish".localized(), for: .normal)
        btn.titleLabel?.font = .mainFont(ofSize: 16, weight: .semibold)
        btn.backgroundColor = .secondColor
        btn.layer.masksToBounds = true
        btn.layer.cornerRadius = 20
        btn.addTarget(self, action: #selector(handleBioButton), for: .touchUpInside)
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        fetchUser()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        mapView.layer.cornerRadius = mapView.frame.size.height / 2
    }
    
    private func fetchUser() {
        
        FirestoreManager.shared.getUserInfoFrom(currentUserUid) { [weak self] user in
            self?.currentUser = user
        }
    }
    
    private func setupViews() {
        view.backgroundColor = .white
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(endEditing)))
        
        // add subviews
        view.addSubview(mapView)
        view.addSubview(dataTextView)
        view.addSubview(bioLabel)
        view.addSubview(bioTextView)
        view.addSubview(bioButton)
        
        // x, y, w, h
        mapView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 12).isActive = true
        mapView.topAnchor.constraint(equalTo: view.topAnchor, constant: 12).isActive = true
        mapView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1/3).isActive = true
        mapView.heightAnchor.constraint(equalTo: mapView.widthAnchor).isActive = true
        
        dataTextView.leftAnchor.constraint(equalTo: mapView.rightAnchor, constant: 12).isActive = true
        dataTextView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -12).isActive = true
        dataTextView.centerYAnchor.constraint(equalTo: mapView.centerYAnchor).isActive = true
        dataTextView.heightAnchor.constraint(equalTo: mapView.heightAnchor).isActive = true
        
        bioLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        bioLabel.topAnchor.constraint(equalTo: mapView.bottomAnchor, constant: 24).isActive = true
        bioLabel.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -30).isActive = true
        bioLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        bioTextView.centerXAnchor.constraint(equalTo: bioLabel.centerXAnchor).isActive = true
        bioTextView.topAnchor.constraint(equalTo: bioLabel.bottomAnchor, constant: 4).isActive = true
        bioTextView.widthAnchor.constraint(equalTo: bioLabel.widthAnchor, constant: 8).isActive = true
        bioTextView.heightAnchor.constraint(equalTo: bioTextView.widthAnchor, multiplier: 1/2).isActive = true
        
        bioButton.centerXAnchor.constraint(equalTo: bioTextView.centerXAnchor).isActive = true
        bioButton.topAnchor.constraint(equalTo: bioTextView.bottomAnchor, constant: 12).isActive = true
        bioButton.widthAnchor.constraint(equalTo: bioTextView.widthAnchor, constant: -20).isActive = true
        bioButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    @objc private func handleBioButton() {
        
        if bioTextView.text.trimmingCharacters(in: .whitespacesAndNewlines) == bioPlaceholder || bioTextView.text.trimmingCharacters(in: .whitespacesAndNewlines) == lastBio.trimmingCharacters(in: .whitespacesAndNewlines) || bioTextView.text.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            return
        }
        
        if bioTextView.text.count < 30 {
            mainAlert(title: "Oops!".localized(), message: "Please extend text at least to 30 characters long.".localized())
            return
        }
        
        guard let currentUserUid = currentUserUid else {
            return
        }
        
        FirestoreManager.shared.updateBio(for: currentUserUid, bio: bioTextView.text) { [weak self] success in
            
            if !success {
                self?.mainAlert(title: "Oops!".localized(), message: "An unexpected error occurred.".localized())
                return
            }
            
            self?.bioTextView.text = self?.bioPlaceholder
            self?.bioTextView.textColor = .mainGray
            
            self?.mainAlert(title: "Success!".localized(), message: "User data has been updated.".localized())
        }
        
//        DatabaseManager.shared.updateBio(for: currentUserUid, bio: bioTextView.text) { [weak self] success in
//
//            if !success {
//                self?.mainAlert(title: "Oops!".localized(), message: "An unexpected error occurred.".localized())
//                return
//            }
//
//            self?.bioTextView.text = self?.bioPlaceholder
//            self?.bioTextView.textColor = .mainGray
//
//            self?.mainAlert(title: "Success!".localized(), message: "User data has been updated.".localized())
//        }
    }
}

extension UserDataController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if textView.textColor == .mainGray {
            textView.text = nil
            textView.textColor = .secondColor
        }
    }
}

// MARK: - Liked controller
class LikedController: UIViewController {
    
    var profileController: ProfileController?
    
    var pets = [Pet]() {
        didSet {
            
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    let cellId = "cellId"
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 20
        layout.minimumInteritemSpacing = 20
        layout.sectionInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .clear
        cv.showsVerticalScrollIndicator = false
        cv.showsHorizontalScrollIndicator = false
        
        cv.delegate = self
        cv.dataSource = self
        cv.register(PetCell.self, forCellWithReuseIdentifier: cellId)
        
        return cv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        fetchLiked()
    }
    
    private func setupViews() {
        view.backgroundColor = .white
        navigationController?.navigationBar.isHidden = true
        
        // add subviews
        view.addSubview(collectionView)
        
        // x, y, w, h
        collectionView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        collectionView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -40).isActive = true
    }
    
    private func fetchLiked() {
        
        guard let currentUserUid = currentUserUid else {
            return
        }
        
        FirestoreManager.shared.getLikedPetsFromUser(with: currentUserUid) { pets in
            self.pets = pets
        }
    }
}

extension LikedController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if pets.count == 0 {
            collectionView.setEmptyMessage("No likes yet. 🐶".localized())
        } else {
            collectionView.restore()
        }
        
        return pets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = collectionView.frame.size
        let padding: CGFloat = 20
        
        let width = (size.width - padding) / 2
        return CGSize(width: width, height: width * 1.3)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as? PetCell else { return UICollectionViewCell() }
        cell.pet = pets[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        cell.alpha = 0
        cell.layer.transform = CATransform3DMakeScale(0.1, 0.1, 1)
        
        UIView.animate(withDuration: 1.5) {
            cell.alpha = 1
            cell.layer.transform = CATransform3DMakeScale(1, 1, 1)
        }
    }
}
