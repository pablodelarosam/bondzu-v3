//
//  GalleryViewController.swift
//  bondzuios
//
//  Created by Luis Mariano Arobes on 12/08/15.
//  Copyright (c) 2015 Bondzu. All rights reserved.
//

import UIKit
import Parse

class GalleryViewController: UIViewController, UICollectionViewDelegate , UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    @IBOutlet weak var collectionView: UICollectionView!
    var pictures = [UIImage]();
    var animalId: String!;
    let NUMBER_ITEMS_ROW: CGFloat = 3;
    
    override func viewDidAppear(animated: Bool) {
        self.navigationController?.navigationBar.topItem?.title = "Gallery"
        self.navigationController!.navigationBar.topItem!.rightBarButtonItem = nil
        super.viewDidAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.activityIndicator.startAnimating()
        /*let cellWidth = ( UIScreen.mainScreen().bounds.width - 15 ) / NUMBER_ITEMS_ROW
        let cellLayout = self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        cellLayout.itemSize = CGSize(width: cellWidth, height: cellWidth)*/
        getPictures();
        // Do any additional setup after loading the view.
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
        
        // Imagen en caso de que no haya
        /*
        var initialThumbnail = UIImage(named: "question")
        cell.imageView.image = initialThumbnail*/
        
        /*let photoFinal = imageWithImage(animal.image, scaledToSize: CGSize(width:self.screenWidth / NUMBER_ITEMS_ROW, height:self.screenWidth / NUMBER_ITEMS_ROW))*/
        cell.imageView.image = img
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    }
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func getPictures() -> Void
    {
        let query = PFQuery(className:"Gallery")
        query.whereKey("animal_id", equalTo: PFObject(withoutDataWithClassName: "AnimalV2", objectId: self.animalId))
        
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
                var i = 0;
                // Do something with the found objects
                self.pictures.removeAll(keepCapacity: true)
                if let objects = objects as? [PFObject] {
                    for (i = 0; i < objects.count; i++)
                    {
                        print("i = \(i) objects.count = \(objects.count)")
                        let object = objects[i]
                        if let img = object.objectForKey("image") as? PFFile
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

}
