//
//  Extensions+constants.swift
//  Petfind
//
//  Created by Didami on 21/01/22.
//

import UIKit
import AVFoundation
import MapKit

extension String {
    
    public func localized() -> String {
        return NSLocalizedString(self, tableName: "Localizable", bundle: .main, value: self, comment: self)
    }
}

struct Screen {
    
    static var width: CGFloat {
        return UIScreen.main.bounds.width
    }
    
    static var height: CGFloat {
        return UIScreen.main.bounds.height
    }
}

func animatedImages(for name: String) -> [UIImage] {
    
    var i = 0
    var images = [UIImage]()
    
    while let image = UIImage(named: "\(name)/\(i)") {
        images.append(image)
        i += 1
    }
    
    return images
}

let sideMenuCellId = "sideMenuCellId"

enum UserDefaultsKey: String {
    case skipCoachMarks1
    case skipCoachMarks2
    case passedPetsIds
}

enum FieldType: String {
    case open
    case closed
}

extension UIColor {
    // TODO: - Change colors
    
//    static let mainColor = UIColor(r: 188, g: 204, b: 215)
//    static let mainColor = UIColor(r: 233, g: 222, b: 206)
    static let mainColor = UIColor(r: 212, g: 227, b: 203)
    
//    static let secondColor = UIColor(r: 69, g: 95, b: 108)
//    static let secondColor = UIColor(r: 91, g: 75, b: 73)
    static let secondColor = UIColor(r: 102, g: 124, b: 102)
    
    static let accentColor = UIColor(r: 91, g: 75, b: 73)
    
    static let mainGray = UIColor(r: 82, g: 82, b: 82)
    static let mainLightGray = UIColor(r: 180, g: 180, b: 180)
    
    static let mainRed = UIColor(r: 252, g: 70, b: 93)
    static let mainGreen = UIColor(r: 49, g: 193, b: 109)
    
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat) {
        self.init(red: r/255, green: g/255, blue: b/255, alpha: 1)
    }
}

extension UIFont {
    
    func withWeight(_ weight: UIFont.Weight) -> UIFont {
        var attributes = fontDescriptor.fontAttributes
        var traits = (attributes[.traits] as? [UIFontDescriptor.TraitKey: Any]) ?? [:]

        traits[.weight] = weight

        attributes[.name] = nil
        attributes[.traits] = traits
        attributes[.family] = familyName

        let descriptor = UIFontDescriptor(fontAttributes: attributes)

        return UIFont(descriptor: descriptor, size: pointSize)
    }
    
    class func mainFont(ofSize size: CGFloat, weight: UIFont.Weight) -> UIFont {
        
        let systemFont = UIFont.systemFont(ofSize: size, weight: weight)

        if let font = UIFont(name: "Montserrat", size: size)?.withWeight(weight) {

            return font
        }
        
        return systemFont
    }
}

/// A segmented control with no corner radius.
class PlainSegmentedControl: UISegmentedControl {
    
    override init(items: [Any]?) {
        super.init(items: items)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = 0
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public func openUrl(_ url: String) {
    
    if let url = URL(string: url) {
        UIApplication.shared.open(url)
    }
}

var player: AVPlayer?
extension UIViewController {
    
    public func setUpVideoBgWith(name: String, ext: String) {
        
        let videoURL: URL = Bundle.main.url(forResource: name, withExtension: ext)!
        
        player = AVPlayer(url: videoURL)
        player?.actionAtItemEnd = .none
        player?.isMuted = true
        
        _ = try? AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: .default, options: .mixWithOthers)
        
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspectFill
        playerLayer.zPosition = -1
        playerLayer.frame = view.frame
        
        view.layer.addSublayer(playerLayer)
        
        player?.play()
            
        // loop video
        NotificationCenter.default.addObserver(self,
            selector: #selector(loopVideo),
            name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
            object: nil)
    }
    
    @objc private func loopVideo() {
        player?.seek(to: .zero)
        player?.play()
    }
    
    public func mainAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.view.tintColor = .secondColor
        alert.addAction(UIAlertAction(title: "got it".localized(), style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
        
    }
    
    @objc public func endEditing() {
        view.endEditing(true)
    }
}

extension UIView {
    
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }

    func applyShadow(radius: CGFloat, opacity: Float, offset: CGSize, color: UIColor = .black) {
        layer.shadowRadius = radius
        layer.shadowOpacity = opacity
        layer.shadowOffset = offset
        layer.shadowColor = color.cgColor
    }
}

extension UICollectionView {

    func setEmptyMessage(_ message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = .secondColor
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.font = .mainFont(ofSize: 18, weight: .medium)
        messageLabel.sizeToFit()

        self.backgroundView = messageLabel
    }

    func restore() {
        self.backgroundView = nil
    }
}

class MapViewController: UIViewController {
    
    var mapView = MKMapView()
    
    var location: CLLocation? {
        didSet {
            
            if let location = location {
                mapView.centerToLocation(location)
                loadingView.remove(completion: nil)
            }
        }
    }
    
    var locationName: String? {
        didSet {
            
            loadingView.presentIn(self, backgroundColor: .white)
            
            if let name = locationName {
                
                getLocation(forPlaceCalled: name) { [weak self] location in
                    self?.location = location
                }
            }
        }
    }
    
    let loadingView = LoadingView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .mainColor
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close".localized(), style: .done, target: self, action: #selector(handleDismiss))
        
        mapView.translatesAutoresizingMaskIntoConstraints = false
        
        // add subviews
        view.addSubview(mapView)
        
        // x, y, w, h
        mapView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        mapView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        mapView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        mapView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
    }
    
    @objc private func handleDismiss() {
        dismiss(animated: true, completion: nil)
    }
}

public func getLocation(forPlaceCalled name: String,
                     completion: @escaping(CLLocation?) -> Void) {
        
    let geocoder = CLGeocoder()
    geocoder.geocodeAddressString(name) { placemarks, error in
            
        guard error == nil else {
            print("*** Error in \(#function): \(error!.localizedDescription)")
            completion(nil)
            return
        }
            
        guard let placemark = placemarks?[0] else {
            print("*** Error in \(#function): placemark is nil")
            completion(nil)
            return
        }
            
        guard let location = placemark.location else {
            print("*** Error in \(#function): placemark is nil")
            completion(nil)
            return
        }

        completion(location)
    }
}

extension MKMapView {
    
    func centerToLocation(_ location: CLLocation) {
        
        let locValue: CLLocationCoordinate2D = location.coordinate

        mapType = .standard

        let span = MKCoordinateSpan(latitudeDelta: 60, longitudeDelta: 60)
        let region = MKCoordinateRegion(center: locValue, span: span)
        setRegion(region, animated: true)

        let annotation = MKPointAnnotation()
        annotation.coordinate = locValue
        addAnnotation(annotation)
    }
}

extension UIScrollView {
    
    public func scrollToBottom() {
        
        let bottomOffset = CGPoint(x: 0, y: self.contentSize.height - self.bounds.height + self.contentInset.bottom)
        self.setContentOffset(bottomOffset, animated: true)
    }
}

public func estimatedFrameForText(text: String) -> CGRect {

    let maxSize = CGSize(width: (Screen.width / 2) + 24, height: CGFloat(MAXFLOAT))

    return NSString(string: text).boundingRect(with: maxSize, options: [.truncatesLastVisibleLine, .usesLineFragmentOrigin], attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 22, weight: .medium)], context: nil)
}

/*
  _____       _____
 /( )   \=== /     \----------------.
|       |   |       |--------------  \
|       |   |       |              \_/
 \_____/     \_____/
 
 */

