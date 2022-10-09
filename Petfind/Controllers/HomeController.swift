//
//  HomeController.swift
//  Petfind
//
//  Created by Didami on 22/01/22.
//

import UIKit
import Shuffle_iOS
import FirebaseFirestore
import Instructions

class HomeController: UIViewController {
    
    let coachMarksController = CoachMarksController()
    let pointOfInterest = UIView()
    
    var parentMarksHavePresented = false {
        didSet {
            
            if parentMarksHavePresented {
                coachMarksController.start(in: .window(over: self))
            }
        }
    }
    
    var petIndex = [PetType.Dog.rawValue: 0, PetType.Cat.rawValue: 0, PetType.Other.rawValue: 0]
    var presentedPetsCount = [PetType.Dog.rawValue: 0, PetType.Cat.rawValue: 0, PetType.Other.rawValue: 0]
    var lastPetsIds: [String: String?] = [PetType.Dog.rawValue: nil, PetType.Cat.rawValue: nil, PetType.Other.rawValue: nil]
    
    var hasLoaded = [PetType.Dog.rawValue: false, PetType.Cat.rawValue: false, PetType.Other.rawValue: false]
    
    // TODO: - Create var for each pet type: [Pet], reload swipe card stack for each change.
    var dogs = [Pet]()
    var cats = [Pet]()
    var others = [Pet]()
    
    private func selectedPets() -> [Pet] {
        
        if selectedIndex == 0 {
            return dogs
        } else if selectedIndex == 1 {
            return cats
        } else {
            return others
        }
    }
    
    private func appendPets(_ pets: [Pet], type: String) {
        
        if type == PetType.Dog.rawValue {
            dogs = pets
        } else if type == PetType.Cat.rawValue {
            cats = pets
        } else {
            others = pets
        }
    }
    
    var currentUser: User?
    
