//
//  ListViewController.swift
//  Weather
//
//  Created by Keval Shetta on 28/07/2023.
//

import UIKit


class ListViewController: UIViewController{
    
    @IBOutlet weak var cityView: UITableView!
    
    var listData: [Dictionary<String,String>] = []
    var tempSelector: String?
    var day:Int = 0
    var conditionString: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cityView.delegate = self
        cityView.dataSource = self
    }
   
    func iconSelector(code:Int, day:Int)->String{
            
        if(day == 1){
            switch code {
            case 1000:
                conditionString = "sun.max.fill"
            case 1003,1006:
                conditionString = "cloud.sun.fill"
            case 1009:
                conditionString = "cloud.fill"
            case 1030:
                conditionString = "cloud.fog.fill"
            case 1063,1180:
                conditionString = "cloud.sun.rain.fill"
            case 1066,1210:
                conditionString = "sun.snow.fill"
            case 1069,1204,1207,1237,1249,1252,1261,1264:
                conditionString = "cloud.sleet.fill"
            case 1072,1150,1153,1168,1171:
                conditionString = "cloud.drizzle.fill"
            case 1087,1273,1276:
                conditionString = "cloud.bolt.rain.fill"
            case 1114:
                conditionString = "wind.snow"
            case 1117,1213,1216,1219,1222,1225,1255,1258,1279,1282:
                conditionString = "cloud.snow.fill"
            case 1135,1147:
                conditionString = "sun.haze.fill"
            case 1183,1186,1189,1192,1198,1201,1240,1243,1246:
                conditionString = "cloud.rain.fill"
            case 1195:
                conditionString = "cloud.heavyrain.fill"
            default:
                conditionString = ""
            }
        }else if(day == 0){
            switch code{
            case 1000:
                conditionString = "moon.fill"
            case 1003,1006:
                conditionString = "cloud.moon.fill"
            case 1009:
                conditionString = "cloud.fill"
            case 1030:
                conditionString = "cloud.fog.fill"
            case 1063,1180:
                conditionString = "cloud.moon.rain.fill"
            case 1066,1210:
                conditionString = "moon.dust.fill"
            case 1069,1204,1207,1237,1249,1252,1261,1264:
                conditionString = "cloud.sleet.fill"
            case 1072,1150,1153,1168,1171:
                conditionString = "cloud.drizzle.fill"
            case 1087,1273,1276:
                conditionString = "cloud.bolt.rain.fill"
            case 1114:
                conditionString = "wind.snow"
            case 1117,1213,1216,1219,1222,1225,1255,1258,1279,1282:
                conditionString = "cloud.snow.fill"
            case 1135,1147:
                conditionString = "moon.haze.fill"
            case 1183,1186,1189,1192,1198,1201,1240,1243,1246:
                conditionString = "cloud.rain.fill"
            case 1195:
                conditionString = "cloud.heavyrain.fill"
            default:
                conditionString = ""
            }
        }
        return conditionString
    }
}

extension ListViewController: UITableViewDelegate{
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

extension ListViewController: UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let cell = tableView.dequeueReusableCell(withIdentifier: "cityContainer") as? CityCell
        cell?.cityLabel.text = listData[indexPath.row]["city"]
        if(tempSelector == "C"){
            cell?.tempLabel.text = "\(listData[indexPath.row]["tempC"] ?? "0") C"
        }else{
            cell?.tempLabel.text = "\(listData[indexPath.row]["tempF"] ?? "0") F"
        }
        let codeNumber = Int(listData[indexPath.row]["code"]!)!
        let day = Int(listData[indexPath.row]["day"]!)!
        let imageDesc: String = iconSelector(code: codeNumber,day: day)
        cell?.conditionImage.image = UIImage(systemName:imageDesc)
        return cell!
    }
}

