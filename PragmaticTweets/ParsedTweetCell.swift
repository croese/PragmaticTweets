//
//  ParsedTweetCellTableViewCell.swift
//  PragmaticTweets
//
//  Created by Christian Roese on 7/18/16.
//  Copyright © 2016 Nothin But Scorpions, LLC. All rights reserved.
//

import UIKit

class ParsedTweetCell: UITableViewCell {

  @IBOutlet weak var avatarImageView: UIImageView!
  @IBOutlet weak var userNameLabel: UILabel!
  @IBOutlet weak var tweetTextLabel: UILabel!
  @IBOutlet weak var createdAtLabel: UILabel!
  
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
