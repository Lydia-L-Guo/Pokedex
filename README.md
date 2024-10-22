# Pokédex

This iOS application allows users to browse and view Pokémon images in a visually appealing and interactive manner. The app features scrolling with pagination, image caching, and a modern UI design.

## Features

- **Scrolling**: Loads Pokémon data in batches of 20, fetching more as the user scrolls down.
- **Image Caching**: Implements in-memory caching to reduce network calls and improve performance.
- **Interactive UI**: Displays selected Pokémon in a prominent area with animations.
- **UI Design**: Utilizes custom layouts, shadows, and rounded corners.


## Technical Decisions

### Manual Image Loading and Caching

- **Why Not Kingfisher?**: Instead of using external libraries like Kingfisher, the app manually handles image loading and caching to have finer control and reduce dependencies.
- **Caching Mechanism**: Utilizes `NSCache` to store downloaded images, improving performance and reducing network usage.

### Pagination

- **Implementation**: Fetches 20 Pokémon at a time using the `limit` and `offset` parameters provided by the PokéAPI.
- **Scroll Detection**: Implements `scrollViewDidScroll` to detect when the user scrolls near the bottom and triggers the loading of more data.
- **Data Consistency**: Maintains the order of Pokémon by keeping track of indices and updating data structures accordingly.

### UICollectionView and Diffable Data Source

- **Collection View**: Uses `UICollectionViewCompositionalLayout` for flexible and powerful layout customization.
- **Diffable Data Source**: Simplifies data management and provides smooth animations when updating the UI.