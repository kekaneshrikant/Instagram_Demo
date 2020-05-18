//
//  FeedTableViewController.swift
//  Instagram
//
//  Created by shrikant kekane on 16.05.20.
//  Copyright © 2020 shrikant kekane. All rights reserved.
//

import UIKit
import Parse

class FeedTableViewController: UITableViewController {
    
    var users = [String: String]()
    var comments = [String]()
    var userNames = [String]()
    var imageFiles = [PFFileObject]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //tableView.rowHeight = UITableView.automaticDimension
    
        let query = PFUser.query()
        query?.whereKey("username", notEqualTo: PFUser.current()?.username)
        query?.findObjectsInBackground(block: { (objects, error) in
            
            if let users = objects {
                for object in users {
                    if let user = object as? PFUser {
                        self.users[user.objectId!] = user.username!
                    }
                }
            }
            
            let getFollowingUsersQuery = PFQuery(className: "Following")
            getFollowingUsersQuery.whereKey("follower", equalTo: PFUser.current()?.objectId)
            getFollowingUsersQuery.findObjectsInBackground { (objects, errors) in
                if let followers = objects {
                    for follower in followers {
                        let followedUser = follower["following"]
                        let query = PFQuery(className: "Post")
                        query.whereKey("userid", equalTo: followedUser!)
                        query.findObjectsInBackground { (objects, error) in
                            if let posts = objects {
                                for post in posts {
                                    self.comments.append(post["message"] as! String)
                                    self.userNames.append(post["userid"] as! String)
                                    self.imageFiles.append(post["imageFile"] as! PFFileObject)
                                    self.tableView.reloadData()
                                }
                            }
                        }
                    }
                }
            }
        })

    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return comments.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : FeedTableViewCell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! FeedTableViewCell
        
        imageFiles[indexPath.row].getDataInBackground { (data, error) in
            if let imageData = data {
                if let imageDataToDisplay = UIImage(data: imageData) {
                    cell.postedImage.image = imageDataToDisplay
                }
            }
        }
        
        //cell.postedImage.image = UIImage(systemName: "plus")
        cell.comment.text = comments[indexPath.row]
        cell.userInfo.text = userNames[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 340
    }

}
