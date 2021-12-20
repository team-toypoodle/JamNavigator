//
//  RequestViewController.swift
//  JamNavigator
//
//  Created by Tasuku Furuki on 2021/12/16.
//

import UIKit
import MapKit
import CoreLocation

//店の構造体を宣言
struct Address {
    var name: String
    var address: String
}

//店の配列
var addresses = [
    Address(name: "JOYSOUND 名駅三丁目店", address: "愛知県名古屋市中村区名駅3丁目14−6"),
    Address(name: "ジャンカラ 名駅東口店", address: "愛知県名古屋市中村区名駅4丁目10−20"),
    Address(name: "ビッグエコー名駅4丁目店", address: "愛知県名古屋市中村区名駅4丁目5−18")
    
]

class RequestViewController: UIViewController,CLLocationManagerDelegate,MKMapViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet weak var mapView: MKMapView!
    var locationManager: CLLocationManager!
    @IBOutlet weak var dayPicker: UIDatePicker!
    @IBOutlet weak var fromtimePicker: UIDatePicker!
    @IBOutlet weak var totimePicker: UIDatePicker!
    @IBOutlet weak var drumrollPicker: UIPickerView!
    
    var demotape: Demotape? = nil
    let datalist: [String] = ["2","3"]
    
    @IBAction func didTapRequestButton(_ sender: Any) {
        
    }
    //  店の位置をポイントする関数
    func addPin() {
        for i in 0..<addresses.count {
            CLGeocoder().geocodeAddressString(addresses[i].address) { placemarks, error in
                if let coordinate = placemarks?.first?.location?.coordinate {
                    let pin = MKPointAnnotation()
                    pin.title = addresses[i].name
                    pin.coordinate = coordinate
                    self.mapView.addAnnotation(pin)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager!.requestWhenInUseAuthorization()
        
        self.title = demotape?.name ?? "NoName"
        
//        倍率設定
        let span = MKCoordinateSpan(latitudeDelta:0.01,
                                    longitudeDelta: 0.01)
        
        let nagoyaStation = CLLocationCoordinate2DMake(35.170915, 136.8793482)
        
//        初期表示
        let region = MKCoordinateRegion(center: nagoyaStation, span: span)
        mapView.region = region
        
//        ポイントを配置
        addPin()
        
        mapView.delegate = self
        
//        日付取得
        dayPicker.datePickerMode = UIDatePicker.Mode.date
        let daydateFormatter = DateFormatter()
        daydateFormatter.dateFormat = "dd MMMM yyyy"
        let dayselectedDate = daydateFormatter.string(from: dayPicker.date)
        print("--------------------")
        print(dayselectedDate)
        print("--------------------")
        
        //        FromTime取得
        fromtimePicker.datePickerMode = UIDatePicker.Mode.time
        let fromtimeFormatter = DateFormatter()
        fromtimeFormatter.dateFormat = "HH:mm:ss"
        let fromtimeselecte = fromtimeFormatter.string(from: fromtimePicker.date)
        print("------From-------")
        print(fromtimeselecte)
        print("--------------------")
        //        ToTime取得
        totimePicker.datePickerMode = UIDatePicker.Mode.time
        let totimeFormatter = DateFormatter()
        totimeFormatter.dateFormat = "HH:mm:ss"
        let totimeselecte = totimeFormatter.string(from: totimePicker.date)
        print("------To--------")
        print(totimeselecte)
        print("--------------------")
        
        // ピッカー設定
        drumrollPicker.delegate = self
        drumrollPicker.dataSource = self
        
        // デフォルト設定
        drumrollPicker.selectRow(0, inComponent: 0, animated: false)
        
    }


    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            break
        case .authorizedAlways, .authorizedWhenInUse:
            manager .startUpdatingLocation()
            break
        default:
            break
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
//        CLLocationCoordinate2D型で住所を取得
        let lc2d:CLLocationCoordinate2D = view.annotation?.coordinate as Any as! CLLocationCoordinate2D
//        上記変数をCLLocation型に変換
        let l:CLLocation = CLLocation(latitude: lc2d.latitude, longitude: lc2d.longitude)
//        上記変数をlocationに代入
        let location:CLLocation = l
        
//        住所取得：逆ジオコーティング
        CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
            guard let placemark = placemarks?.first, error == nil else { return }
            print(placemark.administrativeArea! + placemark.locality! + placemark.name!)
        }
        
//        名前の取得
        print((view.annotation?.title ?? "no title")! as String)
        
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return datalist.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return datalist[row]
    }
    
}
