//
//  ViewController.swift
//  WikiMedia
//
//  Created by Anshu Vij on 1/23/21.
//

import UIKit
import CoreData

var vSpinner : UIView?
class ViewController: UIViewController {
    
    //MARK: - Properties
    @IBOutlet weak var searchBAr: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var wikiManager = WikiSearchManager()
    var modelData : WikiSearchModel?
    var coreModelData = [WikiSearch]()
    var modelRequiredData = [WikiSearchData]()
    var loadingData = false
    var pageCount = 10
    var searchText : String?
    
    //MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setUpUI()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.barStyle = .default
        navigationController?.navigationBar.prefersLargeTitles = true
        self.title = "Search ME!"
        
        coreModelData = DatabaseController.getAllData()
        modelRequiredData.removeAll()
        if coreModelData.count > 0 {
            loadingData = true
            for data in coreModelData {
                
                modelRequiredData.append(WikiSearchData(title: data.title, url: data.url, imageUrl: data.imageUrl))
                
            }
            
            tableView.reloadData()
            
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        modelRequiredData.removeAll()
    }
    
    //MARK: - Helpers
    func setUpUI(){
        
        wikiManager.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        searchBAr.delegate = self
        tableView.register(UINib(nibName: "CustomCell", bundle: nil), forCellReuseIdentifier: "CustomCell")
        
        // SearchBar text
        let textFieldInsideUISearchBar = searchBAr.value(forKey: "searchField") as? UITextField
        textFieldInsideUISearchBar?.textColor = .darkGray
        textFieldInsideUISearchBar?.font = UIFont(name: "Marker Felt Thin", size: 17.0)
        
        // SearchBar placeholder
        let labelInsideUISearchBar = textFieldInsideUISearchBar!.value(forKey: "placeholderLabel") as? UILabel
        labelInsideUISearchBar?.textColor = .systemGray3
        
        
    }
    
    func addWikiDataToCoreData(title : String, url : String, imageUrl: String ) {
        
        let entity = NSEntityDescription.entity(forEntityName: "WikiSearch", in: DatabaseController.getContext())
        let newEntry = NSManagedObject(entity: entity!, insertInto: DatabaseController.getContext())
        newEntry.setValue(title, forKey: "title")
        newEntry.setValue(url, forKey: "url")
        newEntry.setValue(imageUrl, forKey: "imageUrl")
        
        DatabaseController.saveContext()
        
    }
    
    func showAlert() {
        let alertController = UIAlertController(title: "No Result Found", message: "Please try again!", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (UIAlertAction) in
            UserDefaults.standard.removeObject(forKey: "authVerificationID")
            self.navigationController?.popViewController(animated: true)
        }
        alertController.addAction(okAction)
        self.present(alertController, animated: true)
    }
    
}

//MARK: - UITableViewDelegate
extension ViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if modelRequiredData.count > 0 {
            if modelRequiredData[indexPath.row].imageUrl == nil {
                addWikiDataToCoreData(title: modelRequiredData[indexPath.row].title ?? "", url:  modelRequiredData[indexPath.row].url ?? "", imageUrl: "noImage\(indexPath.row)")
            }
            else
            {
                addWikiDataToCoreData(title: modelRequiredData[indexPath.row].title ?? "", url:  modelRequiredData[indexPath.row].url ?? "", imageUrl:  modelRequiredData[indexPath.row].imageUrl ?? "noImage\(indexPath.row)")
            }
            
            let webVC = WebVC()
            webVC.url = modelRequiredData[indexPath.row].url
            self.navigationController?.pushViewController(webVC, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        cell.transform = CGAffineTransform(scaleX: 1, y: 0)
        
        UIView.animate(withDuration: 0.5, delay: 0.05 * Double(indexPath.row)) {
            cell.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
        
        if !loadingData && indexPath.row == modelRequiredData.count - 1 {
            loadingData = true
            self.showSpinner(onView: self.view)
            self.pageCount += 10
            if let searchText = searchText
            {
            wikiManager.getSearchResult(text: searchText, limit: pageCount)
            }
        }
        
    }
    
    
    
}

//MARK: - UITableViewDataSource
extension ViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return modelRequiredData.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell") as! CustomCell
        cell.labelView.text = modelRequiredData[indexPath.row].title
        
        let imageUrl = modelRequiredData[indexPath.row].imageUrl
        
        if imageUrl == nil || imageUrl?.hasPrefix("noImage") == true
        {
            cell.imageViewImage.image = UIImage(named: "noImage")
            
        }
        else
        {
            cell.imageViewImage.loadImagesUsingUrl(urlString: modelRequiredData[indexPath.row].imageUrl!)
        }
        
        return cell
        
        
    }
    
    
    
    
    
    
    
}

//MARK: - UISearchBarDelegate
extension ViewController : UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        if let text = searchBar.text {
            if text.count > 0 {
                searchText = text
                modelRequiredData.removeAll()
                loadingData = false
                self.showSpinner(onView: self.view)
                wikiManager.getSearchResult(text: text)
                searchBar.text = ""
            }
            
        }
    }
}

//MARK: - WeatherManagerDelegate
extension ViewController : WeatherManagerDelegate {
    func didGetResult(_ WikiSearchManager: WikiSearchManager, _ model: WikiSearchModel) {
        print(model)
        modelData = model
        
        guard let pages = modelData?.query.pages else {return}
        
        if !loadingData
        {
            self.modelRequiredData.removeAll()
        }
        
        for i in 0..<pages.count {
            var imageUrl : String?
            if let imageUrlThum = pages[i].thumbnail
            {
                imageUrl = imageUrlThum.source
            }
            modelRequiredData.append(WikiSearchData(title: pages[i].title, url: pages[i].fullurl,imageUrl : imageUrl))
        }
        self.removeSpinner()
        
        if pages.count > 0 {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        else
        {
            DispatchQueue.main.async {
                self.showAlert()
            }
        }
    }
    
    func didFailWithError(error: Error) {
        self.removeSpinner()
    }
    
    
}
//MARK:- UIViewController

extension UIViewController {
    
    func showSpinner(onView : UIView) {
        let spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let ai = UIActivityIndicatorView.init(style: .large)
        ai.startAnimating()
        ai.center = spinnerView.center
        
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            onView.addSubview(spinnerView)
        }
        
        vSpinner = spinnerView
    }
    
    func removeSpinner() {
        DispatchQueue.main.async {
            vSpinner?.removeFromSuperview()
            vSpinner = nil
        }
    }
}

