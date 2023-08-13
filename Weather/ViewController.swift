//
//  ViewController.swift
//  Weather
//
//  Created by Keval Shetta on 19/07/2023.
//

import UIKit
import CoreLocation


class ViewController: UIViewController, CLLocationManagerDelegate, UITextFieldDelegate {

    @IBOutlet weak var image: UIImageView!

    @IBOutlet weak var tempLabel: UILabel!
    
    @IBOutlet weak var location: UILabel!
    
    @IBOutlet weak var conditionLabel: UILabel!
    
    @IBOutlet weak var tempSelector: UISegmentedControl!
    
    @IBOutlet weak var searchText: UITextField!
    
    @IBOutlet weak var wallpaperImageView: UIImageView!
    
    @IBOutlet weak var cityBtn: UIButton!
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    let locationManager = CLLocationManager()
    var currentLocation : CLLocation?
    var myLocation:String = ""
    var celcius:Double = 0
    var farenhit:Double = 0
    var day:Int = 0
    var conditionCode = 0
    var cityList: [Dictionary<String,String>] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        setNeedsStatusBarAppearanceUpdate()
        location.text = ""
        tempLabel.text = ""
        conditionLabel.text = ""
        searchText.delegate = self
        tempSelector.isHidden = true
        cityBtn.isHidden = true
    }
    
    func getCurrentTime(){
        if(day==1){
            wallpaperImageView.image = UIImage(named: "day")
        }else if(day==0){
            wallpaperImageView.image = UIImage(named: "night")
            location.textColor = UIColor.white
            tempLabel.textColor = UIColor.white
            conditionLabel.textColor = UIColor.white
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        if (searchText.text != nil) {
            let myLoc = searchText.text!.trimmingCharacters(in: .whitespaces).replacingOccurrences(of: " ", with: "%20")
            getWeather(Loc: myLoc)
            searchText.text = ""
        }
        return true
    }
    
    
    func setupLocation(){
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if !locations.isEmpty, currentLocation == nil {
            currentLocation = locations.last
            if let curLocation = currentLocation {
                let lat = curLocation.coordinate.latitude
                let long = curLocation.coordinate.longitude
                myLocation = "\(lat),\(long)"
                getWeather(Loc: myLocation)
            }
            locationManager.stopUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    
    func getUrl(Location:String)->URL?{
        let baseUrl = "https://api.weatherapi.com/v1/"
        let endPoint = "current.json"
        let apiKey = "3b4bf688673b4f32bff235820231907"
        let search = Location
        
        let url = "\(baseUrl)\(endPoint)?key=\(apiKey)&q=\(search)"
        return URL(string: url)
    }
    

    @IBAction func getLocation(_ sender: UIButton) {
        setupLocation()
        getWeather(Loc: myLocation)
    }
    
    
    @IBAction func getLocationBySearch(_ sender: UIButton) {
        if (searchText.text != nil) {
            let myLoc = searchText.text!.trimmingCharacters(in: .whitespaces).replacingOccurrences(of: " ", with: "%20")
            getWeather(Loc: myLoc)
            searchText.text = ""
        }
    }
    
    func getWeather(Loc:String){
        let url = getUrl(Location: Loc)
        
        guard let url = url else{
            print("error in url")
            location.text = "Error while getting location"
            return
        }
        
        let urlSession = URLSession.shared
        let dataTask = urlSession.dataTask(with: url) { data, response, error in
            
            guard let data = data else{
                print("No data")
                self.location.text = "No data available!!"
                return
            }
            
            if let data = self.parseJson(data: data){
                
                DispatchQueue.main.async {
                    let myLocation = data.location.name
                    self.location.text = myLocation
                    self.celcius = data.current.temp_c
                    self.farenhit = data.current.temp_f
                    self.tempLabel.text = String(data.current.temp_c)
                    self.conditionLabel.text = data.current.condition.text
                    self.day = data.current.is_day
                    self.getCurrentTime()
                    self.conditionCode = data.current.condition.code
                    self.iconSelector(code: self.conditionCode)
                    self.tempSelector.isHidden = false
                    if(self.day == 0){
                        self.cityBtn.tintColor = UIColor.blue
                    }else if(self.day == 1){
                        self.cityBtn.tintColor = UIColor.red
                    }
                    self.cityBtn.isHidden = false
                    self.cityList.append(["city": myLocation, "tempC": String(self.celcius), "tempF": String(self.farenhit), "code": String(self.conditionCode), "day":String(self.day)])
                }
            }
        }
        
        dataTask.resume()
    }
    
    @IBAction func tempSelector(_ sender: UISegmentedControl) {
        if (tempSelector.selectedSegmentIndex == 0){
            tempLabel.text = String(celcius)
        }else {
            tempLabel.text = String(farenhit)
        }
    }
    
    func parseJson(data:Data)-> Weather?{
        let decoder = JSONDecoder()
        var weatherResponse:Weather?
        
        do{
            weatherResponse = try decoder.decode(Weather.self, from: data)
        }catch{
            print(error)
        }
        return weatherResponse
    }
    
    func iconSelector(code:Int){
        
        switch code{
        case 1000:
            if(day == 1){
                let config = UIImage.SymbolConfiguration(paletteColors: [.orange])
                image.preferredSymbolConfiguration = config
                image.image = UIImage(systemName: "sun.max.fill")
            }else if(day == 0){
                let config = UIImage.SymbolConfiguration(paletteColors: [.white])
                image.preferredSymbolConfiguration = config
                image.image = UIImage(systemName: "moon.fill")
            }
        case 1003,1006:
            if(day == 1){
                let config = UIImage.SymbolConfiguration(paletteColors: [.orange,.white])
                image.preferredSymbolConfiguration = config
                image.image = UIImage(systemName:  "cloud.sun.fill")
            }else if(day == 0){
                let config = UIImage.SymbolConfiguration(paletteColors: [.white,.blue])
                image.preferredSymbolConfiguration = config
                image.image = UIImage(systemName:  "cloud.moon.fill")
            }
        case 1009:
            let config = UIImage.SymbolConfiguration(paletteColors: [.white])
            image.preferredSymbolConfiguration = config
            image.image = UIImage(systemName:  "cloud.fill")
        case 1030:
            let config = UIImage.SymbolConfiguration(paletteColors: [.white])
            image.preferredSymbolConfiguration = config
            image.image = UIImage(systemName:  "cloud.fog.fill")
        case 1063,1180:
            if(day == 1){
                let config = UIImage.SymbolConfiguration(paletteColors: [.white,.orange,.blue])
                image.preferredSymbolConfiguration = config
                image.image = UIImage(systemName:  "cloud.sun.rain.fill")
            }else if(day == 0){
                let config = UIImage.SymbolConfiguration(paletteColors: [.white,.blue])
                image.preferredSymbolConfiguration = config
                image.image = UIImage(systemName:  "cloud.moon.rain.fill")
            }
        case 1066,1210:
            if(day == 1){
                let config = UIImage.SymbolConfiguration(paletteColors: [.white,.orange])
                image.preferredSymbolConfiguration = config
                image.image = UIImage(systemName:  "sun.snow.fill")
            }else if(day == 0){
                let config = UIImage.SymbolConfiguration(paletteColors: [.white,.blue])
                image.preferredSymbolConfiguration = config
                image.image = UIImage(systemName:  "moon.dust.fill")
            }
        case 1069,1204,1207,1237,1249,1252,1261,1264:
            let config = UIImage.SymbolConfiguration(paletteColors: [.white])
            image.preferredSymbolConfiguration = config
            image.image = UIImage(systemName:  "cloud.sleet.fill")
        case 1072,1150,1153,1168,1171:
            let config = UIImage.SymbolConfiguration(paletteColors: [.white,.blue])
            image.preferredSymbolConfiguration = config
            image.image = UIImage(systemName:  "cloud.drizzle.fill")
        case 1087,1273,1276:
            let config = UIImage.SymbolConfiguration(paletteColors: [.white,.blue])
            image.preferredSymbolConfiguration = config
            image.image = UIImage(systemName:  "cloud.bolt.rain.fill")
        case 1114:
            let config = UIImage.SymbolConfiguration(paletteColors: [.white])
            image.preferredSymbolConfiguration = config
            image.image = UIImage(systemName:  "wind.snow")
        case 1117,1213,1216,1219,1222,1225,1255,1258,1279,1282:
            let config = UIImage.SymbolConfiguration(paletteColors: [.white])
            image.preferredSymbolConfiguration = config
            image.image = UIImage(systemName:  "cloud.snow.fill")
        case 1135,1147:
            if(day == 1){
                let config = UIImage.SymbolConfiguration(paletteColors: [.white,.orange])
                image.preferredSymbolConfiguration = config
                image.image = UIImage(systemName:  "sun.haze.fill")
            }else if(day == 0){
                let config = UIImage.SymbolConfiguration(paletteColors: [.white,.blue])
                image.preferredSymbolConfiguration = config
                image.image = UIImage(systemName:  "moon.haze.fill")
            }
        case 1183,1186,1189,1192,1198,1201,1240,1243,1246:
            let config = UIImage.SymbolConfiguration(paletteColors: [.white,.blue])
            image.preferredSymbolConfiguration = config
            image.image = UIImage(systemName:  "cloud.rain.fill")
        case 1195:
            let config = UIImage.SymbolConfiguration(paletteColors: [.white,.blue])
            image.preferredSymbolConfiguration = config
            image.image = UIImage(systemName:  "cloud.heavyrain.fill")
        default:
            image.image = UIImage(systemName:  "sun.max.fill")
        }
    }
    
    struct Weather:Decodable{
        let location:Location
        let current:Current
    }
    
    struct Location: Decodable{
        let name:String
    }
    
    struct Current: Decodable{
        let temp_c:Double
        let temp_f:Double
        let is_day:Int
        let condition:Condition
    }
    
    struct Condition: Decodable{
        let text:String
        let code:Int
    }
    
    @IBAction func cityBtn(_ sender: UIButton) {
        performSegue(withIdentifier: "goToCityList", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "goToCityList"){
            let destination = segue.destination as! ListViewController
            destination.listData = cityList
            if (tempSelector.selectedSegmentIndex == 0){
                destination.tempSelector = "C"
            }else {
                destination.tempSelector = "F"
            }
        }
    }
}
