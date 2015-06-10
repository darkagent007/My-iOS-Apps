//
//  ViewController.swift
//  Table
//
//  Created by Paul Intharathut on 6/10/15.
//  Copyright (c) 2015 Paul Intharathut. All rights reserved.
//

import UIKit

class SearchResultsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,APIControllerProtocol {

    var api : APIController!
    
    let kCellIdentifier: String = "SearchResultCell"
    
    @IBOutlet var myTable: UITableView!
    
    var imageCache = [String:UIImage]()
    
    var albums = [Album]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        api = APIController(delegate: self)
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        api.searchForItunes("Beatles")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return albums.count
        
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier(kCellIdentifier) as! UITableViewCell
        let album = self.albums[indexPath.row]
        
        // Get the formatted price string for display in the subtitle
        cell.detailTextLabel?.text = album.price
        // Update the textLabel text to use the title from the Album model
        cell.textLabel?.text = album.title
        
        // Start by setting the cells image to static file
        // Without this, we will end up without an image view
        cell.imageView?.image = UIImage(named: "Blank52")
        
        let thumbnailURLString = album.thumbnailImageURL
        let thumbnailURL = NSURL(string: thumbnailURLString)!
        
        // If this image is already cached, don't re-download
        if let img = imageCache[thumbnailURLString] {
            cell.imageView?.image = img
        }
        else {
            // The image isn't cached, download the image data
            // We should perform this in a background thread
            let request: NSURLRequest = NSURLRequest(URL: thumbnailURL)
            let mainQueue = NSOperationQueue.mainQueue()
            NSURLConnection.sendAsynchronousRequest(request, queue: mainQueue, completionHandler: { (response, data, error) -> Void in
                if error == nil {
                    // Convert the download data in to a UIImage object
                    let image = UIImage(data: data)
                    // Store the image in to our cache
                    self.imageCache[thumbnailURLString] = image
                    // Update the cell
                    dispatch_async(dispatch_get_main_queue(), {
                        if let cellToUpdate = tableView.cellForRowAtIndexPath(indexPath) {
                            cellToUpdate.imageView?.image = image
                        }
                    })
                }
                else {
                    println("Error: \(error.localizedDescription)")
                }
            })
        }
        return cell
    }
/*
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Get the row data for the selected row
        if let rowData = self.albums[indexPath.row] as? NSDictionary,
            // Get the name of the track for this row
            name = rowData["trackName"] as? String,
            // Get the price of the track on this row
            formattedPrice = rowData["formattedPrice"] as? String {
                let alert = UIAlertController(title: name, message: formattedPrice, preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
        }
        
    }
*/    
    func didReceiveAPIResults(results: NSArray) {
        dispatch_async(dispatch_get_main_queue(), {
            self.albums = Album.albumsWithJSON(results)
            self.myTable!.reloadData()
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        })
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let detailsViewController: DetailsViewController = segue.destinationViewController as? DetailsViewController {
            var albumIndex = myTable!.indexPathForSelectedRow()!.row
            var selectedAlbum = self.albums[albumIndex]
            detailsViewController.album = selectedAlbum
        }
    }

}

