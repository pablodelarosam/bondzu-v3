//
//  GiftsViewController.swift
//  bondzuios
//
//  Created by Luis Mariano Arobes on 12/08/15.
//  Copyright (c) 2015 Bondzu. All rights reserved.
//

import UIKit
import Parse

class GiftsViewController: UIViewController, UICollectionViewDelegate , UICollectionViewDataSource {
    
    let NUMBER_ITEMS_ROW: CGFloat = 2;
    var animalId: String!
    var productos = [Producto]()
    var productsToShow = [Producto]()
    var selectedSegment: Int = 0;
    var segments = ["Comida", "Medicina", "Juguetes", "Recuerdos"];
    var navHairLine:UIImageView? = UIImageView()
    var selectedProduct: Producto!;
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var collectionView: UICollectionView!
       
    @IBOutlet weak var txtNoGifts: UITextView!
    @IBAction func segmentedControlChanged(sender: UISegmentedControl) {
        self.selectedSegment = sender.selectedSegmentIndex
        updateProductsThatShouldShow()
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait

    }
    
    override func viewDidAppear(animated: Bool) {        
        self.navigationController?.navigationBar.topItem?.title = "Gifts"
        self.navigationController?.navigationBar.topItem?.rightBarButtonItem = nil
        super.viewDidAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /*let cellWidth = ((UIScreen.mainScreen().bounds.width) - 32 - 30 ) / NUMBER_ITEMS_ROW*/
        
        /*let cellLayout = self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        cellLayout.itemSize = CGSize(width: cellWidth, height: cellWidth+10)*/
        // Do any additional setup after loading the view.
        let cellWidth = ((UIScreen.mainScreen().bounds.width)-15) / NUMBER_ITEMS_ROW
        let cellLayout = self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        cellLayout.itemSize = CGSize(width: cellWidth, height: cellWidth)
        self.navHairLine = Utiles.getHairLine(self.navigationController!.navigationBar)
        self.toolbar.barStyle = .Black
        self.toolbar.barTintColor = Constantes.COLOR_NARANJA_NAVBAR
        self.toolbar.tintColor = UIColor.whiteColor()
        print("animal id gifts: \(self.animalId)");

        //TEST
        //self.animalId = "uoG4QimJN9"
        
        self.txtNoGifts.hidden = true
        getProductsOfAnimalWith(self.animalId)
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
        
        // Imagen en caso de que no haya
        /*
        var initialThumbnail = UIImage(named: "question")
        cell.imageView.image = initialThumbnail*/
        let size = CGSizeMake(57, 57)
        let photoFinal = Imagenes.imageResize(producto.photo, sizeChange: size, scale: UIScreen.mainScreen().scale);
        cell.imageView.image = photoFinal
        Imagenes.redondeaVista(cell, radio: 1.5)
        /*cell.layer.borderColor = cell.backgroundColor?.CGColor
        cell.layer.borderWidth = 0.2*/
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.selectedProduct = self.productsToShow[indexPath.row];
        //performSegueWithIdentifier("segueDetailGift", sender: self)
        
        let detailVC = self.storyboard?.instantiateViewControllerWithIdentifier("GiftDetailVC") as! GiftDetailViewController
        let navContoller = UINavigationController(rootViewController: detailVC);
        detailVC.producto = self.productsToShow[indexPath.row];
        //self.presentViewController(detailVC, animated: true, completion: nil)
        self.navigationController?.presentViewController(navContoller, animated: true, completion: nil);
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let giftDetailVC = segue.destinationViewController as! GiftDetailViewController;
        giftDetailVC.producto = self.selectedProduct;
    }
    
