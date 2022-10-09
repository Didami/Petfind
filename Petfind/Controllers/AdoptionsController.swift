//
//  AdoptionsController.swift
//  Petfind
//
//  Created by Didami on 25/01/22.
//

import UIKit
import Instructions

class AdoptionsController: UIViewController {
    
    enum AdoptionsTabIndex: Int {
        case firstChild = 0
        case secondChild = 1
    }
    
    var parentController: ParentController?
    
    var currentController: UIViewController?
    
    let newPetController = NewPetController()
    let petsController = PetsController()
    
    var currentUser: User?
    
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
        let sc = PlainSegmentedControl(items: ["Put Up".localized(), "My adoptions".localized()])
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
        displayCurrentTab(AdoptionsTabIndex.firstChild.rawValue, completion: nil)
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
        case AdoptionsTabIndex.firstChild.rawValue:
            vc = newPetController
        case AdoptionsTabIndex.secondChild.rawValue:
            vc = petsController
        default:
            return nil
        }
        
        return vc
    }
    
    private func setupViews() {
        view.backgroundColor = .white
        navigationController?.navigationBar.isHidden = true
        
        newPetController.adoptionsController = self
        petsController.adoptionsController = self
        
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

// MARK: - New Pet Controller
class NewPetController: UIViewController {
    
    var adoptionsController: AdoptionsController?
    
    lazy var mainHeight = (Screen.height + Screen.width) - 60
    
    lazy var contentViewSize = CGSize(width: self.view.frame.width, height: mainHeight / 2)
    
    let coachMarksController = CoachMarksController()
    let pointOfInterest = UIView()
    
    lazy var scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.backgroundColor = .white
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.contentSize = contentViewSize
        sv.showsVerticalScrollIndicator = false
        sv.alwaysBounceVertical = true
        sv.delegate = self
        return sv
    }()
    
    lazy var containerView: UIView = {
        let view = UIView()
        view.frame.size = contentViewSize
        view.backgroundColor = .clear
        return view
    }()
    
    let cellId = "cellId"
    
    var petImages = [UIImage]() {
        didSet {
            
            UIView.animate(withDuration: 0.3) {
                self.pageControl.numberOfPages = self.petImages.count + 1
            }
            
            imageCollection.reloadData()
            
            collectionHeight?.isActive = false
            
            if petImages.count == 0 {
                
                keyboardOffset = 200
                
                contentViewSize.height = mainHeight / 2
                
                collectionHeight = imageCollection.heightAnchor.constraint(equalToConstant: 100)
                collectionHeight?.isActive = true
                
            } else {
                
                keyboardOffset = 300
                
                contentViewSize.height = mainHeight
                
                collectionHeight = imageCollection.heightAnchor.constraint(equalTo: imageCollection.widthAnchor, multiplier: 5/4)
                collectionHeight?.isActive = true
                
            }
            
            scrollView.contentSize = contentViewSize
            containerView.frame.size = contentViewSize
            
            UIView.animate(withDuration: 0.5) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    var lastPetImageType = ""
    
    lazy var imageCollection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = .zero
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.showsVerticalScrollIndicator = false
        cv.showsHorizontalScrollIndicator = false
        cv.isPagingEnabled = true
        
        cv.delegate = self
        cv.dataSource = self
        cv.register(PetImageCell.self, forCellWithReuseIdentifier: cellId)
        
        return cv
    }()
    
    let pageControl: UIPageControl = {
        let pc = UIPageControl()
        pc.translatesAutoresizingMaskIntoConstraints = false
        pc.currentPage = 1
        pc.numberOfPages = 1
        pc.currentPageIndicatorTintColor = .secondColor.withAlphaComponent(0.8)
        pc.pageIndicatorTintColor = .secondColor.withAlphaComponent(0.4)
        pc.backgroundColor = .mainColor.withAlphaComponent(0.4)
        pc.isUserInteractionEnabled = false
        return pc
    }()
    
    lazy var stackView: UIStackView = {
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .vertical
        sv.distribution = .fillEqually
        sv.spacing = 30
        
        sv.addArrangedSubview(nameTextField)
        sv.addArrangedSubview(typeTextField)
        sv.addArrangedSubview(breedTextField)
        sv.addArrangedSubview(childStack)
        
        sv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(endEditing)))
        
        return sv
    }()
    
    lazy var childStack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.distribution = .fillEqually
        sv.spacing = 30
        
        sv.addArrangedSubview(genderTextField)
        sv.addArrangedSubview(ageTextField)
        
        return sv
    }()
    
    let nameTextField: FormTextField = {
        let tf = FormTextField()
        tf.title = "Name".localized()
        tf.subtitle = "Enter pet name ...".localized()
        tf.type = .open
        return tf
    }()
    
    let typeTextField: FormTextField = {
        let tf = FormTextField()
        tf.title = "Type".localized()
        tf.subtitle = "Dog/Cat/Other ...".localized()
        tf.type = .closed
        tf.pickerTitles = [PetType.Dog.rawValue, PetType.Cat.rawValue, PetType.Other.rawValue]
        return tf
    }()
    
    let breedTextField: FormTextField = {
        let tf = FormTextField()
        tf.title = "Breed".localized()
        tf.subtitle = "Bulldog/Poodle/Etc ...".localized()
        tf.type = .open
        return tf
    }()
    
    let genderTextField: FormTextField = {
        let tf = FormTextField()
        tf.title = "Gender".localized()
        tf.subtitle = "Male or female?".localized()
        tf.type = .closed
        tf.pickerTitles = [Gender.Male.rawValue, Gender.Female.rawValue]
        return tf
    }()
    
    let ageTextField: FormTextField = {
        let tf = FormTextField()
        tf.title = "Age".localized()
        tf.subtitle = "ex: 2 (years old)".localized()
        tf.type = .open
        tf.textField.keyboardType = .decimalPad
        return tf
    }()
    
    lazy var rulesButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("Rules".localized(), for: .normal)
        btn.setTitleColor(.mainColor, for: .normal)
        btn.titleLabel?.font = .mainFont(ofSize: 18, weight: .semibold)
        btn.backgroundColor = .secondColor
        btn.addTarget(self, action: #selector(handleRulesButton), for: .touchUpInside)
        return btn
    }()
    
    lazy var doneButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("Done".localized(), for: .normal)
        btn.setTitle("Loading ...".localized(), for: .selected)
        btn.setTitleColor(.secondColor, for: .normal)
        btn.titleLabel?.font = .mainFont(ofSize: 18, weight: .semibold)
        btn.backgroundColor = .mainColor
        btn.addTarget(self, action: #selector(handleDoneButton), for: .touchUpInside)
        return btn
    }()
    
    lazy var buttonStack: UIStackView = {
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .horizontal
        sv.distribution = .fillEqually
        
        sv.addArrangedSubview(rulesButton)
        sv.addArrangedSubview(doneButton)
        
        return sv
    }()
    
    let imagePicker = UIImagePickerController()
    
    var keyboardPresent = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if UserDefaults.standard.bool(forKey: UserDefaultsKey.skipCoachMarks2.rawValue) == true {
            return
        }
        
        coachMarksController.start(in: .window(over: self))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        
        coachMarksController.stop(immediately: true)
    }
    
    var keyboardOffset: CGFloat = 200
    
    @objc func keyboardWillShow(notification: NSNotification) {
        
        if keyboardPresent {
            return
        }
        
        adoptionsController?.segmentedControl.isUserInteractionEnabled = false
        
        self.view.frame.origin.y -= keyboardOffset
        keyboardPresent = true
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        
        if !keyboardPresent {
            return
        }
        
        adoptionsController?.segmentedControl.isUserInteractionEnabled = true
        
        self.view.frame.origin.y += keyboardOffset
        keyboardPresent = false
    }
    
    private func restore() {
        
        UIView.animate(withDuration: 0.3) {
            self.view.alpha = 0
        } completion: { _ in
            
            self.doneButton.isSelected = false
            
            self.nameTextField.restore()
            self.typeTextField.restore()
            self.breedTextField.restore()
            self.genderTextField.restore()
            self.ageTextField.restore()
            
            self.petImages.removeAll()
            
            UIView.animate(withDuration: 0.5) {
                self.view.alpha = 1
            }
        }
    }
    
    // TODO: - Present rules to user
    @objc private func handleRulesButton() {
        
    }
    
    @objc private func handleDoneButton() {
        
        doneButton.isSelected = true
        
        let alert = UIAlertController(title: "Accept rules?".localized(), message: "By uploading a pet you agree to the publication rules, and therefore you abide by the consequences.".localized(), preferredStyle: .alert)
        
        alert.view.tintColor = .secondColor
        
        alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: { _ in
            self.doneButton.isSelected = false
        }))
        
        alert.addAction(UIAlertAction(title: "Agree", style: .default, handler: { _ in
            self.uploadPet()
        }))
        
        present(alert, animated: true)
    }
    
    private func uploadPet() {
        
        if let name = nameTextField.textField.text?.trimmingCharacters(in: .whitespacesAndNewlines), let type = typeTextField.textField.text?.trimmingCharacters(in: .whitespacesAndNewlines), let breed = breedTextField.textField.text, let gender = genderTextField.textField.text?.trimmingCharacters(in: .whitespacesAndNewlines), let age = ageTextField.textField.text?.trimmingCharacters(in: .whitespacesAndNewlines), let location = adoptionsController?.currentUser?.location {
            
            if name.isEmpty || type.isEmpty || breed.isEmpty || gender.isEmpty || age.isEmpty || petImages.isEmpty {
                doneButton.isSelected = false
                return
            }
            
            guard let currentUserUid = currentUserUid else {
                return
            }
            
            let petDict = [
                PetVars.name.rawValue: name,
                PetVars.type.rawValue: type,
                PetVars.breed.rawValue: breed,
                PetVars.gender.rawValue: gender,
                PetVars.age.rawValue: age,
                PetVars.userId.rawValue: currentUserUid,
                PetVars.location.rawValue: location
            ] as [String: AnyObject]
            
            FirestoreManager.shared.insertPet(with: petDict, images: self.petImages) { [weak self] success in
                
                if !success {
                    print("Error uploading pet.")
                    return
                }
                
                self?.restore()
            }
            
//            DatabaseManager.shared.insertPet(with: petDict, images: self.petImages) { success in
//            }
        }
    }
    
    var collectionHeight: NSLayoutConstraint?
    
    private func setupViews() {
        view.backgroundColor = .mainColor
        
        coachMarksController.delegate = self
        coachMarksController.dataSource = self
        
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        
        // add subviews
        view.addSubview(scrollView)
        view.addSubview(buttonStack)
        scrollView.addSubview(containerView)
        
        containerView.addSubview(imageCollection)
        containerView.addSubview(pageControl)
        containerView.addSubview(stackView)
        
        view.addSubview(pointOfInterest)
        
        // x, y, w, h
        buttonStack.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        buttonStack.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        buttonStack.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        buttonStack.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        scrollView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: doneButton.topAnchor).isActive = true
        scrollView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        
        imageCollection.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        imageCollection.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        imageCollection.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        
        collectionHeight = imageCollection.heightAnchor.constraint(equalToConstant: 100)
        collectionHeight?.isActive = true
        
        pageControl.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        pageControl.topAnchor.constraint(equalTo: imageCollection.bottomAnchor).isActive = true
        pageControl.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        pageControl.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        stackView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: pageControl.bottomAnchor, constant: 20).isActive = true
        stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20).isActive = true
        stackView.widthAnchor.constraint(equalTo: containerView.widthAnchor, constant: -50).isActive = true
        
    }
}

