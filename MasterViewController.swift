//
//  MasterViewController.swift
//  TestApp
//
//  Created by iqrar haider on 1/6/15.
//  Copyright (c) 2015 iqrar haider. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {

    var loans = [Loan]()
    var titArray = [String]()
    var loanC : Loan!
    var struck = "iqrar"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.estimatedRowHeight = 100.0;
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        // Pull To Refresh Control
        refreshControl = UIRefreshControl()
        refreshControl?.backgroundColor = UIColor.whiteColor()
        refreshControl?.tintColor = UIColor.grayColor()
        refreshControl?.addTarget(self, action: "getLatestLoans", forControlEvents: UIControlEvents.ValueChanged)
        getLatestLoans()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if titArray.isEmpty {
            println("empty")
            
        }else{
            self.navigationItem.title = self.titArray[0]
        }
        
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return loans.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as MasterTableViewCell
        
        // Configure the cell...
        cell.titleLabel.text = loans[indexPath.row].name
        cell.desplabel.text = loans[indexPath.row].des
        cell.titleLabel.textColor = UIColor.blueColor()
        //cell.imageView?.image = UIImage(named:"check2")
        dispatch_async(dispatch_get_main_queue(), {
            if let imgURL: NSURL = NSURL(string: self.loans[indexPath.row].hrefString){
                
                // Download an NSData representation of the image at the URL
                if let imgData = NSData(contentsOfURL: imgURL){
                    cell.rightImage?.image = UIImage(data: imgData)
                    //cell.imageView?.center = CGPointMake (30.0, 20.0);
                }
                //cell.rightImage?.center = CGPointMake(cell.contentView.bounds.size.width/2,cell.contentView.bounds.size.height/2);
            }
        })
        
        
        
        return cell
    }
    
    func getLatestLoans() {
        let urlAsString = "https://api.myjson.com/bins/4ll2f"
        let url = NSURL(string: urlAsString)!
        let urlSession = NSURLSession.sharedSession()
        let task = urlSession.dataTaskWithURL(url, completionHandler: { (data, response, error) -> Void in
            
            if error != nil {
                println(error.localizedDescription)
            }
            
            // Parse JSON data
            self.loans = self.parseJsonData(data)
            
            // Reload table view
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadData()
                self.refreshControl?.endRefreshing()
            })
            
            
            
        })
        
        task.resume()
    }
    
    func parseJsonData(data: NSData) -> [Loan] {
        var loans = [Loan]()
        println(loans)
        var error:NSError?
        
        let jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &error) as? NSDictionary
        
        
        let title  = jsonResult?["title"]  as String
        println(title)
        titArray.append(title)
        println(titArray[0])
        
        // Return nil if there is any error
        if error != nil {
            println(error?.localizedDescription)
        }
        
        // Parse JSON data
        if let jsonLoans = jsonResult?["rows"] as? [AnyObject]{
            for jsonLoan in jsonLoans {
                
                if let name = jsonLoan["title"] as? String{
                    
                    if let des = jsonLoan[ "description"] as? String{
                        
                        if let hrefString = jsonLoan[ "imageHref" ] as? String{
                            let loan = Loan(name:name, des:des, hrefString:hrefString)
                            loans.append(loan)
                        }
                    }
                }
            }
            
        }
        //println(loans)
        return loans
        
    }
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    }
    */
}
