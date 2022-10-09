//
//  AuthController.swift
//  Petfind
//
//  Created by Didami on 21/01/22.
//

import UIKit
import CoreLocation

class AuthController: UIViewController {
    
    var selectedIndex = 0 {
        didSet {
            
            button.isSelected = false
            
            if selectedIndex == 0 {
                
                if emailTextField.text?.isEmpty == false && passwordTextField.text?.isEmpty == false {
                    button.isUserInteractionEnabled = true
                    button.backgroundColor = .secondColor
                }
                
                selectedViewLeft?.isActive = true
                selectedViewRight?.isActive = false
                
                termsTextView.isUserInteractionEnabled = false
                
                UIView.animate(withDuration: 0.3) {
                    self.stackView.alpha = 0
                    self.button.alpha = 0
                    self.termsTextView.alpha = 0
                    self.view.layoutIfNeeded()
                } completion: { _ in
                    self.button.setTitle("Login".localized(), for: .normal)
                    self.passwordTextField.placeholder = "Password".localized()
                    self.usernameTextField.removeFromSuperview()
                    
                    UIView.animate(withDuration: 0.3) {
                        self.stackView.alpha = 1
                        self.button.alpha = 1
                    }
                }
                
            } else {
                
                if usernameTextField.text?.isEmpty == true {
                    button.isUserInteractionEnabled = false
                    button.backgroundColor = .mainColor
                }
                
                selectedViewRight?.isActive = true
                selectedViewLeft?.isActive = false
                
                termsTextView.isUserInteractionEnabled = true
                
                UIView.animate(withDuration: 0.3) {
                    self.stackView.alpha = 0
                    self.button.alpha = 0
                    self.view.layoutIfNeeded()
                } completion: { _ in
                    self.button.setTitle("Sign up".localized(), for: .normal)
                    self.passwordTextField.placeholder = "Create a password".localized()
                    self.stackView.insertArrangedSubview(self.usernameTextField, at: 1)
                    
                    UIView.animate(withDuration: 0.3) {
                        self.stackView.alpha = 1
                        self.button.alpha = 1
                        self.termsTextView.alpha = 1
                    }
                }
            }
        }
    }
    
    lazy var contentView: UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .white
        container.layer.cornerRadius = 8
        
        container.addSubview(imageView)
        container.addSubview(segmentedControl)
        container.addSubview(stackView)
        container.addSubview(button)
        container.addSubview(termsTextView)
        