    var selectedIndex = 0 {
        didSet {
            
            selectedViewLeft?.isActive = false
            selectedViewCenterXAnchor?.isActive = false
            selectedViewRight?.isActive = false
            
            if selectedIndex == 0 {
                
                selectedViewLeft?.isActive = true
                
            } else if selectedIndex == 1 {
                
                selectedViewCenterXAnchor?.isActive = true
                
            } else if selectedIndex == 2 {
                
                selectedViewRight?.isActive = true
                
            }
            
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    var selectedViewLeft: NSLayoutConstraint?
    var selectedViewRight: NSLayoutConstraint?
    var selectedViewCenterXAnchor: NSLayoutConstraint?
    
    lazy var segmentedControl: PlainSegmentedControl = {
        let sc = PlainSegmentedControl(items: ["Dogs".localized(), "Cats".localized(), "Others".localized()])
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
        selectedView.widthAnchor.constraint(equalTo: topView.widthAnchor, multiplier: 1/3).isActive = true
        
        selectedViewLeft = selectedView.leftAnchor.constraint(equalTo: topView.leftAnchor)
        selectedViewRight = selectedView.rightAnchor.constraint(equalTo: topView.rightAnchor)
        selectedViewCenterXAnchor = selectedView.centerXAnchor.constraint(equalTo: topView.centerXAnchor)
        
        selectedViewLeft?.isActive = true
        selectedViewRight?.isActive = false
        selectedViewCenterXAnchor?.isActive = false
        
        sc.addTarget(self, action: #selector(handleSegmentedControl(_:)), for: .valueChanged)
        sc.isUserInteractionEnabled = false
        
        return sc
    }()
    
    let emptyLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = .mainFont(ofSize: 18, weight: .semibold)
        lbl.textColor = .white
        lbl.textAlignment = .center
        lbl.text = "No pets available.".localized()
        return lbl
    }()
    
    lazy var emptyView: UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .lightGray.withAlphaComponent(0.4)
        container.layer.masksToBounds = true
        container.layer.cornerRadius = 12
        container.alpha = 0
        
        container.addSubview(emptyLabel)
        
        emptyLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor).isActive = true
        emptyLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor).isActive = true
        emptyLabel.widthAnchor.constraint(equalTo: container.widthAnchor, constant: -50).isActive = true
        emptyLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        return container
    }()
    
    lazy var swipeCardStack: SwipeCardStack = {
        let stack = SwipeCardStack()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.backgroundColor = .clear
        stack.cardStackInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        stack.delegate = self
        stack.dataSource = self
        
        stack.alpha = 0
        
        return stack
    }()
    
    lazy var buttonStackView: ButtonStackView = {
        let sv = ButtonStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.delegate = self
        return sv
    }()
    
    var parentController: ParentController?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        
        guard let location = currentUser?.location else { return }
        loadData(petType: getPetTypeFor(selectedIndex), petLocation: location)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        coachMarksController.stop(immediately: true)
    }
    
    private func getPetTypeFor(_ index: Int) -> String {
        
        return selectedIndex == 0 ? PetType.Dog.rawValue : selectedIndex == 1 ? PetType.Cat.rawValue : PetType.Other.rawValue
    }
    
    var lastCursors = [String: DocumentSnapshot]()
    var cursors = [String: DocumentSnapshot]()
    var pageSize = 5 //10
    
    private func loadData(petType: String, petLocation: String, cursor: DocumentSnapshot? = nil) {
        
        guard let parentController = parentController else { return }
        parentController.presentLoadingView()
        
        // TODO: - FIX: get start point cursor and save
        FirestoreManager.shared.startPetsFetch(type: petType, location: petLocation, pageSize: pageSize, cursor: cursor) { [weak self] pets, newCursor, lastCursor  in
            
            guard let self = self else {
                return
            }
            
            // set cursors and pets
            self.lastCursors[self.getPetTypeFor(self.selectedIndex)] = lastCursor
            self.cursors[self.getPetTypeFor(self.selectedIndex)] = newCursor
            self.appendPets(pets, type: petType)
            
            DispatchQueue.main.async {
                self.swipeCardStack.reloadData()
                self.segmentedControl.isUserInteractionEnabled = true
            }
            
            // update presented count value
            guard var presentedCount = self.presentedPetsCount[petType] else {
                return
            }
            
            if presentedCount >= self.pageSize || presentedCount == 0 {
                
                if self.hasLoaded[petType] == false {
                    presentedCount += pets.count
                    self.presentedPetsCount[petType] = presentedCount
                    self.hasLoaded[petType] = true
                }
            }
            
            // set message if there are no pets
            if pets.count == 0 {
                
                UIView.animate(withDuration: 0.4) {
                    self.emptyView.alpha = 1
                }
            }
            
            parentController.removeLoadingView()
            
            // TODO: - Animations
            self.animations()
        }
    }
    
    private func continueData(petType: String, petLocation: String) {
        
        guard let parentController = parentController else { return }
        parentController.presentLoadingView()
        
        FirestoreManager.shared.continuePetsFetch(type: petType, location: petLocation, cursor: cursors[getPetTypeFor(selectedIndex)], pageSize: pageSize) { [weak self] pets, newCursor, lastCursor in
            
            guard let self = self else {
                return
            }
            
            // set cursor and pets
            self.lastCursors[self.getPetTypeFor(self.selectedIndex)] = lastCursor
            self.cursors[self.getPetTypeFor(self.selectedIndex)] = newCursor
            self.appendPets(pets, type: petType)
            
            DispatchQueue.main.async {
                self.swipeCardStack.reloadData()
                self.segmentedControl.isUserInteractionEnabled = true
            }
            
            // update presented count value
            guard var presentedCount = self.presentedPetsCount[petType] else {
                return
            }
            
            if presentedCount >= self.pageSize || presentedCount == 0 {
                presentedCount += pets.count
                self.presentedPetsCount[petType] = presentedCount
            }
            
            // set message if there are no pets
            if pets.count == 0 {
                
                UIView.animate(withDuration: 0.4) {
                    self.emptyView.alpha = 1
                }
            }
            
            parentController.removeLoadingView()
            
            // TODO: - Animations
            self.animations()
        }
    }
    
    private func setupViews() {
        view.backgroundColor = .white
        navigationController?.navigationBar.isHidden = true
        
        coachMarksController.delegate = self
        coachMarksController.dataSource = self
        
        // add subviews
        view.addSubview(segmentedControl)
        view.addSubview(emptyView)
        view.addSubview(swipeCardStack)
        view.addSubview(buttonStackView)
        view.addSubview(pointOfInterest)
        
        // x, y, w, h
        segmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        segmentedControl.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        segmentedControl.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        segmentedControl.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        buttonStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        buttonStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10).isActive = true
        buttonStackView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -40).isActive = true
        buttonStackView.heightAnchor.constraint(equalToConstant: 70).isActive = true
        
        swipeCardStack.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        swipeCardStack.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 10).isActive = true
        swipeCardStack.widthAnchor.constraint(equalTo: buttonStackView.widthAnchor).isActive = true
        swipeCardStack.bottomAnchor.constraint(equalTo: buttonStackView.topAnchor, constant: -20).isActive = true
        
        emptyView.centerXAnchor.constraint(equalTo: swipeCardStack.centerXAnchor).isActive = true
        emptyView.centerYAnchor.constraint(equalTo: swipeCardStack.centerYAnchor).isActive = true
        emptyView.widthAnchor.constraint(equalTo: swipeCardStack.widthAnchor).isActive = true
        emptyView.heightAnchor.constraint(equalTo: swipeCardStack.heightAnchor).isActive = true
    }
    
    private func animations() {
        
        UIView.animate(withDuration: 0.8) { [self] in
            swipeCardStack.alpha = 1
        }
    }
    
    @objc private func handleSegmentedControl(_ sender: UISegmentedControl) {
        selectedIndex = sender.selectedSegmentIndex
        
        UIView.animate(withDuration: 0.6) {
            self.emptyView.alpha = 0
            self.swipeCardStack.alpha = 0
        } completion: { [weak self] _ in
            
            guard let strongSelf = self else {
                return
            }
            
            let type = strongSelf.getPetTypeFor(sender.selectedSegmentIndex)
            
            // TODO: - FIX: use start point cursor
            guard let location = strongSelf.parentController?.currentUser?.location else { return }
            
            if strongSelf.selectedPets().isEmpty {
                // pets have not been fetched before
                strongSelf.loadData(petType: type, petLocation: location, cursor: strongSelf.lastCursors[type])
            } else {
                // pets have been fetched before
                strongSelf.swipeCardStack.reloadData()
                
                UIView.animate(withDuration: 0.6) {
                    strongSelf.swipeCardStack.alpha = 1
                }
            }
        }
    }
    
    @objc private func handleButton(_ sender: UIButton) {
        
        guard let card = swipeCardStack.card(forIndexAt: sender.tag - 1) as? PetSwipeCard else { return }
        
        let petInfoController = PetInfoController()
        petInfoController.pet = selectedPets()[sender.tag - 1]
        petInfoController.attributedText = card.petFooter.textView.attributedText
        present(petInfoController, animated: true, completion: nil)
    }
}

