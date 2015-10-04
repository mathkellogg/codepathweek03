//
//  ViewController.swift
//  Twitter
//
//  Created by Mathew Kellogg on 10/3/15.
//  Copyright © 2015 Mathew Kellogg. All rights reserved.
//

import UIKit


class ViewController: UIViewController {


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onLogin(sender: AnyObject) {
        
        TwitterClient.sharedInstance.loginWithCompletion(){
            (user: User?, error: NSError?) in
            if user != nil {
                //perform segue
                self.performSegueWithIdentifier("loginSegue", sender: self)
                
            } else {
                //handle error
                print("error: \(error)")
            }
        }
        

    }
}