extension NewPetController: UIScrollViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        if scrollView == imageCollection {
            
            let width = scrollView.frame.width
            let currentPage = Int(scrollView.contentOffset.x / width)
            
            pageControl.currentPage = currentPage
        }
    }
    
    private func textFieldsEmpty() -> Bool {
        
        guard let name = nameTextField.textField.text?.trimmingCharacters(in: .whitespacesAndNewlines), let type = typeTextField.textField.text?.trimmingCharacters(in: .whitespacesAndNewlines), let breed = breedTextField.textField.text, let gender = genderTextField.textField.text?.trimmingCharacters(in: .whitespacesAndNewlines), let age = ageTextField.textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            return true
        }
        
        if name.isEmpty || type.isEmpty || breed.isEmpty || gender.isEmpty || age.isEmpty {
            return true
        }
        
        return false
    }
    
    // MARK: Scroll View Delegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollView.bounces = scrollView.contentOffset.y > 100
    }
    
    // MARK: Image Picker Delegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        var selectedImage: UIImage?
        
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            selectedImage = editedImage
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            selectedImage = originalImage
        }
        
        if let image = selectedImage {
            
            ImageManager.shared.animalClassifier(image: image) { recognition in
                
                if recognition == nil {
                    self.mainAlert(title: "Oops!".localized(), message: "AI did not detect an animal, try uploading another photo.".localized())
                    return
                }
                
                guard let type = recognition?.type, let count = recognition?.count, let confidence = recognition?.confidence else { return }
                
                if self.petImages.isEmpty {
                    self.lastPetImageType = type
                } else {
                    
                    if type != self.lastPetImageType {
                        self.mainAlert(title: "Oops!".localized(), message: "Apparently pet type does not match with the other images.".localized())
                        return
                    }
                }
                
                if count != 1 {
                    self.mainAlert(title: "Oops!".localized(), message: "AI detected more than one animal, please upload another photo.".localized())
                    return
                }
                
                let percentage = Int(confidence * 100)
                self.mainAlert(title: "\(percentage)% \(type.localized())", message: "\(type.localized()) " + "detected!".localized())
                
                self.petImages.append(image)
            }
        }
        
        dismiss(animated: true, completion: nil)
        
    }
    
    // MARK: Collection View Delegate & Datasource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return petImages.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = collectionView.frame.size
        return CGSize(width: size.width, height: size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as? PetImageCell else { return UICollectionViewCell() }
        cell.image = indexPath.item == petImages.count ? nil : petImages[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.item == petImages.count {
            
            if textFieldsEmpty() {
                
                let alert = UIAlertController(title: "Advice".localized(), message: "We highly recommend filling in all the fields before adding images.".localized(), preferredStyle: .alert)
                
                alert.view.tintColor = .secondColor
                alert.addAction(UIAlertAction(title: "got it".localized(), style: .cancel, handler: { [self] _ in
                    self.present(self.imagePicker, animated: true, completion: nil)
                }))
                
                present(alert, animated: true)
                return
            }
            
            present(imagePicker, animated: true, completion: nil)
            
        } else {
            
            let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            actionSheet.view.tintColor = .secondColor
            
            actionSheet.addAction(UIAlertAction(title: "Delete".localized(), style: .destructive, handler: { _ in
                self.petImages.remove(at: indexPath.item)
                collectionView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
            }))
            
            actionSheet.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: nil))
            
            present(actionSheet, animated: true, completion: nil)
        }
    }
}