extension HomeController: SwipeCardStackDelegate, SwipeCardStackDataSource, ButtonStackViewDelegate {
    
    private func setLastPetId(_ id: String) {
        lastPetsIds[getPetTypeFor(selectedIndex)] = id
    }
    
    // MARK: - Swipe Card Stack Delegate
    func numberOfCards(in cardStack: SwipeCardStack) -> Int {
        return selectedPets().count
    }
    
    func cardStack(_ cardStack: SwipeCardStack, cardForIndexAt index: Int) -> SwipeCard {
        
        #warning("Print statement should be removed.")
        print("index: \(index)")
        
        let card = PetSwipeCard()
        card.pet = selectedPets()[index]
        card.petFooter.button.tag = index + 1
        card.petFooter.button.addTarget(self, action: #selector(handleButton(_:)), for: .touchUpInside)
        
        return card
    }
    
    func cardStack(_ cardStack: SwipeCardStack, didSwipeCardAt index: Int, with direction: SwipeDirection) {
        
        // TODO: - Optimize paginated downloads
        // get pet
        let pet = selectedPets()[index]
        
        // get and save ids
        guard let userId = currentUserUid, let petId = pet.petId else { return }
        setLastPetId(petId)
        
        // save pass pet id to user defaults
        PetFilterManager.shared.passPet(with: petId, userId: userId)
        
        // execute specific actions for directions
        if direction == .right {
            
            FirestoreManager.shared.likePetWith(id: petId) { success in
                
                if !success {
                    cardStack.shift(animated: true)
                    return
                }
            }
            
//            DatabaseManager.shared.likePetWith(id: petId, type: petType) { success in
//            }
        }
        
        // get pet index and incrase
        let petType = getPetTypeFor(selectedIndex)
        
        guard var indexForPet = petIndex[petType] else {
            return
        }
        
        indexForPet += 1
        
        petIndex[petType] = indexForPet
        
        // remove pet from array and reload data
        dogs.removeAll(where: { $0.petId == pet.petId })
        cats.removeAll(where: { $0.petId == pet.petId })
        others.removeAll(where: { $0.petId == pet.petId })
        
        swipeCardStack.reloadData()
        
//        print("\(petIndex[petType]) == \(presentedPetsCount[petType])")
        // fetch next pets if pet index is equal to the presented pets count
//        if petIndex[getPetTypeFor(selectedIndex)] == presentedPetsCount[petType] {
//            guard let location = parentController?.currentUser?.location else { return }
//            continueData(petType: petType, petLocation: location)
//        }
    }
    
    // MARK: - CONSIDER
    func didSwipeAllCards(_ cardStack: SwipeCardStack) {
        let petType = getPetTypeFor(selectedIndex)
        guard let location = parentController?.currentUser?.location else { return }
        continueData(petType: petType, petLocation: location)
    }
    
    // MARK: - Button Stack View Delegate
    func didTapButton(button: StackButton) {
        
        if selectedPets().isEmpty {
            return
        }
        
        switch button.tag {
        case 1:
            // pass
            swipeCardStack.swipe(.left, animated: true)
        case 2:
            // super like
            swipeCardStack.swipe(.up, animated: true)
        case 3:
            // like
            swipeCardStack.swipe(.right, animated: true)
        case 4:
            // report
            swipeCardStack.swipe(.down, animated: true)
        default:
            break
        }
    }
}

extension HomeController: CoachMarksControllerDelegate, CoachMarksControllerDataSource {
    
