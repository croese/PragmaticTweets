//
//  ViewController.swift
//  PragmaticTweets
//
//  Created by Christian Roese on 7/16/16.
//  Copyright © 2016 Nothin But Scorpions, LLC. All rights reserved.
//

import UIKit
import Social
import Accounts

let defaultAvatarURL = NSURL(string:
  "https://abs.twimg.com/sticky/default_profile_images/default_profile_6_200x200.png")

class RootViewController: UITableViewController {
  
  var parsedTweets: [ParsedTweet] = [  ]
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    reloadTweets()
    let refresher = UIRefreshControl()
    refresher.addTarget(self, action: #selector(RootViewController.handleRefresh(_:)), forControlEvents: .ValueChanged)
    refreshControl = refresher
  }
  
  @IBAction func handleRefresh(sender: AnyObject?) {
    reloadTweets()
    refreshControl?.endRefreshing()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  @IBAction func handleTweetButtonTapped(sender: UIButton) {
    if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter){
      let tweetVC = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
      tweetVC.setInitialText("I just finished the first project in iOS 9 SDK Development. #pragios9")
      self.presentViewController(tweetVC, animated: true, completion: nil)
    } else {
      NSLog("Can't send a tweet")
    }
  }
  
  func reloadTweets() {
    let twitterParams = [
      "count" : "100"
    ]
    
    guard let twitterAPIURL = NSURL(string: "https://api.twitter.com/1.1/statuses/home_timeline.json") else {
      return
    }
    
    sendTwitterRequest(twitterAPIURL, params: twitterParams, completion: handleTwitterData)
    tableView.reloadData()
  }
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return parsedTweets.count
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("CustomTweetCell") as! ParsedTweetCell
    let parsedTweet = parsedTweets[indexPath.row]
    cell.userNameLabel.text = parsedTweet.userName
    cell.tweetTextLabel.text = parsedTweet.tweetText
    cell.createdAtLabel.text = parsedTweet.createdAt
    cell.avatarImageView.image = nil
    
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0)){
      if let url = parsedTweet.userAvatarURL,
        imageData = NSData(contentsOfURL: url) where cell.userNameLabel.text == parsedTweet.userName {
        dispatch_async(dispatch_get_main_queue()) {
          cell.avatarImageView.image = UIImage(data: imageData)
        }
      }
    }
    return cell
  }
  
  private func handleTwitterData(data: NSData!, urlResponse: NSHTTPURLResponse!, error: NSError!) {
    guard let data = data else {
      NSLog("handleTwitterData() received no data")
      return
    }
    NSLog("handleTwitterData(), \(data.length) bytes")
    do {
      let jsonObject = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions([]))
      guard let jsonArray = jsonObject as? [[String:AnyObject]] else {
        NSLog("handleTwitterData() didn't get an array")
        return
      }
      parsedTweets.removeAll()
      
      for tweetDict in jsonArray{
        var parsedTweet = ParsedTweet()
        parsedTweet.tweetText = tweetDict["text"] as? String
        parsedTweet.createdAt = tweetDict["created_at"] as? String
        if let userDict = tweetDict["user"] as? [String:AnyObject] {
          parsedTweet.userName = userDict["name"] as? String
          if let avatarURLString = userDict["profile_image_url_https"] as? String {
            parsedTweet.userAvatarURL = NSURL(string: avatarURLString)
          }
        }
        parsedTweets.append(parsedTweet)
      }
      dispatch_async(dispatch_get_main_queue()){
        self.tableView.reloadData()
      }
    } catch let error as NSError {
      NSLog("JSON error: \(error)")
    }
  }
}

