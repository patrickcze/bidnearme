//
//  GroupTableViewController.swift
//  Lulu
//
//  Created by Patrick Czeczko on 2016-12-03.
//  Copyright © 2016 Team Lulu. All rights reserved.
//

import UIKit
import AlamofireImage
import FirebaseAuth
import FirebaseDatabase

class GroupTableViewController: UITableViewController {
    var groups = [Group]()
    var ref: FIRDatabaseReference?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference()
        
        //Check if the user is logged in before displaying groups
        if let uid = FIRAuth.auth()?.currentUser?.uid {
            getGroupsForUser(userId: uid) { (userGroupsById) in
                if !userGroupsById.isEmpty {
                    for groupId in userGroupsById {
                        self.addGroupToTable(groupId: groupId)
                    }
                }
            }
        }
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        self.navigationController?.navigationBar.topItem?.title = "Groups"
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "GroupTableViewCell"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! GroupTableViewCell

        let group = groups[indexPath.row]
        
        cell.groupTitle.text = group.name
        cell.groupDesc.text = group.desc
        cell.groupItemCount.text = String(group.listingsById.count) + " items"
        cell.groupMemberCount.text = String(group.membersById.count) + " Members"
        cell.groupImage.af_setImage(withURL: group.imageUrl)
        
        return cell
    }
 
    
    //Get all of the groups a user is a member of
    func getGroupsForUser(userId: String, completion: @escaping ([String]) -> Void)  {
        ref?.child("users/\(userId)").observe(.value, with: { snap in
            var groups = [String]()
            self.groups = []
            
            let enumerator = snap.childSnapshot(forPath: "groups").children
            while let groupsSnap = enumerator.nextObject() as? FIRDataSnapshot {
                groups.append(groupsSnap.key)
            }
            
            completion(groups)
        })
    }
    
    func addGroupToTable(groupId: String) {
        getGroupById(groupId: groupId, completion: { (group) in
            self.groups += [group]
            self.tableView.reloadData()
        })
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let indexPath = tableView.indexPathForSelectedRow {
            let destinationController = segue.destination as! GroupListingViewController
            destinationController.group = groups[indexPath.row]
        }
    }
}
