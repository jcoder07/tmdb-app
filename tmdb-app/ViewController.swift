//
//  ViewController.swift
//  tmdb-app
//
//  Created by Juan Fernandez on 05-01-26.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let movieResponse: MovieResponse = loadJSON(filename: "movies", type: MovieResponse.self)
        
        let favoriteMoviesResponse: FavoriteMoviesResponse = loadJSON(filename: "favorite-movies", type: FavoriteMoviesResponse.self)
        
        let decodableStressTest: DecodableStressTest = loadJSON(filename: "decodable_stress_test", type: DecodableStressTest.self)

        print(movieResponse.results)
        print(favoriteMoviesResponse.results)
        print(decodableStressTest.users)
    }


}

