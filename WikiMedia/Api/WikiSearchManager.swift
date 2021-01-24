//
//  WikiSearchManager.swift
//  WikiMedia
//
//  Created by Anshu Vij on 1/23/21.
//

import Foundation

struct WikiSearchManager {
    
    var delegate : WeatherManagerDelegate?
    
    func getSearchResult(text : String, limit : Int = 10) {
        
        let urlString = "https://en.wikipedia.org/w/api.php?action=query&format=json&prop=pageimages%7Cpageterms%7Cinfo&inprop=url&continue=gpsoffset%7C%7C&generator=prefixsearch&redirects=1&formatversion=2&piprop=thumbnail&pithumbsize=50&pilimit=10&wbptterms=description&gpssearch=\(text)&gpslimit=\(limit)&gpsoffset=10"
        performRequest(urlString: urlString)
    }
    
    func performRequest(urlString : String) {
        
       
        
        if let url  = URL(string: urlString){
            let session = URLSession(configuration: .default)
            
            let task = session.dataTask(with: url) { (data, response, error) in
                
                
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                
                if let safeData = data
                {
                    if let model = self.parseJSON(safeData) {
                        self.delegate?.didGetResult(self, model)
                    }
                }
            }
            
            task.resume()
        }
    }
    
    func parseJSON( _ searchModel : Data) -> WikiSearchModel?
   {
       var modelValue = WikiSearchModel(query:Query(pages: []))
       let decoder = JSONDecoder()
           do {
               let decodeData : WikiSearchModel = try decoder.decode(WikiSearchModel.self, from: searchModel)
            modelValue = decodeData
           }
      
       
        catch DecodingError.dataCorrupted(let context) {
            print(context)
        } catch DecodingError.keyNotFound(let key, let context) {
            print("Key '\(key)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch DecodingError.valueNotFound(let value, let context) {
            print("Value '\(value)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch DecodingError.typeMismatch(let type, let context) {
            print("Type '\(type)' mismatch:", context.debugDescription)
            print("codingPath:", context.codingPath)
        }
        catch {
        self.delegate?.didFailWithError(error: error)
        
       }

       return modelValue
   }
    
}
