//
//  PokemonCell.swift
//  Pokedex
//
//  Created by Lydia Guo on 2024/10/21.
//

import Foundation
import UIKit

class PokemonCell: UICollectionViewCell {
    let imageView = UIImageView()
    let nameLabel = UILabel()
    let cardView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        cardView.layer.cornerRadius = 10
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.2
        cardView.layer.shadowOffset = CGSize(width: 0, height: 3)
        cardView.layer.shadowRadius = 5
        contentView.addSubview(cardView)
        
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        cardView.addSubview(imageView)
        
        nameLabel.font = UIFont(name: "GillSans-Bold", size: 14)
        nameLabel.textColor = .black
        nameLabel.textAlignment = .center
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(nameLabel)
        
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            imageView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 8),
            imageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 8),
            imageView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -8),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
            
            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 4),
            nameLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 4),
            nameLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -4),
            nameLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -8)
        ])
    }
    
    func configure(with pokemonDetail: PKDetailItem?, cache: NSCache<NSString, UIImage>) {
        if let pokemonDetail = pokemonDetail,
           let url = pokemonDetail.frontDefaultURL {
            imageView.setImage(url: url, cache: cache)
            nameLabel.text = pokemonDetail.name?.capitalized
        } else {
            imageView.image = nil
            nameLabel.text = ""
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
