//
//  ViewController.swift
//  Example
//
//  Created by Nang Nguyen on 6/25/19.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let demoService = MoviewDBService()
        demoService.fetchGenres { (result) in
            switch result {
            case .success(let value):
                print("Result: \(value)")
            case .failure(let error):
                print("Error: \(error)")
            }
        }
        
        demoService.fetchMovies(page: 1) { (result) in
            switch result {
            case .success(let value):
                print("Result: \(value)")
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }


}

