//
//  StoryInfoViewController.swift
//  MobileNewsApp
//
//  Created by Eitan Yarmush on 3/9/17.
//  Copyright © 2017 cs378. All rights reserved.
//

import UIKit
import Parse
import MGSwipeTableCell

class StoryInfoViewController: UIViewController {
    
    var story: Story?
    var users = [User]()
    var allUsers = [User]()
    var storyUsers = [String: [User]]()
    var user: PFUser = PFUser.current()!
    var admin: Bool = false
    var invited =  [String]()
    
    struct userGroup {
        var sectionName: String!
        var sectionObjects: [User]
    }
    
    var userGroups = [userGroup]()
    
    @IBOutlet weak var userTable: UITableView!
    @IBOutlet weak var leaveButton: LoginScreenButton!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var promptView: UITextView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        userTable.delegate = self
        userTable.dataSource = self
        
        getListOfUsers2()
        
//        getListOfUsers()
        setupView()
//        setupInvite()
        promptView.text = story?.prompt!
        
        
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.userTable.reloadData()
    }
    
    func updateTable() {
//        print(invited.count)
//        if userGroups.count > 1 {
//            userGroups[1].sectionObjects = users.filter({self.invited.contains($0.id!)})
//            self.userTable.reloadData()
//        }
        if invited.count > 0 {
            print(invited)
            print(users)
            userGroups[1].sectionObjects = allUsers.filter({self.invited.contains($0.id!)})
            self.userTable.reloadData()
        }
    }
    
    func getListOfUsers() {
        story?.getUsers(completion: {(users: [User]?, error: Error?) -> Void in
            if error != nil
            {
                print ("there was an error getting the story users")
            }
            else
            {
                self.users = users!
                self.userTable.reloadData()

                
            }
        })
    }
    
    func getListOfUsers2() {
        
        User.getAllUsers(completion: {(users: [User]?, error: Error?) -> Void in
            if error != nil
            {
                print ("there was an error getting the story users")
            }
            else
            {
                self.allUsers = users!
                self.users = users!.filter({(user) -> Bool in
                    return self.story!.users.index(of: user.id!) != nil
                })
                
                let user = PFUser.current()
                
                for index in 0...(self.users.count-1) {
                    if self.users[index].id! == user?.objectId {
                        self.users.remove(at: index)
                        break
                    }
                }
                
                self.userGroups.append(userGroup(sectionName: "Active", sectionObjects: self.users))
                
                self.userTable.reloadData()
                
                self.story?.getInvites(completion: {(invitedUsers: [String]?, error: Error?) -> Void in
                    if error != nil
                    {
                        print ("There was an error retrieving Invites")
                    }
                    else
                    {
                        if invitedUsers != nil {
                            self.invited = invitedUsers!
                            self.userGroups.append(userGroup(sectionName: "Invited", sectionObjects: users!.filter({(user) -> Bool in
                                return self.invited.index(of: user.id!) != nil
                            })))
                            self.userTable.reloadData()
                        }
                        
                    }
                    
                })
 
            }
        })
      
    }
    
