//
//  UserTableViewController.swift
//  Instagram
//
//  Created by shrikant kekane on 15.05.20.
//  Copyright © 2020 shrikant kekane. All rights reserved.
//

import UIKit
import Parse

class UserTableViewController: UITableViewController {
    
    var userNames = [""]
    var objectIds = [""]
    var isFollowing = ["": false]
    
    var refresher: UIRefreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        updateTable()
        refresher.attributedTitle = NSAttributedString(string: "Pull to Refresh")
        refresher.addTarget(self, action: #selector(UserTableViewController.updateTable), for: .valueChanged)
        tableView.addSubview(refresher)
    }
    
    @objc func updateTable() {
        let query = PFUser.query()
              
              query?.whereKey("username", notEqualTo: PFUser.current()?.username)
              
              query?.findObjectsInBackground(block: { (users, error) in
                  
                  if error != nil {
                      print(error)
                  } else {
                      if let users = users {
                          self.userNames.removeAll()
                          self.objectIds.removeAll()
                          self.isFollowing.removeAll()
                          for object in users {
                              if let user = object as? PFUser {
                                  if let userName = user.username {
                                      if let objectId = user.objectId {
                                          let userNameArray = userName.components(separatedBy: "@")
                                          self.userNames.append(userNameArray[0])
                                          self.objectIds.append(objectId)
                                          
                                          let query = PFQuery(className: "Following")
                                          query.whereKey("follower", equalTo: PFUser.current()?.objectId)
                                          query.whereKey("following", equalTo: objectId)
                                          
                                          query.findObjectsInBackground { (objects, error) in
                                              if let objects = objects {
                                                  if objects.count > 0 {
                                                      self.isFollowing[objectId] = true
                                                  } else {
                                                      self.isFollowing[objectId] = false
                                                  }
                                                if self.userNames.count == self.isFollowing.count {
                                                    self.tableView.reloadData()
                                                    self.refresher.endRefreshing()
                                                }
                                               
                                              }
                                          }
                                                                        
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
        return userNames.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        cell.textLabel?.text = userNames[indexPath.row]
        
        if let followsBoolean = isFollowing[objectIds[indexPath.row]] {
            if followsBoolean  {
                cell.accessoryType = UITableViewCell.AccessoryType.checkmark
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        
        if let followsBoolean = isFollowing[objectIds[indexPath.row]] {
            if followsBoolean  {
                isFollowing[objectIds[indexPath.row]] = false
                cell?.accessoryType = UITableViewCell.AccessoryType.none
                let query = PFQuery(className: "Following")
                query.whereKey("follower", equalTo: PFUser.current()?.objectId)
                query.whereKey("following", equalTo: objectIds[indexPath.row])
                
                query.findObjectsInBackground( block: { (objects, error) in
                    if let objects = objects {
                        for object in objects {
                            object.deleteInBackground()
                        }
                    }
                })
            } else {
                isFollowing[objectIds[indexPath.row]] = true
                cell?.accessoryType = UITableViewCell.AccessoryType.checkmark
                let following = PFObject(className: "Following")
                following["follower"] = PFUser.current()?.objectId
                following["following"] = objectIds[indexPath.row]
                following.saveInBackground()

            }
        }
               
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func logoutUser(_ sender: UIBarButtonItem) {
        
        PFUser.logOut()
        
        self.performSegue(withIdentifier: "logoutSegue", sender: self)
    }
    
}
