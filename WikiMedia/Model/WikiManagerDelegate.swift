//
//  WikiManagerDelegate.swift
//  WikiMedia
//
//  Created by Anshu Vij on 1/23/21.
//

import Foundation

protocol WeatherManagerDelegate {
    func didGetResult(_ WikiSearchManager : WikiSearchManager, _ model: WikiSearchModel)
    func didFailWithError(error : Error)
}
