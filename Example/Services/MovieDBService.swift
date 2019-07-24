//
//  MovieDBService.swift
//  Example
//
//  Created by Nang Nguyen on 6/25/19.
//

import Foundation
import HttpClient
import PromiseKit

class MoviewDBService {
    
    func fetchMovies(page: Int, _ completion: @escaping (HTTPResult<[Movie]>) -> ()) {
        let request = PopularMoviesRequest(page: page)
        HTTPRequester.default.requestDecodable(request) { (result: HTTPResult<Movies>) in
            let result = result.map { moviesList in moviesList.results }
            completion(result)
        }
    }
    
    func fetchMovies(page: Int) -> Promise<[Movie]> {
        return Promise { seal in
            let request = PopularMoviesRequest(page: page)
            HTTPRequester.default.requestDecodable(request)
                .done { (result: Movies) in
                    seal.fulfill(result.results)
                }.catch { (error) in
                    seal.reject(error)
                }
        }
    }
    
    func fetchGenres(_ completion: @escaping (HTTPResult<[Genre]>) -> ()) {
        let request = GenresRequest()
        
        HTTPRequester.default.requestObject(request) { (result: HTTPResult<Genres>) in
            let result = result.map { genresList in genresList.genres }
            completion(result)
        }
        
    }
}