    func updateProductsThatShouldShow()
    {
        self.productsToShow.removeAll(keepCapacity: true)
        let selectedCategory = self.segments[self.selectedSegment];
        if(productos.count == 0)
        {
            self.txtNoGifts.hidden = false;
        }else{
            self.txtNoGifts.hidden = true;
        }
        for product in productos
        {
            if product.categoria == selectedCategory
            {
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
    
    func getProductsOfAnimalWith(id: String)
    {
        let query = PFQuery(className: "Productos");
        query.whereKey("animal_Id", equalTo: PFObject(withoutDataWithClassName: "AnimalV2", objectId: self.animalId))
        query.orderByAscending("nombre")
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]?, error: NSError?) -> Void in
            
            if error == nil {
                self.activityIndicator.startAnimating()
                // The find succeeded.
                print("Successfully retrieved \(objects!.count) products.")
                if(objects?.count == 0)
                {
                    print("NO GIFTS")
                    self.txtNoGifts.hidden = false;
                    self.activityIndicator.stopAnimating()
                    return;
                }
                var imagen = UIImage();
                var i = 0;
                // Do something with the found objects
                self.productos.removeAll(keepCapacity: true)
                if let objects = objects as? [PFObject] {
                    for (i = 0; i < objects.count; i++)
                    {
                        print("i = \(i) objects.count = \(objects.count)")
                        let object = objects[i]
                        if let _ = object.objectForKey("photo") as? PFFile
                        {
                            let image = object.objectForKey("photo") as? PFFile
                            image!.getDataInBackgroundWithBlock {
                                (imageData: NSData?, error: NSError?) -> Void in
                                if error == nil {
                                    if let imageData = imageData {
                                        imagen = UIImage(data:imageData)!
                                    }
                                    
                                    //var id = object.objectId
                                    
                                    print(object.objectId)
                                    var nom = "Nombre";
                                    var cat = "Categoria";
                                    var animalid = "-1";
                                    var desc = "Descripcion";
                                    var precio1 = 100.0;
                                    var precio2 = 200.0;
                                    var precio3 = 300.0;
                                    var disponible = false;
                                    var info = "Informacion";
                                    var infoAmount  = "";
                                    
                                    if let _nombre = object.objectForKey("nombre") as? String
                                    {
                                        nom = _nombre
                                    }
                                    
                                    if let _categoria = object.objectForKey("categoria") as? String
                                    {
                                        cat = _categoria
                                    }
                                    
                                    if let _animalId = object.objectForKey("animal_Id") as? String
                                    {
                                        animalid = _animalId
                                    }
                                    
                                    if let _descripcion = object.objectForKey("descripcion") as? String
                                    {
                                        desc = _descripcion
                                    }
                                    
                                    if let _precio1 = object.objectForKey("precio1") as? Double
                                    {
                                        precio1 = _precio1
                                    }
                                    
                                    if let _precio2 = object.objectForKey("precio2") as? Double
                                    {
                                        precio2 = _precio2
                                    }
                                    
                                    if let _precio3 = object.objectForKey("precio3") as? Double
                                    {
                                        precio3 = _precio3
                                    }
                                    
                                    if let _disp = object.objectForKey("disponible") as? Bool
                                    {
                                        disponible = _disp
                                    }
                                    
                                    if let _info = object.objectForKey("info") as? String
                                    {
                                        info = _info
                                    }
                                    
                                    if let _infoAmount = object.objectForKey("info_ammount") as? String{
                                        infoAmount = _infoAmount
                                    }
                                    
                                    let producto = Producto(
                                        _id: object.objectId!,
                                        _nombre: nom,
                                        pic: imagen,
                                        _categoria: cat,
                                        _animalId: animalid,
                                        _descripcion: desc,
                                        _precio1: precio1,
                                        _precio2: precio2,
                                        _precio3: precio3,
                                        _disponible: disponible,
                                        _info: info,
                                        _infoAmount: infoAmount)
                                    
                                    
                                    print("nombre = \(producto.nombre)")
                                    print("desciption = \(producto.descripcion)");
                                    print("funcionando = \(producto.disponible)");
                                    
                                    if(producto.disponible)
                                    {
                                        self.productos.append(producto);
                                        if(i == objects.count)
                                        {
                                            print("i = \(i) objects.count = \(objects.count)")
                                            self.updateProductsThatShouldShow()
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
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
