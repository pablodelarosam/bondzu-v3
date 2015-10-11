//
//  GalleryViewController.swift
//  bondzuios
//
//  Created by Luis Mariano Arobes on 12/08/15.
//  Copyright (c) 2015 Bondzu. All rights reserved.
//  Archivo localizado

import UIKit
import Parse

class GalleryViewController: UIViewController, UICollectionViewDelegate , UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var collectionView: UICollectionView!
    var pictures = [UIImage]();
    var animalId: String!;
    
    
    override func viewDidAppear(animated: Bool) {
        self.navigationController?.navigationBar.topItem?.title = NSLocalizedString("Gallery", comment: "")
        self.navigationController!.navigationBar.topItem!.rightBarButtonItem = nil
        super.viewDidAppear(animated)
    }
    
    override func viewDidLoad() {
        self.activityIndicator.startAnimating()
       
        getPictures();
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.pictures.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("picCell", forIndexPath: indexPath) as! GalleryCollectionViewCell
        let img = self.pictures[indexPath.row] as UIImage
        cell.imageView.image = img
        return cell
        
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.imageSelected(self.pictures[indexPath.row])
    }    
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: -60.0, left: 5.0, bottom: 5.0, right: 5.0)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        return CGSize(width: (UIScreen.mainScreen().bounds.width/3) - 6, height: (UIScreen.mainScreen().bounds.width/3) - 6)
    }
    
    func getPictures() -> Void{
        let query = PFQuery(className:TableNames.Gallery_table.rawValue)
        query.whereKey(TableGalleryColumnNames.Animal.rawValue, equalTo: PFObject(withoutDataWithClassName: TableNames.Animal_table.rawValue, objectId: self.animalId))
        
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]?, error: NSError?) -> Void in
            
            if error == nil {
                //self.activityIndicator.startAnimating()
                // The find succeeded.
                print("Successfully retrieved \(objects!.count) pictures.")
                if(objects?.count == 0)
                {
                    print("NO Pictures")
                    /*self.txtNoPics.hidden = false;
                    self.activityIndicator.stopAnimating()*/
                    return;
                }
                var imagen = UIImage();                
                // Do something with the found objects
                self.pictures.removeAll(keepCapacity: true)
                if let objects = objects as? [PFObject] {
                    for (var i = 0; i < objects.count; i++)
                    {
                        print("i = \(i) objects.count = \(objects.count)")
                        let object = objects[i]
                        if let img = object.objectForKey(TableGalleryColumnNames.Image.rawValue) as? PFFile
                        {
                            let image = img
                            image.getDataInBackgroundWithBlock {
                                (imageData: NSData?, error: NSError?) -> Void in
                                if error == nil {
                                    if let imageData = imageData {
                                        imagen = UIImage(data:imageData)!
                                        self.pictures.append(imagen);
                                        if(i == objects.count)
                                        {
                                            print("RELOADING")
                                            self.collectionView.reloadData()
                                            self.activityIndicator.stopAnimating()
                                        }
                                    }
                                    
                                }
                            }
                        }
                    }
                }
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
    }
    
    
    func imageSelected(image: UIImage) {
        let i = FullImageViewController()
        i.background = captureScreen()
        self.parentViewController!.presentViewController(i, animated: true, completion: nil)
        i.loadImage(image)
    }

}
