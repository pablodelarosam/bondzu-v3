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
    var segments = ["Comida", "Medicina", "Juguetes", "Regalos"];
    var navHairLine:UIImageView? = UIImageView()
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBAction func segmentedControlChanged(sender: UISegmentedControl) {
        self.selectedSegment = sender.selectedSegmentIndex
        updateProductsThatShouldShow()
    }
    
    
    
    override func viewDidAppear(animated: Bool) {
        self.navigationController?.navigationBar.topItem?.title = "Gifts"
        self.navigationController!.navigationBar.topItem!.rightBarButtonItem = nil
        //TEST
        self.animalId = "uoG4QimJN9";
        
        
        getProductsOfAnimalWith(id: self.animalId)
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
        self.navHairLine = Utiles.getHairLine(navigationBar: self.navigationController!.navigationBar)
        self.toolbar.barStyle = .Black
        self.toolbar.barTintColor = Constantes.COLOR_NARANJA_NAVBAR
        self.toolbar.tintColor = UIColor.whiteColor()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        Utiles.moveHairLine(appearing: true, navHairLine: self.navHairLine, toolbar: self.toolbar)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        Utiles.moveHairLine(appearing: false, navHairLine: self.navHairLine, toolbar: self.toolbar)
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
        var photoFinal = Imagenes.imageResize(image: producto.photo, sizeChange: size, scale: UIScreen.mainScreen().scale);
        cell.imageView.image = photoFinal
        Imagenes.redondeaVista(cell, radio: 1.5)
        cell.layer.borderColor = cell.backgroundColor?.CGColor
        cell.layer.borderWidth = 0.2
        return cell
    }
    
    func updateProductsThatShouldShow()
    {
        self.productsToShow.removeAll(keepCapacity: true)
        var selectedCategory = self.segments[self.selectedSegment];
        for product in productos
        {
            if product.categoria == selectedCategory
            {
                self.productsToShow.append(product)
            }
        }
        self.activityIndicator.stopAnimating()
        self.collectionView.reloadData()
    }
    
    func getProductsOfAnimalWith(#id: String)
    {
        var query = PFQuery(className: "Productos");
        query.whereKey("animalId", equalTo: id)
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]?, error: NSError?) -> Void in
            
            if error == nil {
                self.activityIndicator.startAnimating()
                // The find succeeded.
                println("Successfully retrieved \(objects!.count) products.")
                
                var imagen = UIImage();
                var i = 0;
                // Do something with the found objects
                self.productos.removeAll(keepCapacity: true)
                if let objects = objects as? [PFObject] {
                    for (i = 0; i < objects.count; i++)
                    {
                        println("i = \(i) objects.count = \(objects.count)")
                        var object = objects[i]
                        if let imageFile = object.objectForKey("photo") as? PFFile
                        {
                            let image = object.objectForKey("photo") as? PFFile
                            image!.getDataInBackgroundWithBlock {
                                (imageData: NSData?, error: NSError?) -> Void in
                                if error == nil {
                                    if let imageData = imageData {
                                        imagen = UIImage(data:imageData)!
                                    }
                                    
                                    var id = object.objectId
                                    
                                    println(object.objectId)
                                    var producto = Producto(
                                        _id: object.objectId!,
                                        _nombre: object.objectForKey("nombre") as! String,
                                        pic: imagen,
                                        _categoria: object.objectForKey("categoria") as! String,
                                        _animalId: object.objectForKey("animalId") as! String,
                                        _descripcion: object.objectForKey("descripcion") as! String,
                                        _precio1: object.objectForKey("precio1") as! Double,
                                        _precio2: object.objectForKey("precio2") as! Double,
                                        _precio3: object.objectForKey("precio3") as! Double,
                                        _disponible: object.objectForKey("disponible") as! Bool,
                                        _info: object.objectForKey("info") as! String,
                                        _infoAmount: object.objectForKey("info_ammount") as! String)
                                    
                                    
                                    println("nombre = \(producto.nombre)")
                                    println("desciption = \(producto.descripcion)");
                                    println("funcionando = \(producto.disponible)");
                                    
                                    if(producto.disponible)
                                    {
                                        self.productos.append(producto);
                                        if(i == objects.count)
                                        {
                                            println("i = \(i) objects.count = \(objects.count)")
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
                println("Error: \(error!) \(error!.userInfo!)")
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
