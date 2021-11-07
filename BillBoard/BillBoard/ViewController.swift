//
//  ViewController.swift
//  BillBoard
//
//  Created by Abhilash on 31/01/17.
//  Copyright © 2017 Abhilash. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let dateformater :DateFormatter = DateFormatter()
        dateformater.dateFormat = "yyyy-MM-dd"
        let date : Date = dateformater.date(from:"2016-10-15")!
        self.startServiceCall(date:date);
        // Do any additional setup after loading the view, typically from a nib.

    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func startServiceCall(date:Date) -> Void {
        let session = URLSession.shared
        
        let dateformater :DateFormatter = DateFormatter()
        dateformater.dateFormat = "yyyy-MM-dd"
        let dateString : String = dateformater.string(from: date)
        let todoEndpoint: String = NSString.init(format: "http://billboard.modulo.site/charts/%@?filter=song", dateString) as String;
        guard let url = URL(string: todoEndpoint) else {
            print("Error: cannot create URL")
            return
        }
        let urlRequest = URLRequest(url: url)
        let task = session.dataTask(with: urlRequest) {
            (data, response, error) in
            // check for any errors
            guard error == nil else {
                print("error calling GET on /todos/1")
                print(error)
                return
            }
            // make sure we got data
            guard let responseData = data else {
                print("Error: did not receive data")
                return
            }
            // parse the result as JSON, since that's what the API provides
            do {
                guard let todo = try JSONSerialization.jsonObject(with: responseData, options: []) as? [Dictionary<String, Any>] else {
                    print("error trying to convert data to JSON")
                    return
                }
                // now we have the todo, let's just print it to prove we can access it
                //print("The todo is: " + todo.description)
                
                // the todo object is a dictionary
                // so we just access the title using the "title" key
                // so check for a title and print it if we have one
//                guard let todoTitle = todo["title"] as? String else
//                    print("Could not get todo title from JSON")
//                    return
//                }
                var count : Int = 0;
                let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
                let path : String?  = paths.appendingPathComponent("Songs.plist")
                let fileManager = FileManager.default
                
                if (!(fileManager.fileExists(atPath: path!)))
                {
                    let bundle : String = Bundle.main.path(forResource: "Songs", ofType: "plist")!
                    try fileManager.copyItem(atPath: bundle as String, toPath: path!)
                }
                 let data : NSMutableDictionary = NSMutableDictionary.init(contentsOfFile: path!)!
                var rank = [String]()
                var songnames = [String]()
                var songids = [String]()
                var disArtists = [String]()
                var sptids = [String]()
                var artsids = [String]()
                
                for dictionary in todo
                {
                    //print("Count");
                    
                    rank.append(dictionary["rank"] as? String ?? "");
                    songnames.append(dictionary["song_name"] as? String ?? "");
                    songids.append(dictionary["song_id"] as? String ?? "");
                    disArtists.append(dictionary["display_artist"] as? String ?? "");
                    sptids.append(dictionary["spotify_id"] as? String ?? "");
                    artsids.append(dictionary["artist_id"] as? String ?? "");
//                    dict["SongName"] = dictionary["sont_name"];
//                    dict["songID"] = dictionary["song_id"];
//                    dict["DisArtist"] = dictionary["display_artist"];
//                    dict["sptID"] = dictionary["spotify_id"];
//                    dict["ArtistID"] = dictionary["artist_id"];
//                    dict.setValue(dictionary["rank"], forKey: "Rank")
//                    dict.setValue(dictionary["sont_name"], forKey: "SongName")
//                    dict.setValue(dictionary["song_id"], forKey: "songID")
//                    dict.setValue(dictionary["display_artist"], forKey: "DisArtist")
//                    dict.setValue(dictionary["spotify_id"], forKey: "sptID")
//                    dict.setValue(dictionary["artist_id"], forKey: "ArtistID")
                    
                
                    count = count+1;
                }
                var dict = [String : Any]()
                dict["ranks"] = rank
                dict["songNames"] = songnames
                dict["songIDs"] = songids
                dict["displayArtists"] = disArtists
                dict["spotifyIDs"] = sptids
                dict["artistIDs"] = artsids
                
                data.setObject(dict, forKey:String.init(format: "%@",dateString as! CVarArg) as NSCopying)
                data.write(toFile:path!, atomically: true)
               
                let prevDate: Date = dateformater.date(from: dateString)!
                var dateComp : DateComponents = DateComponents.init()
                dateComp.day = -7;
                let NextDate : Date = NSCalendar.current.date(byAdding: dateComp, to: prevDate)!
                if NextDate != dateformater.date(from: "1958-08-09")
                {
                     self.startServiceCall(date: NextDate)
                }
                else{
                    print("done")
                }
            } catch  {
                print("error trying to convert data to JSON")
                return
            }
            
        }
        task.resume()    }


}

