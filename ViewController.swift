//
//  ViewController.swift
//  Test
//
//  Created by TCP_CBE_Jr on 14/09/22.
//

import UIKit
import SwiftyJSON

var fromNotification = false

class appointmentviewcell : UITableViewCell {
    
    @IBOutlet weak var mainview: UIView!
    @IBOutlet weak var quoteview: UIView!
    @IBOutlet weak var arrivedview: UIView!
    @IBOutlet weak var carview: UIView!
    @IBOutlet weak var subview: UIView!
    @IBOutlet weak var datelbl: UILabel!
    @IBOutlet weak var timelbl: UILabel!
    @IBOutlet weak var homelbl: UILabel!
    
    @IBOutlet weak var licenselbl: UILabel!
    
    @IBOutlet weak var imgview: UIImageView!
    
}

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var appointmenttableview: UITableView!
    
    
    @IBOutlet weak var addappointmentview: UIView!
    
    var senderDisplayName = "1"
    var appointmentArr = [appointmentModel]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        addappointmentview.layer.cornerRadius = 5
        
        if fromNotification {
            DispatchQueue.main.asyncAfter(deadline: .now()+1.0) {
                self.takeMeToSecondView()
            }
        }
        getList()
        
    }
    
    
    @IBAction func addappointment(_ sender: Any) {
        
        let viewC = (self.storyboard?.instantiateViewController(withIdentifier: "BookAppointmentViewController")) as! BookAppointmentViewController
        self.navigationController?.pushViewController(viewC, animated: true)
    }
    
    
    
    func getList() {
        
        if WebApiCallBack.isConnectedToNetwork() != true {
            showAlert(title: "Alert", message: "Please verify internet connectivity.", VC: ViewController())
            return
        }
//        showOverlay()
        let urlString = Const.BaseUrl+Const.kListOfAppointments
        let CustomerSK = getPrefName(key: "CustomerSK", value: "152289")
        let ShopSK = getPrefName(key: "ShopSK", value: "1908")
        let Status = getPrefName(key: "Status", value: "DLVD")
        let vehicleType = getPrefName(key: "VehicleType", value: "1")
        let parameters = NSMutableDictionary()
        parameters.setObject(CustomerSK, forKey: "CustomerSK" as NSCopying )
        parameters.setObject(Status, forKey: "Status" as NSCopying)
        parameters.setObject(ShopSK, forKey: "ShopSK" as NSCopying)
        parameters.setObject(vehicleType, forKey: "VehicleType" as NSCopying)
        
        print(parameters)
        
        
        WebApiCallBack.requestApi(webUrl: urlString, paramData: parameters, methiod: Const.POST, completionHandler: {(responseObject,error) -> () in
            
            print("responseObject = \(responseObject); error = \(error)")
            
            if responseObject != nil {
                
                let mresponse = JSON(responseObject!)
                
                if let serverMessage = mresponse["ServerMsg"].dictionary, let message = serverMessage["Msg"]?.stringValue, message == "SUCCESS" {
                    
                    if let list = mresponse["VehicleAppointmentList"].array {
                        self.appointmentArr = []
                        for data in list {
                            
                            let object = appointmentModel()
                            
                            object.CustomerVehicleSK = data["CustomerVehicleSK"].stringValue
                            object.VehiclePicture = data["VehiclePicture"].stringValue
                            object.LicencePlateNo = data["LicencePlateNo"].stringValue
                            object.NextServiceDate = data["NextServiceDate"].stringValue
                            
                            object.AppointmentDate = data["AppointmentDate"].stringValue
                            object.AppointmentTime = data["AppointmentTime"].stringValue
                            object.StatusModifierName = data["StatusModifierName"].stringValue
                            
                            
                            if let AppJobEntry = data["AppJobEntry"].array {
                                for val in AppJobEntry{
                                    
                                    let package = packageModel()
                                    package.JobName = val["JobName"].stringValue
                                    package.JobSK = val["JobSK"].stringValue
                                    package.JobType = val["JobType"].stringValue
                                    object.PackagesArr.append(package)
                                }
                            }
                            
                            self.appointmentArr.append(object)
                            
                        }
    
                        DispatchQueue.main.async {
                            self.appointmenttableview.reloadData()
                        }
                    }
                }
            }
        })
    }
    
    @IBAction func btn(_ sender: Any) {
        fromNotification = false
        
        takeMeToSecondView()
    }
    
    func takeMeToSecondView() {
        let viewC = (self.storyboard?.instantiateViewController(withIdentifier: "secondViewController")) as! secondViewController
        self.navigationController?.pushViewController(viewC, animated: true)
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appointmentArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! appointmentviewcell
        print("dfs")
        cell.mainview.layer.cornerRadius = 5
        cell.quoteview.layer.cornerRadius = 5
        cell.arrivedview.layer.cornerRadius = 5
        cell.carview.layer.cornerRadius = 5
        cell.subview.layer.cornerRadius = 5
        cell.imgview.layer.cornerRadius = 5
        
        let data = appointmentArr[indexPath.row]
        
        cell.datelbl.text = data.AppointmentDate
        cell.timelbl.text = data.AppointmentTime
        cell.homelbl.text = data.StatusModifierName
        cell.licenselbl.text = data.LicencePlateNo
        
        return cell
    }
    
    
    
}

extension UIViewController{
    
    
    func showAlert(title:String?,message:String?,VC:UIViewController)
    {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let action = UIAlertAction(title: "OK", style: .default) { (action) in
    }
    alert.addAction(action)
    VC.present(alert, animated: false, completion: nil)
    }
    
    
}



