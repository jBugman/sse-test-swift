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
    let eventSource = EventSource(URL: NSURL(string: eventsURL))
    
    let delegate: MessageLogger?
    
    init(delegate: MessageLogger) {
        self.delegate = delegate
        
        println("API init")
        
        eventSource.addEventListener("message", handler: { (event: Event!) in
            println(event)
            let text = self.textFromEvent(event.data)
            self.delegate?.logMessage(text)
        })
    }
    
    func textFromEvent(eventText: String) -> String {
        let jsonData = eventText.dataUsingEncoding(NSUTF8StringEncoding)
        let eventData = NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.MutableContainers, error: nil) as NSDictionary
        return eventData["text"] as String
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
