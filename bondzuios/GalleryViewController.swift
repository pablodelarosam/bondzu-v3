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
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    override func viewDidAppear(_ animated: Bool) {
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
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.pictures.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "picCell", for: indexPath) as! GalleryCollectionViewCell
        let img = self.pictures[indexPath.row] as UIImage
        cell.imageView.image = img
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.imageSelected(self.pictures[indexPath.row])
    }    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: -60.0, left: 5.0, bottom: 5.0, right: 5.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (UIScreen.main.bounds.width/3) - 6, height: (UIScreen.main.bounds.width/3) - 6)
    }
    
    func getPictures() -> Void{
        //   PFQuery(className: TableNames.Gallery_table.rawValue)
        let query = PFQuery(className:TableNames.Gallery_table.rawValue)
        query.whereKey(TableGalleryColumnNames.Animal.rawValue, equalTo: PFObject(outDataWithClassName: "AnimalV2", objectId: self.animalId))
        
        query.findObjectsInBackground {
            (objects: [PFObject]?, error: Error?) -> Void in
            
            if error == nil {
                // The find succeeded.
                // Do something with the found objects
                self.pictures.removeAll(keepingCapacity: true)
                if let objects = objects {
                    self.galleryToLoad = objects.count
                    for object in objects {
                         _ = Gallery(object: object, delegate: self)
                    }
                }
            } else {
                // Log details of the failure
                print("Error: \(error!)")
            }}
    }
    

    func imageSelected(_ image: UIImage) {
        let i = FullImageViewController()
        i.modalTransitionStyle = .coverVertical
        i.transitioningDelegate = self
        self.parent!.present(i, animated: true, completion: nil)
        i.loadImage(image)
        dismissHelper.wireToViewController(i)
    }
    
    func galleryImageDidFinishLoading(_ gallery: Gallery) {
        self.pictures.append(gallery.image!);
        galleryToLoad -= 1;
        if galleryToLoad == 0{
            finishLoading()
        }
    }
    
    func galleryImageDidFailLoading(_ gallery: Gallery) {
        galleryToLoad -= 1;
        
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
