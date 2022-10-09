//
//  CustomCells.swift
//  Petfind
//
//  Created by Didami on 24/01/22.
//

import UIKit

// MARK: - Onboarding cell
class OnboardingCell: UICollectionViewCell {
    
    let imgView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.alpha = 0.6
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .black
        
        self.addSubview(imgView)
        
        imgView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        imgView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        imgView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        imgView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Side Menu Cell
class SideMenuCell: UICollectionViewCell {
    
    var sideMenuItem: StackItem? {
        didSet {
            
            if let name = sideMenuItem?.name, let icon = sideMenuItem?.icon {
                
                label.text = name
                imageView.image = icon
                
            }
        }
    }
    
    override var isSelected: Bool {
        didSet {
            
            UIView.animate(withDuration: 0.3) {
                self.backgroundColor = self.isSelected ? .mainColor.withAlphaComponent(0.25) : .clear
            }
        }
    }
    
    let imageView: UIImageView = {
        let icon = UIImageView()
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.contentMode = .scaleAspectFit
        icon.tintColor = .secondColor
        return icon
    }()
    
    let label: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.numberOfLines = 0
        lbl.font = .mainFont(ofSize: 18, weight: .regular)
        lbl.adjustsFontSizeToFitWidth = true
        lbl.textColor = .secondColor
        return lbl
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    private func setupViews() {
        backgroundColor = .clear
        layer.masksToBounds = false
        layer.cornerRadius = 4
        
        // add subviews
        self.addSubview(imageView)
        self.addSubview(label)
        
        // x, y, w, h
        imageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        imageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        imageView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 1/2).isActive = true
        imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor).isActive = true
        
        label.leftAnchor.constraint(equalTo: imageView.rightAnchor, constant: 8).isActive = true
        label.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8).isActive = true
        label.centerYAnchor.constraint(equalTo: imageView.centerYAnchor).isActive = true
        label.heightAnchor.constraint(equalTo: imageView.heightAnchor, constant: 4).isActive = true
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - User Cells
class UserManageCell: UICollectionViewCell {
    
    var user: User? {
        didSet {
            
            if let username = user?.username, let email = user?.email, let userId = user?.userId {
                
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.lineSpacing = 10
                
                let attrString = NSMutableAttributedString(string: "@\(username)\n", attributes: [NSAttributedString.Key.font: UIFont.mainFont(ofSize: 18, weight: .semibold), NSAttributedString.Key.foregroundColor: UIColor.secondColor, NSAttributedString.Key.paragraphStyle: paragraphStyle])
                
                attrString.append(NSAttributedString(string: email, attributes: [NSAttributedString.Key.font: UIFont.mainFont(ofSize: 16, weight: .regular), NSAttributedString.Key.foregroundColor: UIColor.mainGray]))
                
                textView.attributedText = attrString
                
                isUserAdmin(userId: userId) { [weak self] isAdmin in
                    self?.boolSwitch.isOn = isAdmin
                }
            }
        }
    }
    
    weak var delegate: UserCellDelegate?
    
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
    
    let boolSwitch: UISwitch = {
        let bSwitch = UISwitch()
        bSwitch.translatesAutoresizingMaskIntoConstraints = false
        bSwitch.onTintColor = .secondColor
        return bSwitch
    }()
    
    var accessoryView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    private func setupViews() {
        backgroundColor = .mainColor.withAlphaComponent(0.8)
        layer.masksToBounds = true
        layer.cornerRadius = 30
        
        // add subviews
        contentView.addSubview(textView)
        contentView.addSubview(accessoryView)
        accessoryView.addSubview(boolSwitch)
        
        // x, y, w, h
        accessoryView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -20).isActive = true
        accessoryView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        accessoryView.widthAnchor.constraint(equalToConstant: 51).isActive = true
        accessoryView.heightAnchor.constraint(equalTo: contentView.heightAnchor, constant: -40).isActive = true
        
        boolSwitch.centerXAnchor.constraint(equalTo: accessoryView.centerXAnchor).isActive = true
        boolSwitch.centerYAnchor.constraint(equalTo: accessoryView.centerYAnchor).isActive = true
        boolSwitch.widthAnchor.constraint(equalTo: accessoryView.widthAnchor).isActive = true
        boolSwitch.heightAnchor.constraint(equalToConstant: 31).isActive = true
        