//    func setupInvite() {
//        let button = self.navigationItem.rightBarButtonItem
//        button.
//    }
    
    func setupView() {
        self.automaticallyAdjustsScrollViewInsets = false
        userTable.layer.cornerRadius = 5
        userTable.layer.borderColor = UIColor.lightGray.cgColor
        userTable.layer.borderWidth = 2.0
        
        self.titleLabel?.text = self.story?.title
        self.authorLabel?.text = self.story?.author
        
        if story?.createdBy == self.user.objectId
        {
            //Case when the current User is the Admin.
            self.leaveButton.setTitle("Delete Story", for: .normal)
            self.admin = true
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func leaveStory(_ sender: Any) {
        var title = "Delete"
        var message = "Are you sure you want to delete this story?"
        if admin == false {
            message = "Are you sure you want to leave this story"
            title = "Remove"
        }
        
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: title, style: .default, handler: {(action: UIAlertAction) in
            if self.admin == true
            {
                //Delete the story for good
                self.story?.deleteStory(completion: {(error: Error?) -> Void in
                    if error != nil
                    {
                        print("there was an error deleting the story")
                        return
                    }
                })
            }
            else
            {
                //Just delete user from Story
                self.story?.removeUser(user: self.user.objectId!, completion: {(error: Error?) -> Void in
                    if error != nil
                    {
                        print("There was an error removing you from the story")
                        return
                    }
                })
            }
            //Segue back to profile
            let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController];
            if viewControllers[viewControllers.count-3] is ProfileViewController {
                //Code is here so that User does not have to navigate through the Join Story Page again
                self.navigationController!.popToViewController(viewControllers[viewControllers.count - 3], animated: true);
            } else {
                //Do Nothing
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
        

    }
    
    @IBAction func inviteButton(_ sender: UIBarButtonItem) {
        
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let vc = segue.destination as! InviteViewController
        vc.story = self.story!
        vc.invited = self.invited
        vc.parentVC = self
        vc.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
 

}


//Table View Section
extension StoryInfoViewController: UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //If admin return both sections, otherwise only return the first
        var returnVal = userGroups[section].sectionObjects.count
        if section == 1 && self.admin == false {
            returnVal = 0
        }
//        return self.admin ? userGroups[section].sectionObjects.count : 1
        return returnVal
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = userTable.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as! UserTableViewCell
        if userGroups[indexPath.section].sectionObjects.count > 0 {
            let user = userGroups[indexPath.section].sectionObjects[indexPath.row]
            cell.user = user
            cell.nameLabel.text = "\((user.firstName)!) \((user.lastName)!)"
            let avatar = UIImage(named: "username")
            cell.avatarImage.image = avatar
            cell.avatarImage.layer.backgroundColor = UIColor.lightGray.cgColor
            cell.avatarImage.layer.cornerRadius = cell.avatarImage.layer.bounds.width/2
            
            let reportButton = MGSwipeButton(title: "Report", backgroundColor: UIColor.red)
            {
                (sender: MGSwipeTableCell!) in
                
                print("Report button clicked")
                
                return true
                
            }
            reportButton.titleLabel?.font = UIFont(name: "DIN", size: 15)
            
            let pfUser = PFUser.current()
            var currentUser = User(pfobject: pfUser!)

            if (currentUser.blockedUsers?.contains(user.id!))! {
                
                cell.blockLabel.isHidden = false
                
                let unblockButton = MGSwipeButton(title: "Unblock", backgroundColor: UIColor.blue)
                {
                    (sender: MGSwipeTableCell!) in
                    
                    currentUser.unblockUser(user: user.id!, completion: {(error: Error?) -> Void in
                        if error != nil {
                            print(error!)
                        }
                        else {
                            pfUser?.fetchInBackground(block: {(object, error) -> Void in
                                if error != nil {
                                    print(error!)
                                }
                                else {
                                    self.user = object as! PFUser
                                    self.userTable.reloadData()
                                }
                            })
                        }
                    })
                    
                    return true
                }
                
                unblockButton.titleLabel?.font = UIFont(name: "DIN", size: 15)
                cell.rightButtons = [reportButton, unblockButton]
                cell.rightSwipeSettings.transition = .rotate3D
            }
                // Configure the cell...
            else {
                
                cell.blockLabel.isHidden = true
                
                let blockButton = MGSwipeButton(title: "Block", backgroundColor: UIColor.blue)
                {
                    (sender: MGSwipeTableCell!) in
                    
                    let pfUser = PFUser.current()
                    var currentUser = User(pfobject: pfUser!)
                    currentUser.blockUser(user: user.id!, completion: {(error: Error?) -> Void in
                        if error != nil {
                            print(error!)
                        }
                        else {
                            pfUser?.fetchInBackground(block: {(object, error) -> Void in
                                if error != nil {
                                    print(error!)
                                }
                                else {
                                    self.user = object as! PFUser
                                    self.userTable.reloadData()
                                }
                            })
                        }
                    })
                    return true
                    
                }
                blockButton.titleLabel?.font = UIFont(name: "DIN", size: 15)
                cell.rightButtons = [reportButton, blockButton]
                cell.rightSwipeSettings.transition = .rotate3D
            }
        }
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.userGroups[section].sectionName
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.userGroups.count
    }
    
}
