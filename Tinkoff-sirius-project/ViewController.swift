//
//  ViewController.swift
//  Tinkoff-sirius-project
//
//  Created by Эльмира Байгулова on 09.02.2022.
//

import UIKit

class ViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    // MARK: -IBOutlets
    @IBOutlet weak var firstView: UIView!
    @IBOutlet weak var companyNameLabel: UILabel!
    @IBOutlet weak var companyPickerView: UIPickerView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var companySymbolLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var priceChangeLabel: UILabel!
    @IBOutlet weak var priceChangeImageView: UIImageView!
    @IBOutlet weak var companyIconImageView: UIImageView!
    @IBOutlet weak var infoView: UIView!
    
    // MARK: - private properties
    
    private let companies: [String: String] = ["Apple": "AAPL",
                                               "Microsoft": "MSFT",
                                               "Google": "GOOG",
                                               "Amazon": "AMZN",
                                               "Facebook": "FB"]
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.companyPickerView.dataSource = self
        self.companyPickerView.delegate = self
        
        self.activityIndicator.hidesWhenStopped = true
        
        self.requestQuoteUpdate()
   
    }
    
    // MARK: - Private methods
    
    private func requestQuote(for symbol: String) {
        let url = URL(string: "https://cloud.iexapis.com/stable/stock/\(symbol)/quote?&token=pk_75e1844d42ae43a1afd85142da2860d5")!
        
        let dataTask = URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                error == nil,
                (response as? HTTPURLResponse)?.statusCode == 200,
                let data = data
            else {
                DispatchQueue.main.async {
                self.showAlert(title: "Network error", message: "Please check your internet connection")
//                print("Network error")
                }
                return
            }
            self.parseQuote(data: data)
        }
        
        dataTask.resume()
    }
    
    private func requestImage(for symbol: String) {

        let imageUrl = URL(string: "https://storage.googleapis.com/iexcloud-hl37opg/api/logos/\(symbol).png")!
        
        let dataTask = URLSession.shared.dataTask(with: imageUrl) { data, response, error in
            guard
                error == nil,
                (response as? HTTPURLResponse)?.statusCode == 200,
                let data = data
            else {
                DispatchQueue.main.async {
                self.showAlert(title: "Network error", message: "Please check your internet connection")
//                print("Network error")
                }
                return
            }
        
            DispatchQueue.main.async {
                self.companyIconImageView.image = UIImage(data: data)
            }
        }
        dataTask.resume()
    }
    
    private func showAlert(title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: { _ in
            alert.dismiss(animated: true)
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func requestQuoteUpdate() {
        self.activityIndicator.startAnimating()
        self.companyNameLabel.text = "-"
        self.companySymbolLabel.text = "-"
        self.priceLabel.text = "-"
        self.priceChangeLabel.text = "-"
//        self.priceChangeLabel.textColor = UIColor.black
        
        let selectedRow = self.companyPickerView.selectedRow(inComponent: 0)
        let selectedSymbol = Array(self.companies.values)[selectedRow]
        self.requestQuote(for: selectedSymbol)
    }
    
    private func parseQuote(data: Data) {
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data)
            
            guard
                let json = jsonObject as? [String: Any],
                let companyName = json["companyName"] as? String,
                let companySymbol = json["symbol"] as? String,
                let price = json["latestPrice"] as? Double,
                let priceChange = json["change"] as? Double
            else {
                DispatchQueue.main.async {
                self.showAlert(title: "Error", message: "Invalid JSON format")
//                print("Invalid JSON format")
                }
                return
            }
            self.requestImage(for: companySymbol)
            DispatchQueue.main.async {
                self.displayStockInfo(companyName: companyName,
                                      symbol: companySymbol,
                                      price: price,
                                      priceChange: priceChange)
            }
        } catch {
            print("JSON parsing error: " + error.localizedDescription)
        }
    }
    
    private func displayStockInfo(companyName: String, symbol: String, price: Double, priceChange: Double) {
        self.activityIndicator.stopAnimating()
        self.companyNameLabel.text = companyName
        self.companySymbolLabel.text = symbol
        self.priceLabel.text = "\(price)"
        self.priceChangeLabel.text = "\(priceChange)"
        if (priceChange > 0) {
//            self.priceChangeLabel.textColor = UIColor.green
            self.priceChangeImageView.image = UIImage(systemName: "arrow.up")
            self.priceChangeImageView.tintColor = UIColor.green
        } else {
//            self.priceChangeLabel.textColor = UIColor.red
            self.priceChangeImageView.image = UIImage(systemName: "arrow.down")
            self.priceChangeImageView.tintColor = UIColor.red
        }
    }
    
    // MARK: - UIPickerViewDataSource
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.companies.keys.count
    }
    
    // MARK: - UIPickerViewDelegate
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Array(self.companies.keys)[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.activityIndicator.startAnimating()
        
        let selctedSymbol = Array(self.companies.values)[row]
        self.requestQuote(for: selctedSymbol)
    }
}