        textView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 20).isActive = true
        textView.rightAnchor.constraint(equalTo: accessoryView.leftAnchor, constant: -20).isActive = true
        textView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        textView.heightAnchor.constraint(equalTo: accessoryView.heightAnchor).isActive = true
        
    }
    
    @objc private func handleButton(_ sender: UIButton) {
        delegate?.didTapButton(sender)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class UserDetailCell: UICollectionViewCell {
    
    var user: User? {
        didSet {
            
            if let username = user?.username, let email = user?.email {
                
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.lineSpacing = 10
                
                let attrString = NSMutableAttributedString(string: "@\(username)\n", attributes: [NSAttributedString.Key.font: UIFont.mainFont(ofSize: 18, weight: .semibold), NSAttributedString.Key.foregroundColor: UIColor.secondColor, NSAttributedString.Key.paragraphStyle: paragraphStyle])
                
                attrString.append(NSAttributedString(string: email, attributes: [NSAttributedString.Key.font: UIFont.mainFont(ofSize: 16, weight: .regular), NSAttributedString.Key.foregroundColor: UIColor.mainGray]))
                
                topTextView.attributedText = attrString
            }
            
            if user?.bio != nil {
                bottomTextView.text = user?.bio
            } else {
                bottomTextView.text = "User has not added any info yet.".localized()
            }
        }
    }
    
    weak var delegate: UserCellDelegate?
    
    let topTextView: UITextView = {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.isEditable = false
        tv.isSelectable = false
        tv.isScrollEnabled = false
        tv.isUserInteractionEnabled = false
        tv.backgroundColor = .clear
        return tv
    }()
    
    lazy var topView: UIView = {
        let tv = UIView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = .mainColor
        tv.layer.masksToBounds = true
        tv.layer.cornerRadius = 20
        tv.layer.zPosition = 1
        
        tv.addSubview(topTextView)
        
        topTextView.centerXAnchor.constraint(equalTo: tv.centerXAnchor).isActive = true
        topTextView.centerYAnchor.constraint(equalTo: tv.centerYAnchor).isActive = true
        topTextView.widthAnchor.constraint(equalTo: tv.widthAnchor, constant: -24).isActive = true
        topTextView.heightAnchor.constraint(equalTo: tv.heightAnchor, constant: -24).isActive = true
        
        return tv
    }()
    
    let bottomTextView: UITextView = {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.isEditable = false
        tv.isSelectable = false
        tv.isScrollEnabled = true
        tv.backgroundColor = .clear
        tv.textColor = .white
        tv.font = .mainFont(ofSize: 18, weight: .regular)
        return tv
    }()
    
    lazy var messageButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(UIImage(systemName: "paperplane.fill"), for: .normal)
        btn.tintColor = .secondColor
        btn.backgroundColor = .mainColor
        btn.layer.masksToBounds = true
        btn.layer.cornerRadius = 12
        btn.addTarget(self, action: #selector(handleMessageButton(_:)), for: .touchUpInside)
        return btn
    }()
    
    lazy var bottomView: UIView = {
        let bv = UIView()
        bv.translatesAutoresizingMaskIntoConstraints = false
        bv.backgroundColor = .secondColor
        bv.layer.masksToBounds = true
        bv.layer.cornerRadius = 20
        bv.layer.zPosition = 0
        
        bv.addSubview(messageButton)
        bv.addSubview(bottomTextView)
        
        messageButton.rightAnchor.constraint(equalTo: bv.rightAnchor, constant: -12).isActive = true
        messageButton.bottomAnchor.constraint(equalTo: bv.bottomAnchor, constant: -12).isActive = true
        messageButton.widthAnchor.constraint(equalTo: bv.widthAnchor, multiplier: 1/3).isActive = true
        messageButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        bottomTextView.centerXAnchor.constraint(equalTo: bv.centerXAnchor).isActive = true
        bottomTextView.topAnchor.constraint(equalTo: bv.topAnchor, constant: 80).isActive = true
        bottomTextView.widthAnchor.constraint(equalTo: bv.widthAnchor, constant: -24).isActive = true
        bottomTextView.bottomAnchor.constraint(equalTo: messageButton.topAnchor, constant: -8).isActive = true
        
        return bv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    @objc private func handleMessageButton(_ sender: UIButton) {
        delegate?.didTapButton(sender)
    }
    
    private func setupViews() {
        backgroundColor = .clear
        
        // add subviews
        self.addSubview(topView)
        self.addSubview(bottomView)
        
        // x, y, w, h
        topView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        topView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        topView.widthAnchor.constraint(equalTo: self.widthAnchor, constant: -24).isActive = true
        topView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 1/3).isActive = true
        
        bottomView.centerXAnchor.constraint(equalTo: topView.centerXAnchor).isActive = true
        bottomView.widthAnchor.constraint(equalTo: topView.widthAnchor, constant: -8).isActive = true
        bottomView.topAnchor.constraint(equalTo: topView.centerYAnchor).isActive = true
        bottomView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

protocol UserCellDelegate: AnyObject {
    func didTapButton(_ sender: UIButton)
}

// MARK: - Pet Cell
class PetCell: UICollectionViewCell {
    
    var pet: Pet? {
        didSet {
            
            if let imageUrl = pet?.imagesUrl?.first, let name = pet?.name {
                
                ImageManager.shared.fetchImage(urlString: imageUrl) { [weak self] result in
                    
                    switch result {
                        
                    case .success(let img):
                        
                        self?.imageView.image = img
                        
                    case .failure(let err):
                        print(err.localizedDescription)
                    }
                }
                
                titleLabel.text = name
            }
        }
    }
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .mainLightGray
        return iv
    }()
    
    let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = .mainFont(ofSize: 16, weight: .semibold)
        lbl.textColor = .secondColor
        lbl.text = "Loading"
        return lbl
    }()
    
    lazy var petFooter: UIView = {
        let footer = UIView()
        footer.translatesAutoresizingMaskIntoConstraints = false
        footer.backgroundColor = .mainColor
        footer.layer.masksToBounds = true
        footer.layer.cornerRadius = 8
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
    }
    
    private func setupViews() {
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 12
        
        // add subviews
        self.addSubview(imageView)
        self.addSubview(petFooter)
        petFooter.addSubview(titleLabel)
        
        // x, y, w, h
        imageView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        imageView.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        imageView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        
        petFooter.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        petFooter.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -20).isActive = true
        petFooter.widthAnchor.constraint(equalTo: self.widthAnchor, constant: -30).isActive = true
        petFooter.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 1/4).isActive = true
        
        titleLabel.centerXAnchor.constraint(equalTo: petFooter.centerXAnchor).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: petFooter.centerYAnchor).isActive = true
        titleLabel.widthAnchor.constraint(equalTo: petFooter.widthAnchor, constant: -24).isActive = true
        titleLabel.heightAnchor.constraint(equalTo: petFooter.heightAnchor, constant: -24).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