extension NewPetController: CoachMarksControllerDelegate, CoachMarksControllerDataSource {
    
    func numberOfCoachMarks(for coachMarksController: CoachMarksController) -> Int {
        return 4
    }
    
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkAt index: Int) -> CoachMark {
        
        switch index {
        case 0:
            pointOfInterest.frame = scrollView.frame
        case 1:
            let stackFrame = stackView.frame
            pointOfInterest.frame = CGRect(x: stackFrame.minX, y: stackFrame.minY, width: stackFrame.width, height: stackFrame.height / 2)
        case 2:
            pointOfInterest.frame = imageCollection.frame
        case 3:
            pointOfInterest.frame = doneButton.frame
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
        coachViews.bodyView.nextLabel.font = .mainFont(ofSize: 17, weight: .regular)
        
        coachViews.bodyView.hintLabel.textColor = .secondColor
        coachViews.bodyView.nextLabel.textColor = .secondColor
        
        var hintText = ""
        let nextText = "Got it"
        
        switch index {
        case 0:
            hintText = "Put up a pet for adoption by filling in this format."
        case 1:
            hintText = "Fill in fields with your pet info."
        case 2:
            hintText = "Add pet images by clicking and swiping."
        case 3:
            hintText = "Upload your pet by clicking this button."
        default:
            break
        }
        
        coachViews.bodyView.hintLabel.text = hintText.localized()
        coachViews.bodyView.nextLabel.text = nextText.localized()
        
        return (bodyView: coachViews.bodyView, arrowView: coachViews.arrowView)
    }
    
    func coachMarksController(_ coachMarksController: CoachMarksController, didEndShowingBySkipping skipped: Bool) {
        UserDefaults.standard.set(true, forKey: UserDefaultsKey.skipCoachMarks2.rawValue)
    }
}

