//
//  OnboardingController.swift
//  Petfind
//
//  Created by Didami on 26/03/22.
//

import UIKit

class OnboardingController: UIViewController {
    
    var onboardingImages = [UIImage]()
    let animationsDuration = 0.6
    
    let cellId = "cellId"
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.contentInsetAdjustmentBehavior = .never
        cv.backgroundColor = .clear
        cv.alpha = 0
        return cv
    }()
    
    lazy var pageControl: UIPageControl = {
        let pc = UIPageControl()
        pc.translatesAutoresizingMaskIntoConstraints = false
        pc.currentPage = 0
        pc.numberOfPages = 3
        pc.isUserInteractionEnabled = false
        pc.alpha = 0
        return pc
    }()
    
    let quoteTextView: UITextView = {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.isEditable = false
        tv.isSelectable = false
        tv.isScrollEnabled = false
        tv.isUserInteractionEnabled = false
        tv.backgroundColor = .clear
        tv.textAlignment = .natural
        return tv
    }()
    
    lazy var continueButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.backgroundColor = .secondColor
        btn.setTitle("Got it".localized(), for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .mainFont(ofSize: 14, weight: .semibold)
        btn.layer.masksToBounds = true
        btn.layer.cornerRadius = 16
        btn.alpha = 0
        btn.addTarget(self, action: #selector(handleButton(_:)), for: .touchUpInside)
        return btn
    }()
    
    lazy var logoImgView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.image = UIImage(named: "icon")
        iv.alpha = 0
        return iv
    }()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        handleAnimations()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barTintColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.4)
        navigationController?.navigationBar.barStyle = .black
    }
    
    lazy var firstQuote = createQuoteAttrText(title: "Fill your heart with paws".localized(), message: "fill paws with your heart".localized())
    
    private func setupViews() {
        view.backgroundColor = .mainColor
        navigationController?.navigationBar.isHidden = true
        
        setupCollectionView()
        quoteTextView.attributedText = firstQuote
        
        // add subviews
        view.addSubview(collectionView)
        view.addSubview(pageControl)
        view.addSubview(continueButton)
        view.addSubview(quoteTextView)
        view.addSubview(logoImgView)
        
        // x, y, w, h anchors
        collectionView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        collectionView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8).isActive = true
        pageControl.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -12).isActive = true
        pageControl.heightAnchor.constraint(equalToConstant: 28).isActive = true
        
        continueButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        continueButton.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -40).isActive = true
        continueButton.bottomAnchor.constraint(equalTo: pageControl.topAnchor, constant: -4).isActive = true
        continueButton.heightAnchor.constraint(equalToConstant: 60).isActive  = true
        
        quoteTextView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        quoteTextView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        quoteTextView.bottomAnchor.constraint(equalTo: continueButton.topAnchor, constant: -8).isActive = true
        quoteTextView.heightAnchor.constraint(equalToConstant: 130).isActive = true
        
        logoImgView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        logoImgView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50).isActive = true
        logoImgView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1/2, constant: 20).isActive = true
        logoImgView.heightAnchor.constraint(equalTo: logoImgView.widthAnchor).isActive = true
    }
    
    private func setupCollectionView() {
        // delegate + datasource
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // properties
        collectionView.isUserInteractionEnabled = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isPagingEnabled = true
        
        // register cell class
        collectionView.register(OnboardingCell.self, forCellWithReuseIdentifier: cellId)
        
        // add images
        for x in 1...pageControl.numberOfPages {
            guard let img = UIImage(named: "onboarding_img\(x)") else { return }
            onboardingImages.append(img)
        }
    }
    
    @objc private func handleButton(_ sender: UIButton) {
        
        let authController = UINavigationController(rootViewController: AuthController())
        authController.modalPresentationStyle = .fullScreen
        present(authController, animated: true, completion: nil)
    }
    
    // MARK: - Animations
    private func handleAnimations() {
        
        UIView.animate(withDuration: animationsDuration) {
            self.collectionView.alpha = 1
            self.pageControl.alpha = 1
        }
    }
    
    func hideQuoteTextView() {
        
        UIView.animate(withDuration: animationsDuration) {
            self.quoteTextView.alpha = 0
        }
    }
    
    func setQuoteText(attrText: NSMutableAttributedString, completion: (() -> Void)? = nil) {
        collectionView.isUserInteractionEnabled = false
        
        UIView.animate(withDuration: animationsDuration) {
            self.quoteTextView.alpha = 0
        } completion: { _ in
            
            self.quoteTextView.attributedText = attrText
            
            UIView.animate(withDuration: self.animationsDuration) {
                self.quoteTextView.alpha = 1
            } completion: { _ in
                
                self.collectionView.isUserInteractionEnabled = true
                
                if completion != nil {
                    completion!()
                }
            }
        }
    }
    
    func buttonsShowing(_ showing: Bool) {
        
        if showing {
            
            continueButton.isEnabled = true
            
            UIView.animate(withDuration: animationsDuration) {
                self.view.layoutIfNeeded()
                self.continueButton.alpha = 1
                self.logoImgView.alpha = 1
            }
        } else {
            
            continueButton.isEnabled = false
            
            UIView.animate(withDuration: animationsDuration) {
                self.continueButton.alpha = 0
                self.logoImgView.alpha = 0
                self.view.layoutIfNeeded()
            }
        }
    }
    
    private func handlePageControlChange(currentPage: Int) {
        
        pageControl.currentPage = currentPage
        
        switch currentPage {
        case 0:
            // 1
            setQuoteText(attrText: firstQuote)
            buttonsShowing(false)
        case 1:
            // 2
            setQuoteText(attrText: createQuoteAttrText(title: "Help animals".localized(), message: "help yourself".localized()))
            buttonsShowing(false)
        case 2:
            // 3
            setQuoteText(attrText: createQuoteAttrText(title: "Petfind", message: "your new pet in a swipe".localized())) {
                
                self.buttonsShowing(true)
                
                self.collectionView.isScrollEnabled = false
                self.pageControl.alpha = 0
            }
            
        default:
            break
        }
    }
    
    func createQuoteAttrText(title: String, message: String) -> NSMutableAttributedString {
        
        let attributedText = NSMutableAttributedString(string: "\(title)\n", attributes: [NSAttributedString.Key.font: UIFont.mainFont(ofSize: 28, weight: .bold)])
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 8
        
        attributedText.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attributedText.length))
        
        attributedText.append(NSAttributedString(string: message, attributes: [NSAttributedString.Key.font: UIFont.mainFont(ofSize: 22, weight: .regular)]))
        attributedText.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.white, range: NSMakeRange(0, attributedText.length))
        
        return attributedText
    }
}

// MARK: - Delegates
extension OnboardingController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let width = scrollView.frame.width
        let currentPage = Int(scrollView.contentOffset.x / width)
        
        handlePageControlChange(currentPage: currentPage)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return onboardingImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as? OnboardingCell else { return UICollectionViewCell() }
        cell.imgView.image = onboardingImages[indexPath.item]
        return cell
    }
}

/*
  _____       _____
 /( )   \=== /     \----------------.
|       |   |       |--------------  \
|       |   |       |              \_/
 \_____/     \_____/
 
 */