        imageView.centerXAnchor.constraint(equalTo: container.centerXAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: container.topAnchor, constant: 35).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor).isActive = true
        
        segmentedControl.centerXAnchor.constraint(equalTo: container.centerXAnchor).isActive = true
        segmentedControl.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 35).isActive = true
        segmentedControl.widthAnchor.constraint(equalTo: container.widthAnchor, constant: -24).isActive = true
        
        segmentedControlHeight = segmentedControl.heightAnchor.constraint(equalToConstant: 50)
        segmentedControlHeight?.isActive = true
        
        stackView.centerXAnchor.constraint(equalTo: container.centerXAnchor).isActive = true
        
        stackViewTop = stackView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 20)
        stackViewTop?.isActive = true
        
        stackView.widthAnchor.constraint(equalTo: container.widthAnchor, constant: -40).isActive = true
        
        stackViewHeight = stackView.heightAnchor.constraint(equalTo: container.heightAnchor, multiplier: 1/3, constant: -10)
        stackViewHeight?.isActive = true
        
        button.centerXAnchor.constraint(equalTo: container.centerXAnchor).isActive = true
        button.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 30).isActive = true
        button.widthAnchor.constraint(equalTo: stackView.widthAnchor, constant: -40).isActive = true
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        termsTextView.centerXAnchor.constraint(equalTo: button.centerXAnchor).isActive = true
        termsTextView.topAnchor.constraint(equalTo: button.bottomAnchor, constant: 8).isActive = true
        termsTextView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -8).isActive = true
        termsTextView.widthAnchor.constraint(equalTo: button.widthAnchor).isActive = true
        
        return container
    }()
    
    let imageView: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "glyph"))
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.tintColor = .secondColor
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    var selectedViewLeft: NSLayoutConstraint?
    var selectedViewRight: NSLayoutConstraint?
    
    var segmentedControlHeight: NSLayoutConstraint?
    lazy var segmentedControl: PlainSegmentedControl = {
        let sc = PlainSegmentedControl(items: ["Login".localized(), "Sign up".localized()])
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.selectedSegmentIndex = 0
        sc.selectedSegmentTintColor = .clear
        sc.setBackgroundImage(UIImage(), for: .normal, barMetrics: .default)
        sc.setDividerImage(UIImage(), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
        sc.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.mainGray.withAlphaComponent(0.4), NSAttributedString.Key.font: UIFont.mainFont(ofSize: 17, weight: .regular)], for: .normal)
        sc.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.secondColor, NSAttributedString.Key.font: UIFont.mainFont(ofSize: 17, weight: .medium)], for: .selected)
        
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
    
    var stackViewHeight: NSLayoutConstraint?
    var stackViewTop: NSLayoutConstraint?
    lazy var stackView: UIStackView = {
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .vertical
        sv.distribution = .fillEqually
        sv.spacing = 20
        
        sv.addArrangedSubview(emailTextField)
        sv.addArrangedSubview(passwordTextField)
        
        return sv
    }()
    
    lazy var emailTextField: MainTextField = {
        let tf = MainTextField()
        tf.placeholder = "E-mail address".localized()
        tf.icon = UIImage(systemName: "envelope")
        tf.keyboardType = .emailAddress
        tf.autocorrectionType = .no
        tf.returnKeyType = .next
        tf.delegate = self
        return tf
    }()
    
    lazy var passwordTextField: MainTextField = {
        let tf = MainTextField()
        tf.placeholder = "Password".localized()
        tf.icon = UIImage(systemName: "lock")
        tf.isSecureTextEntry = true
        tf.returnKeyType = .done
        tf.delegate = self
        return tf
    }()
    
    lazy var usernameTextField: MainTextField = {
        let tf = MainTextField()
        tf.placeholder = "Create a username".localized()
        tf.icon = UIImage(systemName: "person")
        tf.returnKeyType = .next
        tf.delegate = self
        return tf
    }()
    
    lazy var button: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("Login".localized(), for: .normal)
        btn.setTitle("Loading ...".localized(), for: .selected)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .mainFont(ofSize: 18, weight: .bold)
        btn.backgroundColor = .mainColor
        btn.layer.masksToBounds = true
        btn.layer.cornerRadius = 4
        
        btn.isUserInteractionEnabled = false
        btn.addTarget(self, action: #selector(handleBtn(_:)), for: .touchUpInside)
        return btn
    }()
    
    lazy var termsTextView: UITextView = {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.isEditable = false
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = 4
        paragraph.alignment = .center
        
        let attrString = NSMutableAttributedString(string: "By signing up, you agree to our".localized() + " ", attributes: [NSAttributedString.Key.font: UIFont.mainFont(ofSize: 12, weight: .regular), NSAttributedString.Key.foregroundColor: UIColor.mainGray, NSAttributedString.Key.paragraphStyle: paragraph])
        
        attrString.append(NSAttributedString(string: "Terms and conditions".localized(), attributes: [NSAttributedString.Key.font: UIFont.mainFont(ofSize: 12, weight: .bold), NSAttributedString.Key.foregroundColor: UIColor.secondColor]))
        
        tv.attributedText = attrString
        tv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTermsLabel)))
        
        tv.alpha = 0
        tv.isUserInteractionEnabled = false
        
        return tv
    }()
    
    var locationManager: CLLocationManager?
    
    var countryCode: String? {
        didSet {
            _ = signUpUser
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    private func setupViews() {
        view.backgroundColor = .mainColor
        navigationController?.navigationBar.isHidden = true
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(endEditing)))
        
        // add subviews
        view.addSubview(contentView)
        
        // x, y, w, h
        contentView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        contentView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        contentView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -80).isActive = true
        contentView.heightAnchor.constraint(equalTo: view.heightAnchor, constant: -160).isActive = true
        
