//
//  MovieRepository.swift
//  Rotten Tomatoes
//
//  Created by Marcel Molina on 9/18/15.
//  Copyright © 2015 Marcel Molina. All rights reserved.
//

import Foundation

class MovieRepository {
  typealias Callback = () -> ()
  typealias SearchQuery = [String]

  private var _client: RottenTomatoesClient!

  init(client: RottenTomatoesClient) {
    self._client = client
  }

  convenience init() {
    self.init(client: RottenTomatoesClient())
  }

  var searchQuery: SearchQuery?
  var shouldSimulateRefresh = false

  var movies: [Movie] {
    get {
      return _movies[urlToLoad].map { movies in
        searchQuery.map { queries in
          moviesMatchingSearchQuery(movies, searchQuery: queries)
          } ?? movies
        } ?? []
    }

    set {
      // TODO Succeptible to race condition if tab is changed before request is completed
      _movies[urlToLoad] = newValue
    }
  }

  private var _movies = Dictionary<RottenTomatoesClient.ApiUrl, [Movie]>()

  var urlToLoad: RottenTomatoesClient.ApiUrl!

  var client: RottenTomatoesClient {
    get {
      if shouldSimulateRefresh {
        return RefreshSimulatingRottenTomatoesClient(_client)
      } else {
        return _client
      }
    }
  }

  func loadMovies(onCompletion: Callback? = nil) {
    client.load(urlToLoad) { movies in
      self.movies = movies ?? []
      onCompletion?()
    }
  }

  func hasLoadedUrl() -> Bool {
    return _movies[urlToLoad] != nil
  }

  func simulatingNewResults(callback: Callback) {
    shouldSimulateRefresh = true
    callback()
    shouldSimulateRefresh = false
  }

  func moviesMatchingSearchQuery(movies: [Movie], searchQuery: SearchQuery) -> [Movie] {
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