    func numberOfCoachMarks(for coachMarksController: CoachMarksController) -> Int {
        return 4
    }
    
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkAt index: Int) -> CoachMark {
        
        switch index {
        case 0:
            pointOfInterest.frame = swipeCardStack.frame
        case 1:
            pointOfInterest.frame = buttonStackView.frame
        case 2:
            pointOfInterest.frame = segmentedControl.frame
        case 3:
            pointOfInterest.frame = .zero
            pointOfInterest.center = view.center
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
        
        coachViews.bodyView.hintLabel.font = .mainFont(ofSize: 16, weight: .regular)
        coachViews.bodyView.nextLabel.font = .mainFont(ofSize: 14, weight: .regular)
        
        coachViews.bodyView.hintLabel.textColor = .secondColor
        coachViews.bodyView.nextLabel.textColor = .secondColor
        
        var hintText = ""
        let nextText = "Got it"
        
        switch index {
        case 0:
            hintText = "Pets appear on this stack, swipe in different directions to make a decision."
        case 1:
            hintText = "Or use buttons below"
        case 2:
            hintText = "Filter by different types of pets"
        case 3:
            hintText = "Thanks for your download.\n- Didami ♥️"
        default:
            break
        }
        
        coachViews.bodyView.hintLabel.text = hintText.localized()
        coachViews.bodyView.nextLabel.text = nextText.localized()
        
        return (bodyView: coachViews.bodyView, arrowView: coachViews.arrowView)
    }
    
    func coachMarksController(_ coachMarksController: CoachMarksController, didEndShowingBySkipping skipped: Bool) {
        UserDefaults.standard.set(true, forKey: UserDefaultsKey.skipCoachMarks1.rawValue)
    }
}

/*
  _____       _____
 /( )   \=== /     \----------------.
|       |   |       |--------------  \
|       |   |       |              \_/
 \_____/     \_____/
 
 */