// MARK: - Pets Controller
class PetsController: UIViewController {
    
    var adoptionsController: AdoptionsController?
    
    var pets = [Pet]() {
        didSet {
            
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    let cellId = "cellId"
    
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
//        sc.isUserInteractionEnabled = false
        
        return sc
    }()
    
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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fetchPets()
    }
    
    private func getPetTypeFor(_ index: Int) -> String {
        
        return selectedIndex == 0 ? PetType.Dog.rawValue : selectedIndex == 1 ? PetType.Cat.rawValue : PetType.Other.rawValue
    }
    
    private func setupViews() {
        view.backgroundColor = .white
        navigationController?.navigationBar.isHidden = true
        
        // add subviews
        view.addSubview(segmentedControl)
        view.addSubview(collectionView)
        
        // x, y, w, h
        segmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        segmentedControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        segmentedControl.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        segmentedControl.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        collectionView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: segmentedControl.topAnchor).isActive = true
        collectionView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -40).isActive = true
    }
    
    @objc private func handleSegmentedControl(_ sender: UISegmentedControl) {
        selectedIndex = sender.selectedSegmentIndex
        
        UIView.animate(withDuration: 0.6) {
            self.collectionView.alpha = 0
        } completion: { [weak self] _ in
            self?.fetchPets()
        }
    }
    
    private func fetchPets() {
        
        adoptionsController?.parentController?.presentLoadingView()
        
        pets.removeAll()
        
        FirestoreManager.shared.fetchUserPets(with: getPetTypeFor(selectedIndex)) { [weak self] result in
            
            switch result {
            case .success(let pets):
                
                self?.pets = pets
                self?.adoptionsController?.parentController?.removeLoadingView()
                
                UIView.animate(withDuration: 0.8) {
                    self?.collectionView.alpha = 1
                }
                
            case .failure(let err):
                print(err.localizedDescription)
            }
        }
        
//        DatabaseManager.shared.fetchUserPets(with: getPetTypeFor(selectedIndex)) { [weak self] result in
//        }
    }
}

