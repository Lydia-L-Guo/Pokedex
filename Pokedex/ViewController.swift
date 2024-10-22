//
//  ViewController.swift
//  Pokedex
//
//  Created by Lydia Guo on 2024/10/21.
//

import UIKit

class ViewController: UIViewController {
    
    enum Section {
        case main
    }
    
    var dataSource: UICollectionViewDiffableDataSource<Section, Int>! = nil
    var collectionView: UICollectionView! = nil
    
    var pkList: [PKListItem] = []
    var pkDetail: [PKDetailItem?] = []
    
    var selectedImageView: UIImageView!
    var selectedNameLabel: UILabel!
    
    var isLoading = false
    var offset = 0
    let limit = 20
    var totalPokemons = 0
    
    let imageCache = NSCache<NSString, UIImage>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Pokédex"
        
        let backgroundImage = UIImageView(frame: view.bounds)
        backgroundImage.contentMode = .scaleAspectFill
        view.addSubview(backgroundImage)
        view.sendSubviewToBack(backgroundImage)
        
        configureSelectedImageView()
        configureHierarchy()
        configureDataSource()
        selectedImageView.image = UIImage(named: "Poke_Ball_icon")
        startLoad()
        collectionView.delegate = self
    }
}

extension ViewController {
    func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0 / 3.0),
            heightDimension: .fractionalWidth(1.0 / 3.0 * 1.3)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalWidth(1.0 / 3.0 * 1.3)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.interItemSpacing = .fixed(8)

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 8
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
}

extension ViewController {
    func configureSelectedImageView() {
        selectedImageView = UIImageView()
        selectedImageView.contentMode = .scaleAspectFit
        selectedImageView.translatesAutoresizingMaskIntoConstraints = false
        selectedImageView.layer.cornerRadius = 75
        selectedImageView.clipsToBounds = true
        selectedImageView.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        
        selectedImageView.layer.shadowColor = UIColor.black.cgColor
        selectedImageView.layer.shadowOpacity = 0.5
        selectedImageView.layer.shadowOffset = CGSize(width: 0, height: 5)
        selectedImageView.layer.shadowRadius = 10
        
        view.addSubview(selectedImageView)
        
        selectedNameLabel = UILabel()
        selectedNameLabel.font = UIFont(name: "ChalkboardSE-Bold", size: 24)
        selectedNameLabel.textColor = .white
        selectedNameLabel.textAlignment = .center
        selectedNameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(selectedNameLabel)
        
        NSLayoutConstraint.activate([
            selectedImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            selectedImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            selectedImageView.heightAnchor.constraint(equalToConstant: 150),
            selectedImageView.widthAnchor.constraint(equalToConstant: 150),
            
            selectedNameLabel.topAnchor.constraint(equalTo: selectedImageView.bottomAnchor, constant: 10),
            selectedNameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    func configureHierarchy() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: selectedNameLabel.bottomAnchor, constant: 20),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
     
    func configureDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<PokemonCell, Int> { [weak self] (cell, indexPath, identifier) in
            guard let self = self else { return }
            
            let pokemonDetail = self.pkDetail[identifier]
            cell.configure(with: pokemonDetail, cache: self.imageCache)
        }
        
        dataSource = UICollectionViewDiffableDataSource<Section, Int>(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, identifier: Int) -> UICollectionViewCell? in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: identifier)
        }

        var snapshot = NSDiffableDataSourceSnapshot<Section, Int>()
        snapshot.appendSections([.main])
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}

extension ViewController {
    func startLoad(){
        guard !isLoading else { return }
        isLoading = true
        
        let urlString = "https://pokeapi.co/api/v2/pokemon?limit=\(limit)&offset=\(offset)"
        guard let url = URL(string: urlString) else { return }

        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            self.isLoading = false

            guard let data = data else {
                print("No data received: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            do {
                let response = try JSONDecoder().decode(PKListResponse.self, from: data)
                self.totalPokemons = response.count
                let newPokemons = response.results
                let startIndex = self.pkList.count
                let newItemCount = newPokemons.count

                self.pkDetail.append(contentsOf: Array(repeating: nil, count: newItemCount))
                self.pkList.append(contentsOf: newPokemons)
                self.fetchPokemonDetails(startIndex: startIndex, itemCount: newItemCount)
                self.offset += self.limit
            } catch {
                print("JSON decoding failed: \(error)")
            }
        }

        task.resume()
    }
    
    func fetchPokemonDetails(startIndex: Int, itemCount: Int) {
        let group = DispatchGroup()
        
        for index in 0..<itemCount {
            let pokemonIndex = startIndex + index
            let pokemon = pkList[pokemonIndex]
            guard let url = pokemon.url else { continue }
            group.enter()
            
            let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                defer { group.leave() }
                guard let self = self else { return }
                guard let data = data else {
                    print("No data received: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                do {
                    let pokemonDetails = try JSONDecoder().decode(PKDetailResponse.self, from: data)
                    if let sprites = pokemonDetails.sprites,
                       let frontDefaultURLString = sprites.front_default,
                       let frontDefaultURL = URL(string: frontDefaultURLString) {

                        let updatedPokemonDetails = PKDetailItem(
                            sprites: sprites,
                            frontDefaultURL: frontDefaultURL,
                            name: pokemon.name
                        )

                        self.pkDetail[pokemonIndex] = updatedPokemonDetails
                    }
                } catch {
                    print("JSON decoding failed: \(error)")
                }
            }
            task.resume()
        }
        
        group.notify(queue: .main) {
            self.updateDataSource(startIndex: startIndex, itemCount: itemCount)
        }
    }
    
    func updateDataSource(startIndex: Int, itemCount: Int) {
        var snapshot = dataSource.snapshot()
        let newItems = Array(startIndex..<startIndex + itemCount)
        snapshot.appendItems(newItems)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let selectedPokemon = pkDetail[indexPath.item],
           let url = selectedPokemon.frontDefaultURL {
            selectedImageView.setImage(url: url, cache: imageCache)
            selectedNameLabel.text = selectedPokemon.name?.capitalized
            
            selectedImageView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 3, options: .curveEaseInOut, animations: {
                self.selectedImageView.transform = CGAffineTransform.identity
            }, completion: nil)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height

        if offsetY > contentHeight - scrollView.frame.size.height * 4 {
            if !isLoading && pkList.count < totalPokemons {
                startLoad()
            }
        }
    }
}

extension UIImageView {
    func setImage(url: URL, cache: NSCache<NSString, UIImage>) {
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
