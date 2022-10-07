//
//  ChatLogController.swift
//  Petfind
//
//  Created by Didami on 19/02/22.
//

import UIKit

class ChatLogController: UIViewController {
    
    var user: User? {
        didSet {
            
            if let username = user?.username, let email = user?.email {
                
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.lineSpacing = 10
                
                let attrString = NSMutableAttributedString(string: "@\(username)\n", attributes: [NSAttributedString.Key.font: UIFont.mainFont(ofSize: 26, weight: .bold), NSAttributedString.Key.foregroundColor: UIColor.secondColor, NSAttributedString.Key.paragraphStyle: paragraphStyle])
                
                attrString.append(NSAttributedString(string: email, attributes: [NSAttributedString.Key.font: UIFont.mainFont(ofSize: 21, weight: .regular), NSAttributedString.Key.foregroundColor: UIColor.mainGray]))
                
                textView.attributedText = attrString
            }
        }
    }
    
    var isChatPartnerInterested = false
    
    var pet: Pet?
    
    var messages = [Message]() {
        didSet {
            
            collectionView.reloadData()
            scrollCollectionToBottom()
        }
    }
    
    var messagesHavePresented = false
    
    let cellId = "cellId"
    
    let textView: UITextView = {
        let tv = UITextView()
        tv.isEditable = false
        tv.isSelectable = false
        tv.isScrollEnabled = false
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = .clear
        return tv
    }()
    
    lazy var navBar: UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .mainColor.withAlphaComponent(0.4)
        
        let leftButton = UIButton(type: .system)
        leftButton.translatesAutoresizingMaskIntoConstraints = false
        leftButton.tintColor = .secondColor
        leftButton.setImage(UIImage(systemName: "arrow.left"), for: .normal)
        leftButton.addTarget(self, action: #selector(handleLeftButton), for: .touchUpInside)
        
        container.addSubview(leftButton)
        container.addSubview(textView)
        
        leftButton.leftAnchor.constraint(equalTo: container.leftAnchor, constant: 8).isActive = true
        leftButton.topAnchor.constraint(equalTo: container.safeAreaLayoutGuide.topAnchor, constant: 8).isActive = true
        leftButton.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -20).isActive = true
        leftButton.widthAnchor.constraint(equalTo: leftButton.heightAnchor).isActive = true
        
        textView.leftAnchor.constraint(equalTo: leftButton.rightAnchor, constant: 8).isActive = true
        textView.rightAnchor.constraint(equalTo: container.rightAnchor, constant: -20).isActive = true
        textView.centerYAnchor.constraint(equalTo: leftButton.centerYAnchor).isActive = true
        textView.heightAnchor.constraint(equalTo: leftButton.heightAnchor).isActive = true
        
        return container
    }()
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 25
        layout.sectionInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .clear
        cv.showsVerticalScrollIndicator = false
        cv.alwaysBounceVertical = true
        cv.keyboardDismissMode = .interactive
        
        cv.delegate = self
        cv.dataSource = self
        cv.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
        
        return cv
    }()
    
    // MARK: Input
    let inputTextField: UITextField = {
        let tf = UITextField()
        let attrText = NSAttributedString(string: "Type something ...".localized(), attributes: [NSAttributedString.Key.font: UIFont.mainFont(ofSize: 18, weight: .regular), NSAttributedString.Key.foregroundColor: UIColor.mainGray])
        
        tf.attributedPlaceholder = attrText
        tf.textColor = .mainGray
        tf.font = .mainFont(ofSize: 18, weight: .regular)
        
        tf.backgroundColor = .white
        
        tf.layer.masksToBounds = true
        tf.layer.cornerRadius = 20
        
        tf.leftViewMode = .always
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: tf.frame.size.height))
        
        tf.returnKeyType = .send
        tf.translatesAutoresizingMaskIntoConstraints = false
        
        return tf
    }()
    
    let sendButton = UIButton(type: .system)
    
    lazy var inputContainerView: UIView = {
        let containerView = UIView()
        containerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 120)
        containerView.backgroundColor = .mainColor
        
        sendButton.setTitle("Send".localized(), for: .normal)
        sendButton.setTitleColor(.mainColor, for: .normal)
        sendButton.titleLabel?.font = .mainFont(ofSize: 18, weight: .semibold)
        sendButton.backgroundColor = .secondColor
        sendButton.layer.masksToBounds = true
        sendButton.layer.cornerRadius = 12
        sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        
        // add subviews
        containerView.addSubview(sendButton)
        containerView.addSubview(self.inputTextField)
        
        // x, y, w, h
        sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -8).isActive = true
        sendButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 25).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 1/2, constant: -10).isActive = true
        
        self.inputTextField.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 15).isActive = true
        self.inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor, constant: -10).isActive = true
        self.inputTextField.centerYAnchor.constraint(equalTo: sendButton.centerYAnchor).isActive = true
        self.inputTextField.heightAnchor.constraint(equalTo: sendButton.heightAnchor, constant: 20).isActive = true
        
        return containerView
    }()
    
    override var inputAccessoryView: UIView? {
        get {
            return inputContainerView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
        navBar.heightAnchor.constraint(equalToConstant: Screen.height / 5).isActive = true
        
        collectionView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: navBar.bottomAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -120).isActive = true
        collectionView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
    }
    
    private func scrollCollectionToBottom() {
        let item = self.collectionView(self.collectionView, numberOfItemsInSection: 0) - 1
        self.collectionView.scrollToItem(at: IndexPath(item: item, section: 0), at: .top, animated: true)
    }
    
    func fetchMessages() {
        
        guard let chatPartnerId = user?.userId else { return }
        DatabaseManager.shared.fetchMessagesWith(chatPartnerId) { [weak self] result in
            
            switch result {
                
            case .success(var messages):
                
                messages.sort { message1, message2 in
                    guard let timestamp1 = message1.timestamp?.intValue, let timestamp2 = message2.timestamp?.intValue else { return false }
                    return timestamp1 < timestamp2
                }
                
                self?.messages = messages
                
            case .failure(let err):
                print(err.localizedDescription)
            }
        }
    }
    
    @objc private func handleSend() {
        
        if let text = inputTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), let partnerId = user?.userId {
            
            if text == "" {
                return
            }
            
            if isChatPartnerInterested {
                
                guard let petId = pet?.petId else { return }
                
                FirestoreManager.shared.removeLikedPetFromUser(with: partnerId, petId: petId) { [weak self] success in
                    
                    if !success {
                        self?.mainAlert(title: "Oops!".localized(), message: "Something went wrong.".localized())
                        return
                    }
                }
                
//                DatabaseManager.shared.removeLikedPetFromUser(with: partnerId, petId: petId, petType: petType) { [weak self] success in
//                }
            }
            
            DatabaseManager.shared.sendMessage(to: partnerId, text: text) { [weak self] success in
                
                if success {
                    self?.inputTextField.text = nil
                }
            }
        }
    }

    @objc private func handleLeftButton() {
        navigationController?.popViewController(animated: true)
    }
}

extension ChatLogController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
  
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var height: CGFloat = 80
        
        if let text = messages[indexPath.item].text {
            height = estimatedFrameForText(text: text).height + 24
        }
        
        return CGSize(width: collectionView.frame.size.width, height: height)
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
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as? ChatMessageCell else { return UICollectionViewCell() }
        cell.message = messages[indexPath.item]
        return cell
    }
}
