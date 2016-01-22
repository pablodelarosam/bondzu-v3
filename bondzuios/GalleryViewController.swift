//
//  GalleryViewController.swift
//  bondzuios
//
//  Created by Luis Mariano Arobes on 12/08/15.
//  Copyright (c) 2015 Bondzu. All rights reserved.
//  Archivo localizado

import UIKit
import Parse

class GalleryViewController: UIViewController, UICollectionViewDelegate , UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, GalleryLoadingProtocol, UIViewControllerTransitioningDelegate {

    
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var collectionView: UICollectionView!
    var pictures = [UIImage]();
    var animalId: String!;
    var galleryToLoad = 0;
    weak var blockingHelper : UserBlockingHelper? = nil

    let dismissHelper = InteractiveDismissalHelper()
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewDidAppear(animated: Bool) {
        self.navigationController?.navigationBar.topItem?.title = NSLocalizedString("Gallery", comment: "")
        self.navigationController!.navigationBar.topItem!.rightBarButtonItem = nil
        super.viewDidAppear(animated)
    }
    
    override func viewDidLoad() {
        self.activityIndicator.startAnimating()
        self.transitioningDelegate = self
        getPictures();
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
            (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                if(objects?.count == 0){
                    print("NO Pictures")
                    return;
                }
                self.pictures.removeAll(keepCapacity: true)
                if let objects = objects{
                    self.galleryToLoad = objects.count
                    for object in objects{
                        _ = Gallery(object: object, delegate: self)
                    }
                }
            }
            else{
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
    }
    

    func imageSelected(image: UIImage) {
        let i = FullImageViewController()
        i.modalTransitionStyle = .CoverVertical
        i.transitioningDelegate = self
        self.parentViewController!.presentViewController(i, animated: true, completion: nil)
        i.loadImage(image)
        dismissHelper.wireToViewController(i)
    }
    
    func galleryImageDidFinishLoading(gallery: Gallery) {
        self.pictures.append(gallery.image!);
        galleryToLoad--;
        
        if galleryToLoad == 0{
            finishLoading()
        }
    }
    
    func galleryImageDidFailLoading(gallery: Gallery) {
        galleryToLoad--;
        
        if galleryToLoad == 0{
            finishLoading()
        }
    }
    
    func finishLoading(){
        self.collectionView.reloadData()
        self.activityIndicator.stopAnimating()
    }
    
    /*
    func interactionControllerForDismissal(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return dismissHelper
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return dismissHelper
    }
    */
    
}