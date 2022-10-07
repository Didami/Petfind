//
//  CustomViews.swift
//  Petfind
//
//  Created by Didami on 21/01/22.
//

import UIKit
import Shuffle_iOS
import PopBounceButton

// MARK: - Main Text Field
class MainTextField: UITextField {
    
    override var placeholder: String? {
        didSet {
            
            self.attributedPlaceholder = NSAttributedString(string: placeholder ?? "", attributes: [NSAttributedString.Key.foregroundColor: UIColor.accentColor, NSAttributedString.Key.font: UIFont.mainFont(ofSize: 18, weight: .regular)])
        }
    }
    
    var icon: UIImage? {
        didSet {
            
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
            imageView.image = icon
            imageView.tintColor = .secondColor
            imageView.contentMode = .scaleAspectFit

            let view = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            view.addSubview(imageView)
            imageView.center = view.center
            
            self.leftViewMode = .always
            self.leftView = view
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.accentColor.cgColor
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 4
        self.font = .mainFont(ofSize: 18, weight: .regular)
        self.textColor = .secondColor
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Form Text Field
class FormTextField: UIView {
    
    var title: String? {
        didSet {
            label.text = title
        }
    }
    
    var subtitle: String? {
        didSet {
            textField.attributedPlaceholder = NSAttributedString(string: subtitle ?? "", attributes: [NSAttributedString.Key.foregroundColor: UIColor.mainGray, NSAttributedString.Key.font: UIFont.mainFont(ofSize: 16, weight: .regular)])
        }
    }
    
    let picker = UIPickerView()
    lazy var toolBar: UIToolbar = {
        let tb = UIToolbar()
        tb.setItems([UIBarButtonItem(title: "Done".localized(), style: .done, target: self, action: #selector(dismiss))], animated: false)
        tb.sizeToFit()
        return tb
    }()
    
    var formPickerDelegate = FormPickerDelegate()
    
    var type: FieldType? {
        didSet {
            
            if type == .closed {
                
                textField.tintColor = .clear
                
                formPickerDelegate.textField = self.textField
                
                picker.delegate = formPickerDelegate
                picker.dataSource = formPickerDelegate
                
                textField.inputView = picker
                textField.inputAccessoryView = toolBar
            }
        }
    }
    
    var pickerTitles = [String]() {
        didSet {
            
            if type == .open {
                return
            }
            
            formPickerDelegate.pickerTitles = self.pickerTitles
        }
    }
    
    let label: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.textColor = .secondColor
        lbl.font = .mainFont(ofSize: 18, weight: .semibold)
        return lbl
    }()
    
    let bottomLine = CALayer()
    lazy var textField: UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.backgroundColor = .clear
        tf.textColor = .black
        tf.font = .mainFont(ofSize: 16, weight: .regular)
        
        tf.borderStyle = .none
        tf.layer.addSublayer(bottomLine)
        bottomLine.backgroundColor = UIColor.mainGray.cgColor
        
        return tf
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        bottomLine.frame = CGRect(x: 0, y: textField.frame.height - 2, width: textField.frame.width, height: 0.5)
    }
    
    func restore() {
        textField.text = nil
    }
    
    @objc func dismiss() {
        textField.resignFirstResponder()
    }
    
    private func setupViews() {
        
        // add subviews
        addSubview(label)
        addSubview(textField)
        
        // x, y, w, h
        label.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        label.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        label.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        label.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        textField.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        textField.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 4).isActive = true
        textField.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        textField.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class FormPickerDelegate: NSObject, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var pickerTitles = [String]()
    
    var textField: UITextField?
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerTitles.count + 1
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        
        let attrString = NSAttributedString(string: row == 0 ? "-" : pickerTitles[row - 1].localized(), attributes: [NSAttributedString.Key.foregroundColor: UIColor.secondColor, NSAttributedString.Key.font: UIFont.mainFont(ofSize: 8, weight: .regular)])
        
        return attrString
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if row == 0 {
            pickerView.selectRow(1, inComponent: 0, animated: true)
            textField?.text = pickerTitles[0]
            return
        }
        
        textField?.text = pickerTitles[row - 1]
    }
}

// MARK: - Side Menu Bar
class SideMenuBar: UIView {
    
    var sideMenuItems = [StackItem]() {
        didSet {
            
            sideMenuBarDelegate.sideMenuItems = self.sideMenuItems
            collectionView.reloadData()
        }
    }
    
    var selectedItem = 0
    var isMenuShown = false
    
    var hasPresented = false
    
    let menuContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var menu: UIView = {
        let menu = UIView()
        menu.translatesAutoresizingMaskIntoConstraints = false
        menu.backgroundColor = .white
        
        menu.layer.shadowColor = UIColor.mainGray.cgColor
        menu.layer.shadowOpacity = 0.5
        menu.layer.shadowOffset = CGSize(width: 2, height: 0)
        
        menu.addSubview(menuContent)
        
        menuContent.centerXAnchor.constraint(equalTo: menu.centerXAnchor).isActive = true
        menuContent.centerYAnchor.constraint(equalTo: menu.centerYAnchor).isActive = true
        menuContent.widthAnchor.constraint(equalTo: menu.widthAnchor).isActive = true
        menuContent.heightAnchor.constraint(equalTo: menu.heightAnchor).isActive = true
        
        return menu
    }()
    
    lazy var menuContent: UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.alpha = 0
        
        let icon = UIImageView(image: UIImage(named: "glyph"))
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.tintColor = .secondColor
        icon.contentMode = .scaleAspectFit
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .mainFont(ofSize: 12, weight: .regular)
        label.textColor = .mainGray
        label.text = "Developed with ♥️ by Didami".localized()
        label.adjustsFontSizeToFitWidth = true
        
        container.addSubview(icon)
        container.addSubview(label)
        container.addSubview(collectionView)
        
        icon.leftAnchor.constraint(equalTo: container.leftAnchor, constant: (12 + 10)).isActive = true
        icon.topAnchor.constraint(equalTo: container.safeAreaLayoutGuide.topAnchor, constant: 8).isActive = true
        icon.widthAnchor.constraint(equalTo: container.widthAnchor, multiplier: 1/3).isActive = true
        icon.heightAnchor.constraint(equalTo: icon.widthAnchor).isActive = true
        
        label.leftAnchor.constraint(equalTo: icon.leftAnchor, constant: 2).isActive = true
        label.rightAnchor.constraint(equalTo: container.rightAnchor, constant: -12).isActive = true
        label.bottomAnchor.constraint(equalTo: container.safeAreaLayoutGuide.bottomAnchor, constant: -12).isActive = true
        label.heightAnchor.constraint(equalToConstant: 18).isActive = true
        
        collectionView.leftAnchor.constraint(equalTo: icon.leftAnchor).isActive = true
        collectionView.rightAnchor.constraint(equalTo: label.rightAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: icon.bottomAnchor, constant: 4).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: label.topAnchor, constant: -4).isActive = true
        
        return container
    }()
    
    var menuTrailing: NSLayoutConstraint?
    
    var sideMenuBarDelegate = SideMenuBarDelegate()
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.showsVerticalScrollIndicator = false
        cv.backgroundColor = .clear
        
        cv.delegate = sideMenuBarDelegate
        cv.dataSource = sideMenuBarDelegate
        cv.register(SideMenuCell.self, forCellWithReuseIdentifier: sideMenuCellId)
        
        return cv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.alpha = 0
        self.backgroundColor = .black.withAlphaComponent(0.4)
        
        self.addSubview(menuContainer)
        menuContainer.addSubview(menu)
        
        menuContainer.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        menuContainer.trailingAnchor.constraint(equalTo: self.centerXAnchor, constant: 30).isActive = true
        menuContainer.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        menuContainer.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
//        menu.leftAnchor.constraint(equalTo: menuBackground.leftAnchor).isActive = true
        menu.topAnchor.constraint(equalTo: menuContainer.topAnchor).isActive = true
        menu.bottomAnchor.constraint(equalTo: menuContainer.bottomAnchor).isActive = true
        menu.widthAnchor.constraint(equalTo: menuContainer.widthAnchor, constant: 10).isActive = true
        
        menuTrailing = menu.trailingAnchor.constraint(equalTo: menuContainer.leadingAnchor, constant: -2)
        menuTrailing?.isActive = true
        
        sideMenuBarDelegate.sideMenuBar = self
    }
    
