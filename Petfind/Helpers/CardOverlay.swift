//
//  CardOverlay.swift
//  Petfind
//
//  Created by Didami on 30/01/22.
//

import UIKit
import Shuffle_iOS

class CardOverlay: UIView {

    init(direction: SwipeDirection) {
        super.init(frame: .zero)
        switch direction {
        case .left:
            createLeftOverlay()
        case .up:
            createUpOverlay()
        case .right:
            createRightOverlay()
        case .down:
            createDownOverlay()
        default:
          break
        }
    }

    required init?(coder: NSCoder) {
      return nil
    }

    private func createLeftOverlay() {
        let leftTextView = CardOverlayLabelView(withTitle: "NOPE",
                                                    color: .cardRed,
                                                    rotation: CGFloat.pi / 10)
        addSubview(leftTextView)
        
        leftTextView.translatesAutoresizingMaskIntoConstraints = false
        
        leftTextView.topAnchor.constraint(equalTo: topAnchor, constant: 30).isActive = true
        leftTextView.rightAnchor.constraint(equalTo: rightAnchor, constant: -14).isActive = true
        
    }

    private func createUpOverlay() {
        let upTextView = CardOverlayLabelView(withTitle: "LOVE",
                                                  color: .cardBlue,
                                                  rotation: -CGFloat.pi / 20)
        addSubview(upTextView)
        
        upTextView.translatesAutoresizingMaskIntoConstraints = false
        
        upTextView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -150).isActive = true
        upTextView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    }
    
    private func createRightOverlay() {
        let rightTextView = CardOverlayLabelView(withTitle: "YES",
                                                     color: .cardGreen,
                                                     rotation: -CGFloat.pi / 10)
        addSubview(rightTextView)

        rightTextView.translatesAutoresizingMaskIntoConstraints = false
        
        rightTextView.topAnchor.constraint(equalTo: topAnchor, constant: 26).isActive = true
        rightTextView.leftAnchor.constraint(equalTo: leftAnchor, constant: 14).isActive = true
    }
    
    private func createDownOverlay() {
        let downTextView = CardOverlayLabelView(withTitle: "! ! !",
                                                  color: .cardDarkRed,
                                                  rotation: CGFloat.pi / 20)
        addSubview(downTextView)
        
        downTextView.translatesAutoresizingMaskIntoConstraints = false
        
        downTextView.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true
        downTextView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
    }
}

private class CardOverlayLabelView: UIView {

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()

    init(withTitle title: String, color: UIColor, rotation: CGFloat) {
        super.init(frame: CGRect.zero)
        
        layer.borderColor = color.cgColor
        layer.borderWidth = 4
        layer.cornerRadius = 4
        transform = CGAffineTransform(rotationAngle: rotation)

        addSubview(titleLabel)
        titleLabel.textColor = color
        titleLabel.attributedText = NSAttributedString(string: title,
                                                       attributes: NSAttributedString.Key.overlayAttributes)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
          
        titleLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 8).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -3).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
}

extension NSAttributedString.Key {

    static var overlayAttributes: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.font: UIFont.mainFont(ofSize: 42, weight: .bold),
        NSAttributedString.Key.kern: 5.0
    ]
}

extension UIColor {
    static var cardRed = UIColor(red: 252 / 255, green: 70 / 255, blue: 93 / 255, alpha: 1)
    static var cardDarkRed = UIColor(red: 202 / 255, green: 20 / 255, blue: 43 / 255, alpha: 1)
    static var cardGreen = UIColor(red: 49 / 255, green: 193 / 255, blue: 109 / 255, alpha: 1)
    static var cardBlue = UIColor(red: 52 / 255, green: 154 / 255, blue: 254 / 255, alpha: 1)
}
