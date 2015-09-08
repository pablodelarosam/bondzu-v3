//
//  CatalogViewController.swift
//  bondzuios
//
//  Created by Luis Mariano Arobes on 12/08/15.
//  Copyright (c) 2015 Bondzu. All rights reserved.
//

import UIKit
import Parse

class CatalogViewController: UIViewController, UICollectionViewDelegate , UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{

    var navHairLine:UIImageView? = UIImageView()
    
    @IBOutlet weak var segementedControl: UISegmentedControl!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var heightBanner: NSLayoutConstraint!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    let NUMBER_ITEMS_ROW: CGFloat = 3;
    var animals = [AnimalV2]()
    var animalsToShow = [AnimalV2]()
    var selectedAnimal: AnimalV2!;
    
    var screenSize: CGRect!
    var screenWidth: CGFloat!
    var screenHeight: CGFloat!
    
    let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Dark)) as UIVisualEffectView
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.heightBanner.constant = 0;
        // Do any additional setup after loading the view.
        self.navigationController?.navigationBar.barStyle = .Black
        self.navigationController?.navigationBar.barTintColor = Constantes.COLOR_NARANJA_NAVBAR
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        screenSize = UIScreen.mainScreen().bounds
        screenWidth = screenSize.width
        screenHeight = screenSize.height
        
        /*let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 5, right: 5)
        layout.itemSize = CGSize(width: screenWidth / NUMBER_ITEMS_ROW, height: screenHeight / NUMBER_ITEMS_ROW)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        self.collectionView.collectionViewLayout = layout;*/
    
        self.collectionView.backgroundView = self.visualEffectView;
        self.collectionView.alpha = 0.85;
        
        self.navHairLine = Utiles.getHairLine(self.navigationController!.navigationBar)
        self.toolbar.barStyle = .Black
        self.toolbar.barTintColor = Constantes.COLOR_NARANJA_NAVBAR
        self.segementedControl.tintColor = UIColor.whiteColor()
        self.activityIndicator.startAnimating()
        getAnimals();
    }
    
    
    override func viewWillAppear(animated: Bool) {
        self.navigationItem.hidesBackButton = true;
        Utiles.moveHairLine(true, navHairLine: self.navHairLine, toolbar: self.toolbar)
    }
    
    override func viewDidDisappear(animated: Bool) {
        Utiles.moveHairLine(false, navHairLine: self.navHairLine, toolbar: self.toolbar)
    }
    
    override func viewWillLayoutSubviews() {
        visualEffectView.frame.size = CGSize(width: self.collectionView.frame.width , height: self.collectionView.frame.height)
        super.viewWillLayoutSubviews();
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.animalsToShow.count
    }

    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("animalCell", forIndexPath: indexPath) as! AnimalCollectionViewCell
        
        let animal = self.animalsToShow[indexPath.row] as AnimalV2
        cell.nameLabel.text = animal.name;
        cell.speciesLabel.text = animal.specie;
        
        // Imagen en caso de que no haya
        /*
        var initialThumbnail = UIImage(named: "question")
        cell.imageView.image = initialThumbnail*/
        
        let photoFinal = imageWithImage(animal.image, scaledToSize: CGSize(width:self.screenWidth / NUMBER_ITEMS_ROW, height:self.screenWidth / NUMBER_ITEMS_ROW))
        cell.imageView.image = photoFinal
        
        Imagenes.redondeaVista(cell.imageView, radio: cell.imageView.frame.size.width / 2);
        cell.imageView.layer.borderColor = UIColor.whiteColor().CGColor;
        cell.imageView.layer.borderWidth = 5;
        
        /*cell.layer.borderColor = UIColor.whiteColor().CGColor;
        cell.layer.borderWidth = 1;*/
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.selectedAnimal = self.animalsToShow[indexPath.row];
        performSegueWithIdentifier("catalogSegue", sender: self)
    }
    
    @IBAction func next(sender: UIBarButtonItem) {
        
        /*let vc : UITabBarController = self.storyboard!.instantiateViewControllerWithIdentifier("Tabs") as! UITabBarController
        self.presentViewController(vc, animated: true, completion: nil);*/
        //performSegueWithIdentifier("catalogSegue", sender: self)
        print("Buscar");

    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let nextVC : TabsViewController = segue.destinationViewController as! TabsViewController
        
        nextVC.animal = self.selectedAnimal;
    }
    
    func updateAnimalsThatShouldShow()
    {
        self.activityIndicator.stopAnimating()
        self.collectionView.reloadData()
    }
    
    func getAnimals()
    {
        let query = PFQuery(className:"AnimalV2")
        query.whereKeyExists("objectId");
        query.orderByAscending("name");
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]?, error: NSError?) -> Void in
            
            if error == nil {
                // The find succeeded.
                print("Successfully retrieved \(objects!.count) animals.")
                // Do something with the found objects
                if let objects = objects as? [PFObject] {
                    var i = 0 as Int;
                    for object in objects {
                        print(object.objectId)
                        i++;
                        
                        let image = object.objectForKey("profilePhoto") as? PFFile;
                        image?.getDataInBackgroundWithBlock
                            {
                                (imageData: NSData?, error: NSError?) -> Void in
                                let animal = AnimalV2();
                                if error == nil
                                {
                                    animal.image = UIImage(data: imageData!);
                                }
                                animal.name = object.objectForKey("name") as! String;
                                animal.objectId = object.objectId!;
                                animal.specie = object.objectForKey("species") as! String;
                                self.animalsToShow.append(animal);
                                
                                //self.activityIndicator.stopAnimating()
                                //self.updateAnimalsThatShouldShow();
                                self.collectionView.reloadData();
                                
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
