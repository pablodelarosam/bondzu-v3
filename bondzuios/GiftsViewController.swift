//
//  GiftsViewController.swift
//  bondzuios
//
//  Created by Luis Mariano Arobes on 12/08/15.
//  Copyright (c) 2015 Bondzu. All rights reserved.
//  Archvivo Localizado


import UIKit
import Parse

class GiftsViewController: UIViewController, UICollectionViewDelegate , UICollectionViewDataSource, ProductoLoadingProtocol {
    
    var user : Usuario!
    
    let NUMBER_ITEMS_ROW: CGFloat = 2;
    var animalId: String!
    var productos = [Producto]()
    var productsToShow = [Producto]()
    var selectedSegment: Int = 0;
    var segments = [NSLocalizedString("Comida", comment: ""), NSLocalizedString("Medicina", comment: ""), NSLocalizedString("Juguetes", comment: ""), NSLocalizedString("Recuerdos", comment: "")];
    var navHairLine:UIImageView? = UIImageView()
    var selectedProduct: Producto!;
    
    weak var blockingHelper : UserBlockingHelper? = nil

    var toLoad = 0
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var collectionView: UICollectionView!
       
    @IBOutlet weak var txtNoGifts: UITextView!
    @IBAction func segmentedControlChanged(sender: UISegmentedControl) {
        self.selectedSegment = sender.selectedSegmentIndex
        updateProductsThatShouldShow()
    }
    
    @IBOutlet weak var noGiftsLabel: UITextView!
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait

    }
    
    override func viewDidAppear(animated: Bool) {        
        self.navigationController?.navigationBar.topItem?.title = NSLocalizedString("Gifts", comment: "")
        self.navigationController?.navigationBar.topItem?.rightBarButtonItem = nil
        super.viewDidAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let cellWidth = ((UIScreen.mainScreen().bounds.width)-15) / NUMBER_ITEMS_ROW
        let cellLayout = self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        cellLayout.itemSize = CGSize(width: cellWidth, height: cellWidth)
        self.navHairLine = Utiles.getHairLine(self.navigationController!.navigationBar)
        self.toolbar.barStyle = .Black
        self.toolbar.barTintColor = Constantes.COLOR_NARANJA_NAVBAR
        
        if user.hasLoadedPriority{
            self.toolbar.barTintColor = user.type!.color
        }
        else{
            user.appendTypeLoadingObserver({
                (_, type) -> () in
                if let type = type{
                    self.toolbar.barTintColor = type.color
                    self.collectionView.reloadData()
                }
            })
        }
        
        self.toolbar.tintColor = UIColor.whiteColor()
        self.txtNoGifts.hidden = true
        getProductsOfAnimalWith(self.animalId)
        noGiftsLabel.text = NSLocalizedString("No gifts here.", comment: "")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        Utiles.moveHairLine(true, navHairLine: self.navHairLine, toolbar: self.toolbar)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        Utiles.moveHairLine(false, navHairLine: self.navHairLine, toolbar: self.toolbar)
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.productsToShow.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("giftCell", forIndexPath: indexPath) as! GiftCollectionViewCell
        
        let producto = self.productsToShow[indexPath.row] as Producto
        cell.label.text = producto.nombre
        let size = CGSizeMake(57, 57)
        let photoFinal = Imagenes.imageResize(producto.photo, sizeChange: size, scale: UIScreen.mainScreen().scale);
        cell.imageView.image = photoFinal
        Imagenes.redondeaVista(cell, radio: 1.5)
        
        if user.hasLoadedPriority{
            cell.backgroundColor = user.type!.color
        }
        else{
            cell.backgroundColor = Constantes.COLOR_NARANJA_NAVBAR
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.selectedProduct = self.productsToShow[indexPath.row];
        let detailVC = self.storyboard?.instantiateViewControllerWithIdentifier("GiftDetailVC") as! GiftDetailViewController
        let navContoller = UINavigationController(rootViewController: detailVC);
        detailVC.producto = self.productsToShow[indexPath.row];
        detailVC.user = self.user
        self.navigationController?.presentViewController(navContoller, animated: true, completion: nil);
    }
    
 
    func updateProductsThatShouldShow(){
        self.productsToShow.removeAll(keepCapacity: true)
        let selectedCategory = self.segments[self.selectedSegment];
        if(productos.count == 0){
            self.txtNoGifts.hidden = false;
        }
        else{
            self.txtNoGifts.hidden = true;
        }
        for product in productos{
            if product.categoria == selectedCategory{
                self.productsToShow.append(product)
            }
        }
        if(productsToShow.count == 0)
        {
            self.txtNoGifts.hidden = false;
        }else{
            self.txtNoGifts.hidden = true;
        }
        self.activityIndicator.stopAnimating()
        self.collectionView.reloadData()
    }
    
    func getProductsOfAnimalWith(id: String){
        let query = PFQuery(className: TableNames.Products.rawValue);
        query.whereKey(TableProductColumnNames.AnimalID.rawValue, equalTo: PFObject(withoutDataWithClassName: TableNames.Animal_table.rawValue, objectId: self.animalId))
        query.orderByAscending(TableProductColumnNames.Name.rawValue + NSLocalizedString(LOCALIZED_STRING, comment: ""))
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                self.activityIndicator.startAnimating()
                if(objects?.count == 0){
                    self.txtNoGifts.hidden = false;
                    self.activityIndicator.stopAnimating()
                    return;
                }
                
                self.productos.removeAll(keepCapacity: true)
                
                if let objects = objects{
                    self.toLoad = objects.count
                    
                    for object in objects{
                        _ = Producto(object: object, delegate: self)
                    }
                }
            }
            else {
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func productoDidFailedLoading(product: Producto) {
        if(--toLoad == 0){
            self.updateProductsThatShouldShow()
        }
    }
    
    func productoDidFinishLoading(product: Producto) {
        if(product.disponible){
            self.productos.append(product);
            if(--toLoad == 0){
                self.updateProductsThatShouldShow()
            }
        }
    }
}