extension PetsController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if pets.count == 0 {
            collectionView.setEmptyMessage("No adoptions yet. 🐶".localized())
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let pet = pets[indexPath.item]
        guard let petId = pet.petId, let petType = pet.type else { return }
        
        let usersController = UsersController()
        usersController.parentController = adoptionsController?.parentController
        
        FirestoreManager.shared.getLikesFromPet(with: petId, type: petType) { [weak self] result in
            
            switch result {
            case .success(let users):
                
                usersController.pet = pet
                usersController.users = users
                self?.present(usersController, animated: true, completion: nil)
                
            case .failure(let err):
                print(err.localizedDescription)
            }
        }
        
//        DatabaseManager.shared.getLikesFromPet(with: petId, type: petType) { [weak self] result in
//        }
    }
}

// MARK: - Users Controller
class UsersController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UserCellDelegate {
    
    var parentController: ParentController?
    
    var pet: Pet? {
        didSet {
            
            petInfoView.pet = self.pet
            
            if let name = pet?.name, let age = pet?.age, let breed = pet?.breed, let gender = pet?.gender {
                
                titleLabel.text = "Interested people on".localized() + " \(name)"
                
                let titleFontSize: CGFloat!
                let subtitleFontSize: CGFloat!
                
                if name.count > 8 || breed.count > 8 {
                    titleFontSize = 24
                    subtitleFontSize = 16
                } else {
                    titleFontSize = 28
                    subtitleFontSize = 20
                }
                
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.lineSpacing = 6
                
                let attrString = NSMutableAttributedString(string: "\(name), \(age)\n", attributes: [NSAttributedString.Key.font: UIFont.mainFont(ofSize: titleFontSize, weight: .bold), NSAttributedString.Key.foregroundColor: UIColor.secondColor, NSAttributedString.Key.paragraphStyle: paragraphStyle])
                
                attrString.append(NSAttributedString(string: "\(breed), \(gender)", attributes: [NSAttributedString.Key.font: UIFont.mainFont(ofSize: subtitleFontSize, weight: .regular), NSAttributedString.Key.foregroundColor: UIColor.mainGray]))
                
                petInfoView.attributedText = attrString
            }
        }
    }
    
