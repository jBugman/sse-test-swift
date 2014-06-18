//
//  ViewController.swift
//  EcoClient
//
//  Created by Sergey Parshukov on 18.06.14.
//  Copyright (c) 2014 bugman. All rights reserved.
//

import UIKit


let baseURL = "http://spmbp.local:8080"
let postURL = baseURL + "/api/post"
let eventsURL = baseURL + "/api/events"

let clientColor = "#000000"


class APIClient {
    
    let manager = AFHTTPRequestOperationManager()
    let eventSource = TRVSEventSource(URL: NSURL(string: eventsURL))
    
    let delegate: MessageLogger?
    
    init(delegate: MessageLogger) {
        self.delegate = delegate
        
        println("API init")
        
        eventSource.addListenerForEvent("message", usingEventHandler: { (event: TRVSServerSentEvent!, error: NSError!) in
            println(event)
            let text = self.textFromEvent(event.data)
            self.delegate?.logMessage(text)
        })
        eventSource.open()
    }
    
    func textFromEvent(eventData: NSData) -> String {
        let eventObject = self.eventObjectFromData(eventData)
        return eventObject["text"] as String
    }

    func eventObjectFromData(data: NSData) -> NSDictionary {
        return NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as NSDictionary
    }
    
    func post(text: String) {
        manager.requestSerializer = AFJSONRequestSerializer()
        let data = [
            "color": clientColor,
            "text": text
        ]
        manager.POST(
            postURL,
            parameters: data,
            success: { (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) in
                println("JSON: " + responseObject.description)
            },
            failure: { (operation: AFHTTPRequestOperation!, error: NSError!) in
                println("Error: " + error.localizedDescription)
            }
        )
    }
}


protocol MessageLogger {
    func logMessage(text: String)
}


class ViewController: UIViewController, MessageLogger {
    
    @IBOutlet var messageInput : UITextField
    @IBOutlet var messageLog : UITextView
    
    var messages : String[] = []
    
    let client: APIClient?
    
    @IBAction func send() {
        println("send")
        
        let newMessage = messageInput.text
        
        client?.post(newMessage)
        
        messageInput.text = ""
    }
    
    func logMessage(text: String) {
        messages += text
        messageLog.text = messagesText
    }
    
    var messagesText: String {
        get{
            return "\n".join(messages.reverse())
        }
    }
    
    init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
        
        self.client = APIClient(delegate: self)
    }

}
