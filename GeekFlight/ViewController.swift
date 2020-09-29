//
//  ViewController.swift
//  GeekFlight
//
//  Created by Maksim Romanov on 28.09.2020.
//  Copyright © 2020 Maksim Romanov. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        NetworkService.getLocation(icao24: "4245a7")
    }


}

