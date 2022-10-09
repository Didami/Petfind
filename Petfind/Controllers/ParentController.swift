//
//  ParentController.swift
//  Petfind
//
//  Created by Didami on 25/01/22.
//

import UIKit
import Instructions

class ParentController: UIViewController {
    
    enum ParentTabIndex: Int {
        case firstChild = 0
        case secondChild = 1
        case thirdChild = 2
        case fourthChild = 3
        case fifthChild = 4
    }
    
    var currentController: UIViewController?
    
    let homeController = HomeController()
    let adoptionsController = AdoptionsController()
    let profileController = ProfileController()
    let adminController = AdminController()
    let aboutController = AboutController()
    
    var currentUser: User?
    
    let navBarHeight = (Screen.height / 8) + 32
    
    let icon = UIImageView(image: UIImage(named: "glyph"))
    let leftButton = UIButton(type: .system)
    let rightButton = UIButton(type: .system)
    
    lazy var navBar: UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .mainColor
        
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.tintColor = .secondColor
        icon.contentMode = .scaleAspectFit
        
        leftButton.translatesAutoresizingMaskIntoConstraints = false
        leftButton.tintColor = .secondColor
        leftButton.setImage(UIImage(systemName: "line.3.horizontal.circle.fill"), for: .normal)
        leftButton.addTarget(self, action: #selector(handleLeftButton), for: .touchUpInside)
        
        rightButton.translatesAutoresizingMaskIntoConstraints = false
        rightButton.tintColor = .secondColor
        rightButton.setImage(UIImage(systemName: "paperplane.fill"), for: .normal)
        rightButton.addTarget(self, action: #selector(handleRightButton), for: .touchUpInside)
        
        container.addSubview(icon)
        container.addSubview(leftButton)
        container.addSubview(rightButton)
        
        icon.centerXAnchor.constraint(equalTo: container.centerXAnchor).isActive = true
        icon.topAnchor.constraint(equalTo: container.safeAreaLayoutGuide.topAnchor, constant: 4).isActive = true
        icon.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -12).isActive = true
        icon.widthAnchor.constraint(equalTo: icon.heightAnchor).isActive = true
        
        leftButton.leftAnchor.constraint(equalTo: container.leftAnchor, constant: 12).isActive = true
        leftButton.topAnchor.constraint(equalTo: icon.topAnchor).isActive = true
        leftButton.bottomAnchor.constraint(equalTo: icon.bottomAnchor).isActive = true
        leftButton.widthAnchor.constraint(equalTo: icon.widthAnchor).isActive = true
        
        rightButton.rightAnchor.constraint(equalTo: container.rightAnchor, constant: -12).isActive = true
        rightButton.topAnchor.constraint(equalTo: icon.topAnchor).isActive = true
        rightButton.bottomAnchor.constraint(equalTo: icon.bottomAnchor).isActive = true
        rightButton.widthAnchor.constraint(equalTo: icon.widthAnchor).isActive = true
        
        return container
    }()
    
    lazy var contentView: UIView = {
        let cv = UIView()
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()
    
    let sideBar = SideMenuBar()
    let loadingView = LoadingView()
    
    let coachMarksController = CoachMarksController()
    let pointOfInterest = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        
        fetchUserData {
            
            // set parent controller to childs
            self.homeController.parentController = self
            self.adoptionsController.parentController = self
            
            self.displayCurrentTab(ParentTabIndex.firstChild.rawValue)
        }
    }
    
    private func fetchUserData(completion: @escaping (() -> Void)) {
        
        guard let currentUserUid = currentUserUid else { return }
        FirestoreManager.shared.getUserInfoFrom(currentUserUid) { user in
            self.currentUser = user
            
            self.homeController.currentUser = user
            self.adoptionsController.currentUser = user
            
            completion()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupSideBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if UserDefaults.standard.bool(forKey: UserDefaultsKey.skipCoachMarks1.rawValue) == true {
            return
        }
        
        coachMarksController.start(in: .window(over: self))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        coachMarksController.stop(immediately: true)
        
        if let currentViewController = currentController {
            currentViewController.viewWillDisappear(animated)
        }
    }
    
    func showChatController(for user: User, pet: Pet) {
        let chatLogController = ChatLogController()
        chatLogController.isChatPartnerInterested = true
        chatLogController.user = user
        chatLogController.pet = pet
        navigationController?.pushViewController(chatLogController, animated: true)
    }
    
    func showChatController(for user: User) {
        let chatLogController = ChatLogController()
        chatLogController.user = user
        navigationController?.pushViewController(chatLogController, animated: true)
    }
    
    public func presentLoadingView() {
        loadingView.presentIn(self, backgroundColor: nil)
    }
    
    public func removeLoadingView() {
        loadingView.remove(completion: nil)
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
            
            self.displayCurrentTab(tabIndex)
            
            UIView.animate(withDuration: 0.5) {
                self.contentView.alpha = 1
            }
        }
    }
    
    private func displayCurrentTab(_ tabIndex: Int) {
        
        if let vc = viewControllerForSelectedSegmentIndex(tabIndex) {
            
            self.addChild(vc)
            vc.didMove(toParent: self)
            vc.view.frame = self.contentView.bounds
            self.contentView.addSubview(vc.view)
            self.currentController = vc
            
        }
    }
    
    private func viewControllerForSelectedSegmentIndex(_ index: Int) -> UIViewController? {
            
        var vc: UIViewController?
            
        switch index {
        case ParentTabIndex.firstChild.rawValue:
            vc = homeController
        case ParentTabIndex.secondChild.rawValue:
            vc = adoptionsController
        case ParentTabIndex.thirdChild.rawValue:
            vc = profileController
        case ParentTabIndex.fourthChild.rawValue:
            vc = adminController
        case ParentTabIndex.fifthChild.rawValue:
            vc = aboutController
        default:
            return nil
        }
        
        return vc
    }
    
