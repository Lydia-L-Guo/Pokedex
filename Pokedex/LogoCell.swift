//
//  LogoCell.swift
//  Pokedex
//
//  Created by Lydia Guo on 2024/10/21.
//

import Foundation
import UIKit

class LogoCell: UICollectionViewCell {
    let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    func loadImage(url: URL, cache: NSCache<NSString, UIImage>) {
        if let cachedImage = cache.object(forKey: url.absoluteString as NSString) {
            imageView.image = cachedImage
            return
        }
        
        imageView.image = nil
        
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url),
               let image = UIImage(data: data) {
                cache.setObject(image, forKey: url.absoluteString as NSString)
                DispatchQueue.main.async {
                    self.imageView.image = image
                }
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension UIImageView {
    func loadImage(url: URL, cache: NSCache<NSString, UIImage>) {
        if let cachedImage = cache.object(forKey: url.absoluteString as NSString) {
            self.image = cachedImage
            return
        }
        
        self.image = nil
        
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url),
               let image = UIImage(data: data) {
                cache.setObject(image, forKey: url.absoluteString as NSString)
                DispatchQueue.main.async {
                    self.image = image
                }
            }
        }
    }
}
