//
//  FBHelper.swift
//  FacebookAndTwitterShare
//
//  Created by Mohsin on 28/02/2015.
//  Copyright (c) 2015 PanaCloud. All rights reserved.
//

import Foundation

class FBHelper{
    var fbSession:FBSession?
    init(){
        self.fbSession = nil
    }
    
    func fbAlbumRequestHandler(connection:FBRequestConnection!, result:AnyObject!, error:NSError!){
        
        if let gotError = error{
            println(gotError.description)
        }
        else{
            let graphData = result.valueForKey("data") as [FBGraphObject]
            var albums:[AlbumModel] =  [AlbumModel]()
            for obj:FBGraphObject in graphData{
                let desc = obj.description
                println(desc)
                let name = obj.valueForKey("name") as String
               // println(name)
                if(name == "ETC"){
                    let test=""
                }
                let id = obj.valueForKey("id") as String
                var cover = ""
                if let existsCoverPhoto : AnyObject = obj.valueForKey("cover_photo"){
                    let coverLink = existsCoverPhoto  as String
                    cover = "/\(coverLink)/photos"
                }
                
                //println(coverLink)
                let link = "/\(id)/photos"
                
                let model = AlbumModel(name: name, link: link, cover:cover)
                albums.append(model)
                
            }
            NSNotificationCenter.defaultCenter().postNotificationName("albumNotification", object: nil, userInfo: ["data":albums])
        }
    }
    
    func fetchPhoto(link:String){
        let fbRequest = FBRequest.requestForMe()
        fbRequest.graphPath = link
        fbRequest.startWithCompletionHandler(fetchPhotosHandler)
    }
    
    func fetchPhotosHandler(connection:FBRequestConnection!, result:AnyObject!, error:NSError!){
        if let gotError = error{
            
        }
        else{
            var pictures:[UIImage] = [UIImage]()
            var picturesUrl:[NSString] = [NSString]()

            let graphData = result.valueForKey("data") as [FBGraphObject]
            var albums:[AlbumModel] =  [AlbumModel]()
            for obj:FBGraphObject in graphData{
                println(obj.description)
                let pictureURL = obj.valueForKey("picture") as String
                let url = NSURL(string: pictureURL)
                
                picturesUrl.append(obj["source"] as String)
                
                let picData = NSData(contentsOfURL: url)
                let img = UIImage(data: picData)
                pictures.append(img)
            }
            
            NSNotificationCenter.defaultCenter().postNotificationName("photoNotification", object: nil, userInfo: ["photos":pictures, "photosUrl": picturesUrl])
        }
    }
    
    func fetchAlbum(){
        
        let request =  FBRequest.requestForMe()
        request.graphPath = "me/albums"
        
        request.startWithCompletionHandler(fbAlbumRequestHandler)
        
       // request.startWithCompletionHandler({_ in println("dsa")})
    }
    
    func logout(){
        self.fbSession?.closeAndClearTokenInformation()
        self.fbSession?.close()
    }
    
    func login(){
        
        
        let activeSession = FBSession.activeSession()
        let fbsessionState = activeSession.state
        if(fbsessionState.hashValue != FBSessionState.Open.hashValue && fbsessionState.hashValue != FBSessionState.OpenTokenExtended.hashValue){
            
            let permission = ["basic_info", "email","user_photos","friends_photos"]
            
            FBSession.openActiveSessionWithPublishPermissions(permission, defaultAudience: FBSessionDefaultAudience.Friends, allowLoginUI: true, completionHandler: self.fbHandler)
            
        }
    }
    
    func fbHandler(session:FBSession!, state:FBSessionState, error:NSError!){
        if let gotError = error{
            //got error
        }
        else{
            
            self.fbSession = session
            
            FBRequest.requestForMe()?.startWithCompletionHandler(self.fbRequestCompletionHandler)
        }
    }
    
    func fbRequestCompletionHandler(connection:FBRequestConnection!, result:AnyObject!, error:NSError!){
        if let gotError = error{
            //got error
        }
        else{
            //let resultDict = result as Dictionary
            //let email = result["email"]
            //let firstName = result["first_name"]
            
           // let email : AnyObject = result.valueForKey("email")
            let email = "temp@temo.com"
            let firstName:AnyObject = result.valueForKey("first_name")
            let userFBID:AnyObject = result.valueForKey("id")
            let userImageURL = "https://graph.facebook.com/\(userFBID)/picture?type=small"
            
            let url = NSURL.URLWithString(userImageURL)
            
            let imageData = NSData(contentsOfURL: url)
            
            let image = UIImage(data: imageData)
            
            println("userFBID: \(userFBID) Email \(email) \n firstName:\(firstName) \n image: \(image)")
            
            var userModel = User(email: email, name: firstName, image: image)
            
            NSNotificationCenter.defaultCenter().postNotificationName("PostData", object: userModel, userInfo: nil)
            
        }
    }
}