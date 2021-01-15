//
//  ViewController.swift
//  FatImages
//
//  Created by Fernando Rodriguez on 10/12/15.
//  Copyright © 2015 Udacity. All rights reserved.
//

import UIKit

// MARK: - BigImages: String

enum BigImages: String {
    case whale = "https://d17h27t6h515a5.cloudfront.net/topher/2017/November/59fe5127_whale/whale.jpg"
    case shark = "https://d17h27t6h515a5.cloudfront.net/topher/2017/November/59fe5123_shark/shark.jpg"
    case seaLion = "https://d17h27t6h515a5.cloudfront.net/topher/2017/November/59fe511f_sealion/sealion.jpg"
}

// MARK: - ViewController: UIViewController

class ViewController: UIViewController {
    
    // MARK: Outlets
    
    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    
    // MARK: Actions
    
    @IBAction func setTransparencyOfImage(sender: UISlider) {
        photoView.alpha = CGFloat(sender.value)
    }
    
    // MARK: - Sync Download
    
    // this method downloads a huge image, blocking the main queue and the UI
    // (for instructional purposes only, NEVER DO THIS IN A PRODUCTION APP!!!!)
    @IBAction func synchronousDownload(sender: UIBarButtonItem) {
        // get the url for the image
        // get the NSData with the image
        // turn it into an image
        if let url = URL(string: BigImages.seaLion.rawValue), let imgData = try? Data(contentsOf: url), let image = UIImage(data: imgData) {
            // display image - UIImage can be used in background queues
            photoView.image = image
        }
    }
    
    // MARK: - Async Download
    
    // this method avoids blocking by creating a background queue, without blocking the UI
    @IBAction func simpleAsynchronousDownload(sender: UIBarButtonItem) {
        // get url for image
        let url = URL(string: BigImages.shark.rawValue)
        
        // create a queue from scratch
        let downloadQueue = DispatchQueue(label: "download", attributes: [])
        
        // call dispatch async to send a closure to the downloads queue
        downloadQueue.async { () -> Void in
            
            // download data
            let imgData = try? Data(contentsOf: url!)
            
            // turn it into a UIImage
            let image = UIImage(data: imgData!)
            
            // display it
            DispatchQueue.main.async(execute: { () -> Void in
                self.photoView.image = image
            })
            
        }
        
    }
    
    // MARK: - Async Download (with Completion Handler)
    func withBigImage(completionHandler handler: @escaping (_ image: UIImage) -> Void) {
        // userInteractive is top priority, userInitiated is normal priority, background is low priority
        DispatchQueue.global(qos: .userInitiated).async { () -> Void in
            if let url = URL(string: BigImages.whale.rawValue), let imgData = try? Data(contentsOf: url), let img = UIImage(data: imgData) {
                
                // all set and done, run the completion closure - ALL completion handelers should run in the main queue
                DispatchQueue.main.async(execute: { () -> Void in
                    handler(img)
                })
            }
        }
    }
    
    @IBAction func asynchronousDownload(sender: UIBarButtonItem) {
        // start animation - THIS DOES A COOL LOADING CIRCLE THING
        activityView.startAnimating()
        
        withBigImage { (image) -> Void in
            // display it
            self.photoView.image = image
            
            // stop animating
            self.activityView.stopAnimating()
        }
    }
}