    func presentAuth() {
        let vc = UINavigationController(rootViewController: AuthController())
        vc.modalTransitionStyle = .flipHorizontal
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }
    
    @objc private func handleLeftButton() {
        sideBar.presentIn(self)
    }
    
    @objc private func handleRightButton() {
        navigationController?.pushViewController(MessagesController(), animated: true)
    }
    
    @objc private func handleSignOut() {
        
        signOut { success in
            
            if !success {
                print("error logging out")
                return
            }
            
            self.presentAuth()
        }
    }
    
    private func setupViews() {
        view.backgroundColor = .white
        navigationController?.navigationBar.isHidden = true
        
        coachMarksController.delegate = self
        coachMarksController.dataSource = self
        
        // add subviews
        view.addSubview(navBar)
        view.addSubview(contentView)
        view.addSubview(pointOfInterest)
        
        // x, y, w, h
        navBar.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        navBar.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        navBar.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        navBar.heightAnchor.constraint(equalToConstant: navBarHeight).isActive = true
        
        contentView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        contentView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        contentView.topAnchor.constraint(equalTo: navBar.bottomAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    private func setupSideBar() {
        
        let sideMenuItems = [
            StackItem(name: "Home".localized(), icon: UIImage(systemName: "house.fill"), action: {
                self.switchToTab(ParentTabIndex.firstChild.rawValue)
            }),
            
            StackItem(name: "Adoptions".localized(), icon: UIImage(systemName: "pawprint.fill"), action: {
                self.switchToTab(ParentTabIndex.secondChild.rawValue)
            }),
            
            StackItem(name: "Profile".localized(), icon: UIImage(systemName: "person.fill"), action: {
                self.switchToTab(ParentTabIndex.thirdChild.rawValue)
            }),
            
            StackItem(name: "About".localized(), icon: UIImage(systemName: "info.circle.fill"), action: {
                self.switchToTab(ParentTabIndex.fifthChild.rawValue)
            }),
            
            StackItem(name: "Log out".localized(), icon: UIImage(systemName: "rectangle.portrait.and.arrow.right.fill"), action: {
                
                self.handleSignOut()
            })
        ]
        
        self.sideBar.sideMenuItems = sideMenuItems
        
        isUserAdmin(userId: currentUserUid) { isAdmin in
            
            if isAdmin {
                
                self.sideBar.sideMenuItems.insert(StackItem(name: "Admin".localized(), icon: UIImage(systemName: "person.crop.circle.badge.checkmark")) {
                    self.switchToTab(ParentTabIndex.fourthChild.rawValue)
                }, at: 3)
            }
            
            self.sideBar.collectionView.selectItem(at: IndexPath(item: self.sideBar.selectedItem, section: 0), animated: false, scrollPosition: UICollectionView.ScrollPosition(rawValue: 0))
        }
    }
}

extension ParentController: CoachMarksControllerDelegate, CoachMarksControllerDataSource {
    
    func numberOfCoachMarks(for coachMarksController: CoachMarksController) -> Int {
        return 6
    }
    
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkAt index: Int) -> CoachMark {
        
        switch index {
        case 0:
            pointOfInterest.frame = icon.frame
        case 1:
            pointOfInterest.frame = icon.frame
        case 2:
            pointOfInterest.frame = navBar.frame
        case 3:
            pointOfInterest.frame = rightButton.frame
        case 4:
            pointOfInterest.frame = leftButton.frame
        case 5:
            pointOfInterest.frame = icon.frame
        default:
            break
        }
        
        return coachMarksController.helper.makeCoachMark(for: pointOfInterest)
    }
    
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkViewsAt index: Int, madeFrom coachMark: CoachMark) -> (bodyView: (UIView & CoachMarkBodyView), arrowView: (UIView & CoachMarkArrowView)?) {
        
        let coachViews = coachMarksController.helper.makeDefaultCoachViews(
            withArrow: true,
            arrowOrientation: coachMark.arrowOrientation
        )
        
        coachViews.bodyView.hintLabel.font = .mainFont(ofSize: 17, weight: .regular)
        coachViews.bodyView.nextLabel.font = .mainFont(ofSize: 15, weight: .regular)
        
        coachViews.bodyView.hintLabel.textColor = .secondColor
        coachViews.bodyView.nextLabel.textColor = .secondColor
        
        var hintText = ""
        var nextText = "Got it"
        
        switch index {
        case 0:
            hintText = "Hey there! Welcome to Petfind"
            nextText = "Next"
        case 1:
            hintText = "We will show you how to use Petfind."
        case 2:
            hintText = "This is the main bar"
        case 3:
            hintText = "Use direct messages to contact other users."
        case 4:
            hintText = "Use this button to open the Side Bar."
        case 5:
            hintText = "Now we will teach you about the Home Menu."
        default:
            break
        }
        
        coachViews.bodyView.hintLabel.text = hintText.localized()
        coachViews.bodyView.nextLabel.text = nextText.localized()
        
        return (bodyView: coachViews.bodyView, arrowView: coachViews.arrowView)
    }
    
    func coachMarksController(_ coachMarksController: CoachMarksController, didEndShowingBySkipping skipped: Bool) {
        homeController.parentMarksHavePresented = true
    }
}

/*
  _____       _____
 /( )   \=== /     \----------------.
|       |   |       |--------------  \
|       |   |       |              \_/
 \_____/     \_____/
 
 */
