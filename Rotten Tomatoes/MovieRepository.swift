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
  typealias ApiUrl = RottenTomatoesClient.ApiUrl

  private var _client: RottenTomatoesClient!

  init(client: RottenTomatoesClient) {
    self._client = client
  }

  convenience init() {
    self.init(client: RottenTomatoesClient())
  }

  var searchQuery: SearchQuery?
  private var shouldSimulateRefresh = false

  var movies = Dictionary<ApiUrl, [Movie]>()

  func moviesFor(url: ApiUrl) -> [Movie] {
    return movies[url].map { moviesForUrl in
      searchQuery.map { queries in
        moviesMatchingSearchQuery(moviesForUrl, searchQuery: queries)
        } ?? moviesForUrl
      } ?? []
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

  func simulatingNewResults(url: ApiUrl, callback: Callback) {
    shouldSimulateRefresh = true
    movies.removeValueForKey(url)
    callback()
    shouldSimulateRefresh = false
  }

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