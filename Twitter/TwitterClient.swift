//
//  TwitterCleint.swift
//  Twitter
//
//  Created by Mathew Kellogg on 10/3/15.
//  Copyright © 2015 Mathew Kellogg. All rights reserved.
//

import UIKit

let twitterConsumerKey = "amYhAyOupzSnZaHyPtiYRFLob"
let twitterConsumerSecret = "IePv30ACWL31sGTJkNv1n03XgqhhiOKbUyXNotF74YUWTWfcB9"
let twitterBaseURL = NSURL(string: "https://api.twitter.com")

class TwitterClient: BDBOAuth1RequestOperationManager {
    
    var loginCompletion: ((user: User?, error: NSError?) -> ())?
    
    class var sharedInstance: TwitterClient{
        struct Static {
            static let instance = TwitterClient(baseURL: twitterBaseURL, consumerKey: twitterConsumerKey, consumerSecret: twitterConsumerSecret)

        }
        return Static.instance
    }
    
    func homeTimelineWithCompletion(params: NSDictionary?, completion: (tweets: [Tweet]?, error: NSError?) -> ()) {
        
        TwitterClient.sharedInstance.GET("1.1/statuses/home_timeline.json", parameters: nil, success: {
            (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
            let tweets = Tweet.tweetsWitArray(response as! [NSDictionary])
            completion(tweets: tweets, error: nil)
        }, failure: {
            (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
            completion(tweets: nil, error: error)
        })
        
    }
    
    func loginWithCompletion (completion: (user: User?, error: NSError?) -> ()) {
        loginCompletion = completion
        
        // fetch request token and redirect to authorization page
        TwitterClient.sharedInstance.requestSerializer.removeAccessToken()
        TwitterClient.sharedInstance.fetchRequestTokenWithPath("oauth/request_token", method: "GET", callbackURL: NSURL(string:"cptwitterdemo://oauth"), scope: nil, success: {
            (requestToken: BDBOAuth1Credential!) -> Void in
            print(requestToken)
            let authURL = NSURL(string:"https://api.twitter.com/oauth/authorize?oauth_token=\(requestToken.token)")
            UIApplication.sharedApplication().openURL(authURL!)
        }, failure: {
                (error: NSError!) -> Void in
                self.loginCompletion?(user: nil, error: error)
        })
    }
    
    
    func tweet(text: String, completion: (tweet: Tweet?, error: NSError?) -> ()) {
        
        let params = ["status":text]

        POST("1.1/statuses/update.json", parameters: params, success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
            let tweet = Tweet(dictionary: response as! NSDictionary)
            completion(tweet: tweet, error: nil)
            }) { (operation: AFHTTPRequestOperation!, error:NSError!) -> Void in
                completion(tweet: nil, error: error)
        }
    }
    
    func reply(text: String, tweetId: Int, completion: (tweet: Tweet?, error: NSError?) -> ()) {
        
        let params = ["status":text, "in_reply_to_status_id": "\(tweetId)"]
        
        POST("1.1/statuses/update.json", parameters: params, success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
            let tweet = Tweet(dictionary: response as! NSDictionary)
            completion(tweet: tweet, error: nil)
            }) { (operation: AFHTTPRequestOperation!, error:NSError!) -> Void in
                completion(tweet: nil, error: error)
        }
    }
    
    func retweet(text: String, tweetId: Int, completion: (tweet: Tweet?, error: NSError?) -> ()) {
        
        let params = ["status":text]

        
        POST("1.1/statuses/retweet/\(tweetId).json", parameters: params, success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
            let tweet = Tweet(dictionary: response as! NSDictionary)
            completion(tweet: tweet, error: nil)
            }) { (operation: AFHTTPRequestOperation!, error:NSError!) -> Void in
                completion(tweet: nil, error: error)
        }
    }
    
    func deleteTweet(tweetId: Int, completion: (tweet: Tweet?, error: NSError?) -> ()) {
        
        POST("1.1/statuses/destroy/\(tweetId).json", parameters: ["":""], success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
            let tweet = Tweet(dictionary: response as! NSDictionary)
            completion(tweet: tweet, error: nil)
            }) { (operation: AFHTTPRequestOperation!, error:NSError!) -> Void in
                completion(tweet: nil, error: error)
        }
    }
    
    func favorite(tweetId: Int, completion: (tweet: Tweet?, error: NSError?) -> ()) {
        
        let params = ["id":"\(tweetId)"]

        POST("1.1/favorites/create.json", parameters: params, success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
            let tweet = Tweet(dictionary: response as! NSDictionary)
            completion(tweet: tweet, error: nil)
            }) { (operation: AFHTTPRequestOperation!, error:NSError!) -> Void in
                completion(tweet: nil, error: error)
        }
    }
    
    func unfavorite(tweetId: Int, completion: (tweet: Tweet?, error: NSError?) -> ()) {
        
        let params = ["id":"\(tweetId)"]
        
        POST("1.1/favorites/destroy.json", parameters: params, success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
            let tweet = Tweet(dictionary: response as! NSDictionary)
            completion(tweet: tweet, error: nil)
            }) { (operation: AFHTTPRequestOperation!, error:NSError!) -> Void in
                completion(tweet: nil, error: error)
        }
    }

    func openURL(url: NSURL){
        
        fetchAccessTokenWithPath("oauth/access_token", method: "POST", requestToken: BDBOAuth1Credential(queryString: url.query)!, success: {
            (accessToken: BDBOAuth1Credential!) -> Void in
            print ("got access token \(accessToken)")
            TwitterClient.sharedInstance.requestSerializer.saveAccessToken(accessToken)
            
            TwitterClient.sharedInstance.GET("1.1/account/verify_credentials.json", parameters: nil, success: {
                (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
                let user = User(dictionary: response as! NSDictionary)
                User.currentUser = user
                self.loginCompletion?(user: user, error: nil)
                }, failure: {
                    (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                    self.loginCompletion?(user: nil, error: error)
            })

            }) { (error:NSError!) -> Void in
                self.loginCompletion?(user: nil, error: error)
        }
    }
}