    public func presentIn(_ vc: UIViewController) {
        
        if !hasPresented {
            collectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: false, scrollPosition: [])
            hasPresented = true
        }
        
        vc.view.window?.addSubview(self)
        
        self.frame = vc.view.window?.frame ?? vc.view.frame
        self.center = vc.view.window?.center ?? vc.view.center
        
        UIView.animate(withDuration: 0.2) {
            self.alpha = 1
        } completion: { _ in
            
            self.menuTrailing?.isActive = false
            self.menuTrailing = self.menu.trailingAnchor.constraint(equalTo: self.menuContainer.trailingAnchor)
            self.menuTrailing?.isActive = true
            
            UIView.animate(withDuration: 0.5) {
                self.layoutIfNeeded()
            } completion: { _ in
                
                UIView.animate(withDuration: 0.25) {
                    self.menuContent.alpha = 1
                    self.isMenuShown = true
                }
            }
        }
    }
    
    func dismiss(duration: TimeInterval, onDone: (() -> Void)?) {
        
        self.menuTrailing?.isActive = false
        self.menuTrailing = self.menu.trailingAnchor.constraint(equalTo: menuContainer.leadingAnchor)
        self.menuTrailing?.isActive = true
        
        UIView.animate(withDuration: duration / 2) {
            self.menuContent.alpha = 0
            self.layoutIfNeeded()
        } completion: { _ in
            
            UIView.animate(withDuration: duration / 2) {
                self.alpha = 0
            } completion: { _ in
                
                self.removeFromSuperview()
                self.frame = .zero
                self.isMenuShown = false
                
                if onDone != nil {
                    onDone!()
                }
            }
        }
    }
    
    private var beginPoint: CGFloat = 0
    private var difference: CGFloat = 0
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if isMenuShown {
            
            if let touch = touches.first {
                
                let location = touch.location(in: menuContainer)
                beginPoint = location.x
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if isMenuShown {
            
            if let touch = touches.first {
                
                let location = touch.location(in: menuContainer)
                let differenceFromBeginPoint = beginPoint - location.x
                
                if differenceFromBeginPoint >= -10 {
                    self.menuTrailing?.constant = -differenceFromBeginPoint
                    difference = differenceFromBeginPoint
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if isMenuShown {
            
            if difference > UIScreen.main.bounds.width / 4 {
                dismiss(duration: 0.2, onDone: nil)
            } else {
                
                menuTrailing?.constant = -2
                
                UIView.animate(withDuration: 0.2) {
                    self.layoutIfNeeded()
                }
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

struct StackItem {
    
    var name: String?
    var icon: UIImage?
    var action: (() -> Void)?
    
    func performAction() {
        
        if action != nil {
            action!()
        }
    }
}

class SideMenuBarDelegate: NSObject, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    var sideMenuItems = [StackItem]()
    var sideMenuBar: SideMenuBar?
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sideMenuItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width, height: 60)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: sideMenuCellId, for: indexPath) as? SideMenuCell else { return UICollectionViewCell() }
        cell.sideMenuItem = sideMenuItems[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        sideMenuBar?.dismiss(duration: 0.8, onDone: {
            self.sideMenuItems[indexPath.item].performAction()
            self.sideMenuBar?.selectedItem = indexPath.item
        })
    }
}

// MARK: - Pet Swipe Card
class PetSwipeCard: SwipeCard {
    
    var pet: Pet? {
        didSet {
            
            if let imageUrl = pet?.imagesUrl?.first, let name = pet?.name, let breed = pet?.breed, let gender = pet?.gender, let age = pet?.age {
                
                ImageManager.shared.fetchImage(urlString: imageUrl) { [weak self] result in
                    
                    switch result {
                        
                    case .success(let img):
                        
                        self?.imageView.image = img
                        
                        self?.activityIndicator.stopAnimating()
                        self?.activityIndicator.alpha = 0
                        
                    case .failure(let err):
                        print(err.localizedDescription)
                    }
                }
                
               DispatchQueue.main.async {
                    
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
                    
                   attrString.append(NSAttributedString(string: "\(breed), \(gender.localized())", attributes: [NSAttributedString.Key.font: UIFont.mainFont(ofSize: subtitleFontSize, weight: .regular), NSAttributedString.Key.foregroundColor: UIColor.mainGray]))
                    
                    self.petFooter.textView.attributedText = attrString
                }
            }
        }
    }
    
    let activityIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView()
        ai.translatesAutoresizingMaskIntoConstraints = false
        ai.style = .large
        return ai
    }()
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .mainLightGray
        return iv
    }()
    
    let petFooter: CardPetViewFooter = {
        let footer = CardPetViewFooter()
        footer.translatesAutoresizingMaskIntoConstraints = false
        footer.layer.masksToBounds = false
        footer.layer.shadowColor = UIColor.black.cgColor
        footer.layer.shadowOffset =  CGSize.zero
        footer.layer.shadowOpacity = 0.5
        footer.layer.shadowRadius = 4
        return footer
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        activityIndicator.startAnimating()
    }
    
    private func setupViews() {
        
        setupOverlays()
        
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 12
        
        // add subviews
        self.addSubview(imageView)
        self.addSubview(activityIndicator)
        self.addSubview(petFooter)
        
        // x, y, w, h
        imageView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        imageView.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        imageView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        
        activityIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        activityIndicator.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        activityIndicator.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        
        petFooter.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        petFooter.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -20).isActive = true
        petFooter.widthAnchor.constraint(equalTo: self.widthAnchor, constant: -30).isActive = true
        petFooter.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 1/4, constant: 8).isActive = true
    }
    
    private func setupOverlays() {
        
        let rightOverlay = CardOverlay(direction: .right)
        self.setOverlay(rightOverlay, forDirection: .right)
        
        let leftOverlay = CardOverlay(direction: .left)
        self.setOverlay(leftOverlay, forDirection: .left)
        
        let upOverlay = CardOverlay(direction: .up)
        self.setOverlay(upOverlay, forDirection: .up)
        
        let downOverlay = CardOverlay(direction: .down)
        self.setOverlay(downOverlay, forDirection: .down)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class CardPetViewFooter: UIView {
    
    let textView: UITextView = {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.isEditable = false
        tv.isSelectable = false
        tv.isScrollEnabled = false
        tv.isUserInteractionEnabled = false
        tv.backgroundColor = .clear
        return tv
    }()
    
    let button: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("Info.", for: .normal)
        btn.setTitleColor(.mainColor, for: .normal)
        btn.titleLabel?.font = .mainFont(ofSize: 16, weight: .regular)
        btn.backgroundColor = .secondColor
        btn.layer.masksToBounds = true
        btn.layer.cornerRadius = 12
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    private func setupViews() {
        
        self.backgroundColor = .mainColor
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 8
        
        // add subviews
        self.addSubview(button)
        self.addSubview(textView)
        
        // x, y, w, h
        button.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -15).isActive = true
        button.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        button.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 1/3).isActive = true
        button.widthAnchor.constraint(equalToConstant: 75).isActive = true
        
        textView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 15).isActive = true
        textView.rightAnchor.constraint(equalTo: button.leftAnchor, constant: -10).isActive = true
        textView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        textView.heightAnchor.constraint(equalTo: self.heightAnchor, constant: -30).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Button Stack View
class StackButton: PopBounceButton {

    override init() {
        super.init()
        backgroundColor = .white
        tintColor = .secondColor
        layer.masksToBounds = true
    }

    required init?(coder aDecoder: NSCoder) {
        return nil
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        layer.cornerRadius = frame.width / 2
    }
}

protocol ButtonStackViewDelegate: AnyObject {
    func didTapButton(button: StackButton)
}

class ButtonStackView: UIStackView {

    weak var delegate: ButtonStackViewDelegate?

    private lazy var passButton: StackButton = {
        let button = StackButton()
        button.setImage(UIImage(named: "pass"), for: .normal)
        button.addTarget(self, action: #selector(handleTap), for: .touchUpInside)
        button.tag = 1
        return button
    }()

    private lazy var superLikeButton: StackButton = {
        let button = StackButton()
        button.setImage(UIImage(named: "star"), for: .normal)
        button.addTarget(self, action: #selector(handleTap), for: .touchUpInside)
        button.tag = 2
        return button
    }()
    
    private lazy var likeButton: StackButton = {
        let button = StackButton()
        button.setImage(UIImage(named: "checkmark"), for: .normal)
        button.addTarget(self, action: #selector(handleTap), for: .touchUpInside)
        button.tag = 3
        return button
    }()
    
    private lazy var reportButton: StackButton = {
        let button = StackButton()
        button.setImage(UIImage(named: "report"), for: .normal)
        button.addTarget(self, action: #selector(handleTap), for: .touchUpInside)
        button.tag = 4
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        distribution = .equalSpacing
        alignment = .center
        configureButtons()
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureButtons() {
        let largeMultiplier: CGFloat = 72 / 414
        addArrangedSubview(from: passButton, diameterMultiplier: largeMultiplier)
        addArrangedSubview(from: superLikeButton, diameterMultiplier: largeMultiplier)
        addArrangedSubview(from: likeButton, diameterMultiplier: largeMultiplier)
        addArrangedSubview(from: reportButton, diameterMultiplier: largeMultiplier)
    }

    private func addArrangedSubview(from button: StackButton, diameterMultiplier: CGFloat) {
        let container = ButtonContainer()
        container.addSubview(button)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.leftAnchor.constraint(equalTo: container.leftAnchor).isActive = true
        button.rightAnchor.constraint(equalTo: container.rightAnchor).isActive = true
        button.topAnchor.constraint(equalTo: container.topAnchor).isActive = true
        button.bottomAnchor.constraint(equalTo: container.bottomAnchor).isActive = true
        
        addArrangedSubview(container)
        container.translatesAutoresizingMaskIntoConstraints = false
        container.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor, multiplier:    diameterMultiplier).isActive = true
        container.heightAnchor.constraint(equalTo: button.widthAnchor).isActive = true
    }

    @objc private func handleTap(_ button: StackButton) {
        delegate?.didTapButton(button: button)
    }
}

private class ButtonContainer: UIView {

    override func draw(_ rect: CGRect) {
        applyShadow(radius: 0.2 * bounds.width, opacity: 0.05, offset: CGSize(width: 0, height: 0.05 * bounds.width))
    }
}

// MARK: - Loading View
class LoadingView: UIView {
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.animationImages = animatedImages(for: "glyph_animation")
        iv.animationDuration = 1.2
        iv.animationRepeatCount = 0
        iv.image = iv.animationImages?.first
        return iv
    }()
    
    let label: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.textAlignment = .center
        lbl.textColor = .secondColor
        lbl.font = .mainFont(ofSize: 28, weight: .medium)
        lbl.text = "Loading".localized()
        return lbl
    }()
    
    lazy var containerView: UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .clear
        
        container.addSubview(imageView)
        container.addSubview(label)
        
        imageView.centerXAnchor.constraint(equalTo: container.centerXAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: container.topAnchor).isActive = true
        imageView.widthAnchor.constraint(equalTo: container.widthAnchor, multiplier: 1/2).isActive = true
        imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor).isActive = true
        
        label.centerXAnchor.constraint(equalTo: container.centerXAnchor).isActive = true
        label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 12).isActive = true
        label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -12).isActive = true
        label.widthAnchor.constraint(equalTo: container.widthAnchor, constant: -12).isActive = true
        
        return container
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    private func setupViews() {
        self.alpha = 0
        
        // add subviews
        self.addSubview(containerView)
        
        // x, y, w, h
        containerView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        containerView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 1/2).isActive = true
        containerView.heightAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
    }
    
    public func presentIn(_ vc: UIViewController, backgroundColor: UIColor?) {
        
        self.backgroundColor = backgroundColor
        
        vc.view.addSubview(self)
        self.frame = vc.view.frame
        self.center = vc.view.center
        
        imageView.startAnimating()
        
        UIView.animate(withDuration: 0.5) {
            self.alpha = 1
        }
    }
    
    public func remove(completion: (() -> Void)? = nil) {
        
        self.removeFromSuperview()
        
        UIView.animate(withDuration: 0.5) {
            self.alpha = 0
        } completion: { _ in
            
            self.imageView.stopAnimating()
            
            if completion != nil {
                completion!()
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Pet Info View

let petImageCellId = "petImageCellId"

class PetInfoView: UIView {
    
    var pet: Pet? {
        didSet {
            
            guard var imgsUrl = pet?.imagesUrl else { return }
            
            imgsUrl.sort { img1, img2 in
                return (img1.localizedCaseInsensitiveCompare(img2) == .orderedAscending)
            }
            
            petImages.removeAll()
            
            for imgUrl in imgsUrl {
                
                ImageManager.shared.fetchImage(urlString: imgUrl) { [weak self] result in
                    
                    switch result {
                    case .success(let img):
                        self?.petImages.append(img)
                    case .failure(let err):
                        print(err.localizedDescription)
                    }
                }
            }
        }
    }
    
    var petImages = [UIImage]() {
        didSet {
            
            petInfoViewDelgate.petImages = self.petImages
            
            UIView.animate(withDuration: 0.3) {
                self.pageControl.numberOfPages = self.petImages.count
            }
            
            guard let first = petImages.first else { return }
            
            first.getColors { [weak self] colors in
                
                UIView.animate(withDuration: 0.3) {
                    self?.imageCollection.backgroundColor = colors?.background
                    self?.pageControl.backgroundColor = colors?.primary.withAlphaComponent(0.4)
                }
            }
            
            imageCollection.reloadData()
        }
    }
    
    var attributedText: NSAttributedString? {
        didSet {
            textView.attributedText = self.attributedText
        }
    }
    
    var petInfoViewDelgate = PetInfoViewDelgate()
    
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
        cv.backgroundColor = .mainLightGray
        
        cv.delegate = petInfoViewDelgate
        cv.dataSource = petInfoViewDelgate
        cv.register(PetImageCell.self, forCellWithReuseIdentifier: petImageCellId)
        
        return cv
    }()
    
    let pageControl: UIPageControl = {
        let pc = UIPageControl()
        pc.translatesAutoresizingMaskIntoConstraints = false
        pc.currentPage = 1
        pc.numberOfPages = 1
        pc.backgroundColor = .mainGray.withAlphaComponent(0.4)
        pc.isUserInteractionEnabled = false
        return pc
    }()
    
    
    let textView: UITextView = {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.isEditable = false
        tv.isSelectable = false
        tv.isScrollEnabled = false
        tv.isUserInteractionEnabled = false
        tv.backgroundColor = .clear
        return tv
    }()
    
    lazy var navBar: UIView = {
        let navBar = UIView()
        navBar.translatesAutoresizingMaskIntoConstraints = false
        navBar.backgroundColor = .mainColor.withAlphaComponent(0.6)
        
        navBar.addSubview(textView)
        
        textView.centerXAnchor.constraint(equalTo: navBar.centerXAnchor).isActive = true
        textView.centerYAnchor.constraint(equalTo: navBar.centerYAnchor).isActive = true
        textView.widthAnchor.constraint(equalTo: navBar.widthAnchor, constant: -16).isActive = true
        textView.heightAnchor.constraint(equalTo: navBar.heightAnchor, constant: -16).isActive = true
        
        return navBar
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        petInfoViewDelgate.pageControl = pageControl
    }
    
    private func setupViews() {
        self.backgroundColor = .white
        
        // add subviews
        self.addSubview(imageCollection)
        self.addSubview(pageControl)
        self.addSubview(navBar)
        
        // x, y, w, h
        navBar.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        navBar.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        navBar.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        navBar.heightAnchor.constraint(equalToConstant: 120).isActive = true
        
        pageControl.centerXAnchor.constraint(equalTo: navBar.centerXAnchor).isActive = true
        pageControl.bottomAnchor.constraint(equalTo: navBar.topAnchor).isActive = true
        pageControl.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        pageControl.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        imageCollection.centerXAnchor.constraint(equalTo: navBar.centerXAnchor).isActive = true
        imageCollection.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        imageCollection.bottomAnchor.constraint(equalTo: pageControl.topAnchor).isActive = true
        imageCollection.widthAnchor.constraint(equalTo: pageControl.widthAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class PetInfoViewDelgate: NSObject, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    var petImages = [UIImage]()
    var pageControl: UIPageControl?
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        let width = scrollView.frame.width
        let currentPage = Int(scrollView.contentOffset.x / width)
        
        pageControl?.currentPage = currentPage
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return petImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = collectionView.frame.size
        return CGSize(width: size.width, height: size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: petImageCellId, for: indexPath) as? PetImageCell else { return UICollectionViewCell() }
        cell.image = petImages[indexPath.item]
        return cell
    }
}
