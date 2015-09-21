//
//  MovieRepository.swift
//  Rotten Tomatoes
//
//  Created by Marcel Molina on 9/18/15.
//  Copyright © 2015 Marcel Molina. All rights reserved.
//

import Foundation

// Encapsulates access to movies returned by the RottenTomatoesClient.
//
// Provides:
// - Access to list of movies by endpoint (Box Office & DVD)
// - Sorting by release date, title or rating
// - Disjunction title and synposis search
class MovieRepository {
  // MARK: Typealiases
  typealias Callback = () -> ()
  typealias SearchQuery = [String]
  typealias ApiUrl = RottenTomatoesClient.ApiUrl
  typealias SortingPredicate = (Movie, Movie) -> Bool

  // MARK: Enums
  enum SortDescriptor {
    case ReleaseDate
    case Title
    case Rating
  }

  // MARK: - Properties

  var movies = Dictionary<ApiUrl, [Movie]>()
  var searchQuery: SearchQuery?

  private var _client: RottenTomatoesClient!

  // MARK: - Initializers

  init(client: RottenTomatoesClient) {
    self._client = client
  }

  convenience init() {
    self.init(client: RottenTomatoesClient())
  }

  // MARK: - Public Interface

  func moviesFor(url: ApiUrl) -> [Movie] {
    return movies[url].map { moviesForUrl in
      searchQuery.map { queries in
        moviesMatchingSearchQuery(moviesForUrl, searchQuery: queries)
        } ?? moviesForUrl
      } ?? []
  }

  func loadMovies(url: ApiUrl, onCompletion: Callback? = nil) {
    if hasLoadedUrl(url) {
      onCompletion?()
    } else {
      client.load(url) { movies in
        self.movies[url] = movies ?? []
        onCompletion?()
      }
    }
  }

  func hasLoadedUrl(url: ApiUrl) -> Bool {
    return movies[url] != nil
  }

  private var client: RottenTomatoesClient {
    get {
      if shouldSimulateRefresh {
        return RefreshSimulatingRottenTomatoesClient(_client)
      } else {
        return _client
      }
    }
  }

  // MARK: - Sorting

  var sortDescriptor: SortDescriptor {
    get { return _sortDescriptor }
    
    set {
      _sortDescriptor = newValue
      updateSorting()
    }
  }

  private var _sortDescriptor = SortDescriptor.ReleaseDate

  private func updateSorting() {
    let predicate = sortingPredicates(sortDescriptor)
    Synchronizer.synchronize(self) {
      for (url, moviesFromUrl) in self.movies {
        self.movies[url] = moviesFromUrl.sort(predicate)
      }
    }
  }

  private let sortingPredicates: SortDescriptor -> SortingPredicate = { descriptor in
    switch descriptor {
      case .Title:
        return { $0.title < $1.title }
      case .ReleaseDate:
        return { $0.releaseDate.compare($1.releaseDate) == NSComparisonResult.OrderedDescending }
      case .Rating:
        return { ($0.criticsRating.score ?? 0) > ($1.criticsRating.score ?? 0) }
    }
  }

  // MARK: - Refresh simulation

  private var shouldSimulateRefresh = false

  func simulatingNewResults(url: ApiUrl, callback: Callback) {
    shouldSimulateRefresh = true
    movies.removeValueForKey(url)
    callback()
    shouldSimulateRefresh = false
  }

  // MARK: - Search

  private func moviesMatchingSearchQuery(movies: [Movie], searchQuery: SearchQuery) -> [Movie] {
    return movies.filter { movie in
      let movieText = [movie.title, movie.synopsis]

      return searchQuery.any { query in
        movieText.any { text in
          text.localizedCaseInsensitiveContainsString(query)
        }
      }
    }
  }
}