// MARK: - Pet Image Cell
class PetImageCell: UICollectionViewCell {
    
    var image: UIImage? {
        didSet {
            
            if image == nil {
                contentView.backgroundColor = .mainColor
                imageView.image = nil
                addIcon.alpha = 1
            } else {
                contentView.backgroundColor = .clear
                imageView.image = image
                addIcon.alpha = 0
            }
        }
    }
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    let addIcon: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "arrow.up.doc.fill"))
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.tintColor = .secondColor
        iv.contentMode = .scaleAspectFit
        iv.alpha = 0
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    private func setupViews() {
        // add subviews
        contentView.addSubview(imageView)
        contentView.addSubview(addIcon)
        
        // x, y, w, h
        imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        imageView.widthAnchor.constraint(equalTo: contentView.widthAnchor).isActive = true
        imageView.heightAnchor.constraint(equalTo: contentView.heightAnchor).isActive = true
        
        addIcon.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        addIcon.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        addIcon.widthAnchor.constraint(equalToConstant: 80).isActive = true
        addIcon.heightAnchor.constraint(equalTo: addIcon.widthAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Pet Data Cell
struct PetData {
    
    var title: String?
    var subtitle: String?
    
}

class PetDataCell: UICollectionViewCell {
    
    var petData: PetData? {
        didSet {
            
            if let title = petData?.title, let subtitle = petData?.subtitle {
                
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.lineSpacing = 8
                
                let attrText = NSMutableAttributedString(string: "\(title.localized())\n", attributes: [NSAttributedString.Key.font: UIFont.mainFont(ofSize: 20, weight: .semibold), NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.paragraphStyle: paragraphStyle])
                
                attrText.append(NSAttributedString(string: subtitle.localized(), attributes: [NSAttributedString.Key.font: UIFont.mainFont(ofSize: 18, weight: .regular), NSAttributedString.Key.foregroundColor: UIColor.mainGray]))
                
                textView.attributedText = attrText
            }
        }
    }
    
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    private func setupViews() {
        // add subviews
        addSubview(textView)
        
        // x, y, w, h
        textView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        textView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        textView.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        textView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Message Cell
class MessageCell: UICollectionViewCell {
    
    var message: Message? {
        didSet {
            
            if let chatPartnerId = message?.chatPartnerId() {
                
                FirestoreManager.shared.getUserInfoFrom(chatPartnerId) { [weak self] user in
                    
                    if let username = user?.username, let text = self?.message?.text, let profileIcon = user?.profileIcon {
                        
                        self?.icon.image = UIImage(named: "profile_img\(profileIcon)")
                        
                        let paragraphStyle = NSMutableParagraphStyle()
                        paragraphStyle.lineSpacing = 10
                        
                        let attrString = NSMutableAttributedString(string: "\(username)\n", attributes: [NSAttributedString.Key.font: UIFont.mainFont(ofSize: 18, weight: .semibold), NSAttributedString.Key.foregroundColor: UIColor.secondColor, NSAttributedString.Key.paragraphStyle: paragraphStyle])
                        
                        attrString.append(NSAttributedString(string: text, attributes: [NSAttributedString.Key.font: UIFont.mainFont(ofSize: 16, weight: .regular), NSAttributedString.Key.foregroundColor: UIColor.mainGray]))
                        
                        self?.textView.attributedText = attrString
                    }
                }
            }
        }
    }
    
    let icon: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .secondColor
        iv.backgroundColor = .clear
        return iv
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    private func setupViews() {
        backgroundColor = .mainColor.withAlphaComponent(0.8)
        layer.masksToBounds = true
        layer.cornerRadius = 30
        
        // add subviews
        addSubview(icon)
        addSubview(textView)
        
        // x, y, w, h
        icon.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 20).isActive = true
        icon.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        icon.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 1/2).isActive = true
        icon.widthAnchor.constraint(equalTo: icon.heightAnchor).isActive = true
        
        textView.leftAnchor.constraint(equalTo: icon.rightAnchor, constant: 12).isActive = true
        textView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -20).isActive = true
        textView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        textView.heightAnchor.constraint(equalTo: self.heightAnchor, constant: -40).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Messages
class ChatMessageCell: UICollectionViewCell {
    
    var message: Message? {
        didSet {
            
            if let uid = currentUserUid, let text = message?.text {
                
                bubbleWidth?.constant = estimatedFrameForText(text: text).width + 36
                
                if message?.fromId == uid {
                    
                    bubbleView.backgroundColor = .mainColor
                    textView.textColor = .black
                    
                    bubbleRight?.isActive = true
                    bubbleLeft?.isActive = false
                    
                } else {
                    
                    bubbleView.backgroundColor = .secondColor
                    textView.textColor = .white
                    
                    bubbleRight?.isActive = false
                    bubbleLeft?.isActive = true
                    
                }
                
                textView.text = text
            }
        }
    }
    
    let bubbleView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .secondColor
        return view
    }()
    
    let textView: UITextView = {
        let tv = UITextView()
        tv.isEditable = false
        tv.isSelectable = false
        tv.isScrollEnabled = false
        tv.text = "Loading"
        tv.font = .mainFont(ofSize: 22, weight: .regular)
        tv.textColor = .white
        tv.backgroundColor = .clear
        tv.contentInset = UIEdgeInsets(top: 1, left: 1, bottom: 0.5, right: 0.5)
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        message?.fromId == currentUserUid ? bubbleView.roundCorners(corners: [.topLeft, .topRight, .bottomLeft], radius: 14) : bubbleView.roundCorners(corners: [.topLeft, .topRight, .bottomRight], radius: 14)
    }
    
    var bubbleLeft: NSLayoutConstraint?
    var bubbleRight: NSLayoutConstraint?
    var bubbleWidth: NSLayoutConstraint?
    
    private func setupViews() {
        // add subviews
        self.addSubview(bubbleView)
        bubbleView.addSubview(textView)
        
        // x, y, w, h
        bubbleRight = bubbleView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8)
        bubbleRight?.isActive = true
        
        bubbleLeft = bubbleView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8)
        bubbleLeft?.isActive = false
        
        bubbleView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        
        bubbleWidth = bubbleView.widthAnchor.constraint(equalToConstant: 200)
        bubbleWidth?.isActive = true
        
        bubbleView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        
        textView.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor).isActive = true
        textView.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor).isActive = true
        textView.widthAnchor.constraint(equalTo: bubbleView.widthAnchor, constant: -4).isActive = true
        textView.heightAnchor.constraint(equalTo: bubbleView.heightAnchor, constant: -4).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - About cells
class SocialCell: UICollectionViewCell {
    
    var social: Social? {
        didSet {
            
            if let title = social?.title, let icon = social?.icon {
                
                label.text = title
                iconView.image = icon
            }
        }
    }
    
    let iconView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    let label: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = .mainFont(ofSize: 18, weight: .semibold)
        lbl.textColor = .secondColor
        return lbl
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    private func setupViews() {
        // add subviews
        self.addSubview(iconView)
        self.addSubview(label)
        
        // x, y, w, h
        iconView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        iconView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        iconView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 1/2).isActive = true
        iconView.widthAnchor.constraint(equalTo: iconView.heightAnchor).isActive = true
        
        label.leftAnchor.constraint(equalTo: iconView.rightAnchor, constant: 8).isActive = true
        label.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: iconView.centerYAnchor).isActive = true
        label.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/*
  _____       _____
 /( )   \=== /     \----------------.
|       |   |       |--------------  \
|       |   |       |              \_/
 \_____/     \_____/
 
 */