//        setUpVideoBgWith(name: "auth_bg", ext: "mov")
    }
    
    private func presentParent() {
        let vc = UINavigationController(rootViewController: ParentController())
        vc.modalTransitionStyle = .flipHorizontal
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }
    
    @objc private func handleSegmentedControl(_ sender: UISegmentedControl) {
        selectedIndex = sender.selectedSegmentIndex
    }
    
    @objc private func handleTermsLabel() {
        openUrl("https://app.websitepolicies.com/policies/view/rgq4ljqm/")
    }
    
    @objc private func handleBtn(_ sender: UIButton) {
        sender.isSelected = true
        
        guard let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), let password = passwordTextField.text else { return }
        
        if selectedIndex == 0 {
            
            if email == "" || password.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                mainAlert(title: "Oops!".localized(), message: "Please fill in all required fields.".localized())
                return
            }
            
            authWith(email: email, password: password) { [weak self] success in
                
                if !success {
                    self?.button.isSelected = false
                    self?.mainAlert(title: "Oops!".localized(), message: "An unexpected error occurred. Make sure the info is correct.".localized())
                    return
                }
                
                self?.presentParent()
            }
            
        } else if selectedIndex == 1 {
            
            locationManager = CLLocationManager()
            
            locationManager?.requestAlwaysAuthorization()
            locationManager?.requestWhenInUseAuthorization()

            if CLLocationManager.locationServicesEnabled() {
                locationManager?.delegate = self
                locationManager?.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            }
        }
    }
    
    private lazy var signUpUser: Void = {
        
        if let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), let password = passwordTextField.text, let username = usernameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), let location = countryCode {
            
            if email == "" || username == "" || password.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                button.isSelected = false
                mainAlert(title: "Oops!".localized(), message: "Please fill in all required fields.".localized())
                return
            }
            
            createUserWith(email: email, password: password, username: username, location: location) { [weak self] result in
                
                switch result {
                    
                case .success(let user):
                    
                    FirestoreManager.shared.insertUser(user) { [weak self] success in
                        
                        if !success {
                            self?.button.isSelected = false
                            self?.mainAlert(title: "Oops!".localized(), message: "An unexpected error occurred.".localized())
                            return
                        }
                        
                        self?.presentParent()
                    }
                    
                case .failure(let err):
                    self?.button.isSelected = false
                    self?.mainAlert(title: "Oops!".localized(), message: "An unexpected error occurred. E-mail address may be already taken or incorrect.".localized())
                    print(err.localizedDescription)
                }
            }
        }
    }()
}

extension AuthController: UITextFieldDelegate, CLLocationManagerDelegate {
    
    // MARK: - Text Field Delegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        segmentedControlHeight?.constant = 0
        
        stackViewTop?.isActive = false
        stackViewTop = stackView.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 35)
        stackViewTop?.isActive = true
        
        UIView.animate(withDuration: 0.4) {
            self.segmentedControl.alpha = 0
            self.view.layoutIfNeeded()
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        segmentedControlHeight?.constant = 50
        
        stackViewTop?.isActive = false
        stackViewTop = stackView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 20)
        stackViewTop?.isActive = true
        
        UIView.animate(withDuration: 0.4) {
            self.segmentedControl.alpha = 1
            self.view.layoutIfNeeded()
        }
        
        if emailTextField.text?.isEmpty == false && passwordTextField.text?.isEmpty == false {
            
            if selectedIndex == 0 {
                button.isUserInteractionEnabled = true
                button.backgroundColor = .secondColor
            } else {
                
                if usernameTextField.text?.isEmpty == false {
                    button.isUserInteractionEnabled = true
                    button.backgroundColor = .secondColor
                } else {
                    button.isUserInteractionEnabled = false
                    button.backgroundColor = .mainColor
                }
            }
        } else {
            button.isUserInteractionEnabled = false
            button.backgroundColor = .mainColor
        }
    }
    
    // MARK: - Location Manager Delegate
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        
        if manager.authorizationStatus == .notDetermined {
            return
        }
        
        if manager.authorizationStatus == .authorizedAlways || manager.authorizationStatus == .authorizedWhenInUse {
            manager.startUpdatingLocation()
        } else {
            mainAlert(title: "Oops!".localized(), message: "We would like to know your location to facilitate app usage.".localized())
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let lastLocation = locations.last {
            let geocoder = CLGeocoder()

            geocoder.reverseGeocodeLocation(lastLocation) { [weak self] (placemarks, error) in
                
                if error == nil {
                    
                    if let firstLocation = placemarks?[0],
                       
                        let countryCode = firstLocation.isoCountryCode {
                        
                        self?.countryCode = countryCode
                        self?.locationManager?.stopUpdatingLocation()
                        
                    }
                }
            }
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