    var users = [User]() {
        didSet {
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                self.scrollView.scrollToBottom()
            }
        }
    }
    
    let cellId = "cellId"
    
    lazy var contentViewSize = CGSize(width: self.view.frame.width, height: Screen.height + Screen.width)
    
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
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
//        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 25, right: 0)
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.isPagingEnabled = true
        cv.alwaysBounceVertical = false
        cv.showsVerticalScrollIndicator = false
        cv.showsHorizontalScrollIndicator = false
        cv.backgroundColor = .clear
        
        cv.delegate = self
        cv.dataSource = self
        cv.register(UserDetailCell.self, forCellWithReuseIdentifier: cellId)
        
        return cv
    }()
    
    let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.text = "Loading ...".localized()
        lbl.textColor = .secondColor
        lbl.font = .mainFont(ofSize: 16, weight: .semibold)
        return lbl
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
    
    lazy var deleteButton: UIButton = {
        let btn = UIButton()
        
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .cardRed
        
        var attrContainer = AttributeContainer()
        attrContainer.font = .mainFont(ofSize: 16, weight: .medium)
        
        config.attributedTitle = AttributedString("Delete".localized(), attributes: attrContainer)
        config.image = UIImage(systemName: "trash.fill")
        
        config.titlePadding = 10
        config.imagePadding = 10
        
        btn.configuration = config
        btn.addTarget(self, action: #selector(handleDelete), for: .touchUpInside)
        
        return btn
    }()
    
    lazy var adoptedButton: UIButton = {
        let btn = UIButton()
        
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .secondColor
        
        var attrContainer = AttributeContainer()
        attrContainer.font = .mainFont(ofSize: 16, weight: .medium)
        
        config.attributedTitle = AttributedString("Got adopted!".localized(), attributes: attrContainer)
        config.image = UIImage(systemName: "pawprint.circle.fill")
        
        config.titlePadding = 10
        config.imagePadding = 15
        
        btn.configuration = config
        btn.addTarget(self, action: #selector(handleAdopted), for: .touchUpInside)
        
        return btn
    }()
    
    lazy var buttonsStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 20
        
        stack.addArrangedSubview(adoptedButton)
        stack.addArrangedSubview(deleteButton)
        
        return stack
    }()
    
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
        containerView.addSubview(titleLabel)
        containerView.addSubview(collectionView)
        containerView.addSubview(buttonsStack)
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
        
        titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        titleLabel.topAnchor.constraint(equalTo: petInfoView.bottomAnchor, constant: 4).isActive = true
        titleLabel.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -40).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        buttonsStack.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        buttonsStack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12).isActive = true
        buttonsStack.widthAnchor.constraint(equalTo: titleLabel.widthAnchor).isActive = true
        buttonsStack.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        collectionView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor).isActive = true
        collectionView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: deleteButton.topAnchor, constant: -4).isActive = true
        
        closeButton.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 12).isActive = true
        closeButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12).isActive = true
        closeButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        closeButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
    }
    
    @objc private func handleDismiss() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func handleDelete() {
        
        guard let petName = pet?.name, let petId = pet?.petId, let imagesCount = pet?.imagesUrl?.count else {
            return
        }
        
        let message = "\(petName) " + "won't be shown to other users anymore.".localized()
        let alert = UIAlertController(title: "Are you sure?".localized(), message: message, preferredStyle: .alert)
        
        alert.view.tintColor = .secondColor
        alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: "Delete".localized(), style: .destructive, handler: { [weak self] _ in
            
            FirestoreManager.shared.removePet(with: petId, imagesCount: imagesCount) { success in
                
                if !success {
                    self?.mainAlert(title: "Oops!".localized(), message: "An unexpected error occurred.".localized())
                    return
                }
                
                self?.handleDismiss()
            }
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    @objc private func handleAdopted() {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        guard let petName = pet?.name else {
            return users.count
        }
        
        if users.isEmpty {
            collectionView.setEmptyMessage("No users are interested in".localized() + " \(petName) " + "yet.".localized())
        } else {
            collectionView.restore()
        }
        
        return users.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = collectionView.frame.size
        return CGSize(width: size.width, height: size.height * 0.9)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as? UserDetailCell else { return UICollectionViewCell() }
        cell.messageButton.tag = indexPath.item
        cell.user = users[indexPath.item]
        cell.delegate = self
        return cell
    }
    
    func didTapButton(_ sender: UIButton) {
        
        guard let pet = pet else {
            return
        }
        
        dismiss(animated: true) {
            self.parentController?.showChatController(for: self.users[sender.tag], pet: pet)
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
