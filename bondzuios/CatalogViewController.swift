//
//  CatalogViewController.swift
//  bondzuios
//
//  Created by Luis Mariano Arobes on 12/08/15.
//  Copyright (c) 2015 Bondzu. All rights reserved.
//  Archivo Localizado

//TODO posible bug here. Searching may do a circle reference here.

import UIKit
import Parse

class CatalogViewController: UIViewController, UICollectionViewDelegate , UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchBarDelegate, CapsuleLoadingDelegate, AnimalV2LoadingProtocol{

    
    var user : Usuario!
    
    //NOTE: To avoid possible bugs the search bar appears in the place of the segment control. Therefore is impossible to change the view while searching.
    
    //MARK: Constants
    
    let animalsIndex = 0
    let videoIndex = 1
    
    ///Number of items per row. Possibly there will be a modification that takes landscape mode in mind or even different devices so this can become a computed variable.
    fileprivate var NUMBER_ITEMS_ROW: CGFloat{
        return 2
    }
    
    ///The image that appears when imageWithImage haven't finished processing
    fileprivate let initialThumbnail = UIImage()
    
    
    //MARK: Variables
    
    
    ///The animated bakground blur
    @IBOutlet weak var animalEffectView: EffectBackgroundView!

    ///The animals model
    var animalsToShow = [AnimalV2]()
    
    ///This is a helper variable that changes the search icon with the done item when neccesary. The done item is created in runtime wile search one is stored here. This reference is necesary as the other one is weak and if its removed from the view it will go to null.
    fileprivate var barButtonItem : UIBarButtonItem?
    
    /// This property hides the division between the toolbar and the nav bar
    fileprivate var navHairLine : UIImageView? = UIImageView()

    ///The filtered animals model
    var searchedAnimals = [AnimalV2]()
    
    ///The video capsules filtered model
    var searchedVideoCapsules = [Capsule]()
    
    ///A variable that tells if the selected item should be considered from the normal or the filtered array.
    fileprivate var searching = false
    
    
    ///The numbers of animals that havent loaded yet. When they're fully loaded the view changes showing the animals. Doing the loading in this manner ensures that the animals are shown in alphabetical order.
    var toLoadAnimals = 0
    
    ///The numbers of videos that havent loaded yet. When they're fully loaded the view changes showing the animals. Doing the loading in this manner ensures that the animals are shown in alphabetical order.
    var toLoadVideos = 0
    
    ///The video capsules model
    var videoCapsules = [Capsule]()
    
    ///Weak bar of the searching element
    @IBOutlet weak var searchBarButtonItem: UIBarButtonItem!

    //MARK: View Outlets

    ///Loading indicator while the animals are loading
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //the view that will contain sections 0 of segmented control (about us )
    @IBOutlet weak var secondaryView: UIView!
    
    //the view for specials segmented control section (index 3)
    @IBOutlet weak var specialsView: UIView!
    
    ///The view that displays the items in a collection view. This is both, the data sorce and the controller.
   
    @IBOutlet weak var collectionView: UICollectionView!
    
    ///Contant that is ment for future use with ads
    @IBOutlet weak var heightBanner: NSLayoutConstraint!
    
    ///The animals and videos searchbar
    @IBOutlet weak var searchBar: UISearchBar!
    
    ///The Animals/Video trigger
    @IBOutlet weak var segementedControl: UISegmentedControl!
    
    ///Place where the segmented control appears
    @IBOutlet weak var toolbar: UIToolbar!
    
    
    //image to be retrieved from the database for initial promotions
    var newImage: UIImage?
    
    var aboutUsSelected = false
    
    var loginCounter : Int?
    
    //MARK:Collection view delegate & data source
  
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if segementedControl.selectedSegmentIndex == self.animalsIndex{
            if toLoadAnimals == 0{
                if !activityIndicator.isHidden{
                    self.activityIndicator.stopAnimating()
                }
                return searching ? self.searchedAnimals.count : self.animalsToShow.count
            }
            else{
                if activityIndicator.isHidden{
                    self.activityIndicator.isHidden = false
                    self.activityIndicator.startAnimating()
                }
                return 0;
            }
            
        }
        else if segementedControl.selectedSegmentIndex == self.videoIndex{
            if toLoadVideos == 0{
                if !activityIndicator.isHidden{
                    self.activityIndicator.stopAnimating()
                }
                return searching ? self.searchedVideoCapsules.count : self.videoCapsules.count
            }
            else{
                if activityIndicator.isHidden{
                    self.activityIndicator.isHidden = false
                    self.activityIndicator.startAnimating()
                }
                return 0
            }
        }
        //for other options, collection view must be hidden, so this doesnt really matter
        else {
            if !activityIndicator.isHidden{
                self.activityIndicator.stopAnimating()
            }
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "animalCell", for: indexPath as IndexPath) as! AnimalCollectionViewCell
        cell.layer.shouldRasterize = true;
        cell.layer.rasterizationScale = UIScreen.main.scale;
        // cell.imageView.image = initialThumbnail
        
        cell.tab = segementedControl.selectedSegmentIndex
        cell.row = indexPath.row
        
        if segementedControl.selectedSegmentIndex == self.animalsIndex{
            let animal = searching ? self.searchedAnimals[indexPath.row] : self.animalsToShow[indexPath.row]
            cell.nameLabel.text = animal.name;
            cell.speciesLabel.text = animal.specie;
            let width = UIScreen.main.bounds.width
            let backgroundQueue = DispatchQueue.global(qos: .userInitiated)
            backgroundQueue.async {
                let photoFinal = imageWithImage(animal.image!, scaledToSize: CGSize(width: width / self.NUMBER_ITEMS_ROW, height:width / self.NUMBER_ITEMS_ROW))
                DispatchQueue.main.async() {
                    if cell.tab == self.segementedControl.selectedSegmentIndex && cell.row == indexPath.row{
                        cell.imageView.image = photoFinal
                    }
                }
            }
            

        }
        else if segementedControl.selectedSegmentIndex == self.videoIndex {
            print("Vide")
            let capsule = searching ? self.searchedVideoCapsules[indexPath.row] : self.videoCapsules[indexPath.row]
            print("Vide", capsule)
            cell.nameLabel.text = capsule.title[0]
            cell.speciesLabel.text = "" ; //capsule.videoDescription[0]; //capsule.animalName;
            let width = UIScreen.main.bounds.width
            DispatchQueue.global(qos: .userInitiated).async {
                let photoFinal = imageWithImage(capsule.image, scaledToSize: CGSize(width:width / self.NUMBER_ITEMS_ROW, height:width / self.NUMBER_ITEMS_ROW))
                DispatchQueue.main.async {
                    if cell.tab == self.segementedControl.selectedSegmentIndex && cell.row == indexPath.row{
                        cell.imageView.image = photoFinal
                    }
                }
            }
            if !capsule.hasLoadedPriority{
                cell.imageView.layer.borderColor = UIColor.white.cgColor
            }
            else{
                cell.imageView.layer.borderColor = capsule.requiredPriority!.color.cgColor
            }
        }
        print("OK")
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        if segementedControl.selectedSegmentIndex == 0{
            performSegue(withIdentifier: "catalogSegue", sender: searching ? self.searchedAnimals[indexPath.row] : self.animalsToShow[indexPath.row])
            searching = false
            searchBar.resignFirstResponder()
        }
        else if segementedControl.selectedSegmentIndex == self.videoIndex {
            performSegue(withIdentifier: "capsule", sender: searching ? self.searchedVideoCapsules[indexPath.row] : self.videoCapsules[indexPath.row])
            searching = false
            searchBar.resignFirstResponder()
        }
        //if segment index is another number, a collection view cell shouldnt be clicked, so this is ok
        
        //maybe I should set searching to false and searchbar resigned on an else block.....
        //!!!!!!!!!!!!!!!!!! note to Dany
    }
    
    //MARK: Video Capsule Delegate
    
    func capsuleDidFinishLoading(_ capsule: Capsule) {
        DispatchQueue.main.async{
            self.toLoadVideos -= 1
            print("To load videos: \(self.toLoadVideos)")
            if self.segementedControl.selectedSegmentIndex == self.videoIndex{
                print("Error")
                self.collectionView.reloadData()
            }
        }
    }
    
    func capsuleDidFailLoading(_ capsule: Capsule) {
        DispatchQueue.main.async{
            let index = self.videoCapsules.index(of: capsule)
            self.videoCapsules.remove(at: index!)
            self.toLoadVideos -= 1
            if self.segementedControl.selectedSegmentIndex == self.videoIndex{
                self.collectionView.reloadData()
            }
        }
    }

    func capsuleDidFailLoadingRequiredType(_ capsule: Capsule) {
        
        if toLoadVideos != 0{ return }
        
        if searching{
            if let index = searchedVideoCapsules.index(of: capsule){
                self.searchedVideoCapsules.remove(at: index)
                if segementedControl.selectedSegmentIndex == self.videoIndex {
                    self.collectionView.deleteItems(at: [IndexPath(item: index, section: 0)] )
                }
            }
            if let index = videoCapsules.index(of: capsule){
                videoCapsules.remove(at: index)
            }
        }
        else{
            if let index = videoCapsules.index(of: capsule){
                videoCapsules.remove(at: index)
                if segementedControl.selectedSegmentIndex == self.videoIndex{
                    self.collectionView.deleteItems(at: [IndexPath(item: index, section: 0)])
                }
            }
        }
    }
    
    func capsuleDidLoadRequiredType(_ capsule: Capsule) {
        
        if toLoadVideos != 0{ return }

        if segementedControl.selectedSegmentIndex == self.videoIndex{
            if searching{
                if let index = searchedVideoCapsules.index(of: capsule){
                    self.collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
                }
            }
            else{
                if let index = videoCapsules.index(of: capsule){
                    self.collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
                }
            }
        }
    }
    
    //MARK: Methods
    
    
    
    ///Performs the animal and video query. Note: The animalV2 filling should be migrated to the model
    func getAnimals(){
        
        
        let query = PFQuery(className:TableNames.Animal_table.rawValue)
        query.whereKeyExists(TableAnimalColumnNames.ID.rawValue);
        query.order(byAscending: TableAnimalColumnNames.Name.rawValue + NSLocalizedString(LOCALIZED_STRING, comment: ""));
        query.findObjectsInBackground {
            (objects: [PFObject]?, error: Error?) -> Void in
            if error == nil {
                self.animalsToShow.removeAll() //new for pull to refresh to not make duplicates
                if let objects = objects{
                    self.toLoadAnimals = objects.count
                    for object in objects {
                        let animal = AnimalV2(object: object, delegate: self);
                        self.animalsToShow.append(animal)
                    }
                    DispatchQueue.main.async{
                        if self.segementedControl.selectedSegmentIndex == self.animalsIndex {
                            self.collectionView.reloadData()
                            self.refreshControl.endRefreshing()
                        }
                    }
                }
            }
            else {
                print("Error: \(error!) \(error?.localizedDescription)")
            }
        }

        
        let videoQuery = PFQuery(className: TableNames.VideoCapsule_table.rawValue)
        videoQuery.whereKey("esCapsula", equalTo: true)
        videoQuery.order(byDescending: TableVideoCapsuleNames.Date.rawValue)
        videoQuery.findObjectsInBackground {
            (array, error) -> Void in
            if error == nil, let capsulesArray = array{
                self.videoCapsules.removeAll() //new for pull to refresh to not make duplicates
                self.toLoadVideos = capsulesArray.count
                
                for object in capsulesArray{
                    let c = Capsule(object: object, delegate: self)
                    self.videoCapsules.append(c)
                }
                
                if self.segementedControl.selectedSegmentIndex == self.videoIndex{
                    DispatchQueue.main.async{
                        self.collectionView.reloadData()
                        self.refreshControl.endRefreshing()
                    }
                }
            }
        }
        
        
    }
    
    ///Dissmises the keyboard
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard searchBar.text != nil else{ return }
        
        if searchBar.text?.characters.count == 0 {
            searching = false
            return
        }
        
        searching = true
        searchBar.resignFirstResponder()
    }
    
    ///Function that is called when the search bar text changes. It determines if the user is searching and returns the result data.
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        guard searchBar.text != nil && searchBar.text?.characters.count != 0 else{
            searching = false
            collectionView.reloadData()
            return
        }
        
        searching = true
        
        if segementedControl.selectedSegmentIndex == self.animalsIndex {
            searchedAnimals = animalsToShow.filter({ (element) -> Bool in
                let name = element.name.lowercased().range(of: searchBar.text!.lowercased())
                let species = element.specie.lowercased().range(of: searchBar.text!.lowercased())
                
                if name != nil || species != nil{
                    return true
                }
                return false
            })
        }
        else{
            searchedVideoCapsules = videoCapsules.filter({ (element) -> Bool in
                let title = element.title[0].lowercased().range(of: searchBar.text!.lowercased())
                let species = element.videoDescription[0].lowercased().range(of: searchBar.text!.lowercased())
                let animal = element.animalName.lowercased().range(of: searchBar.text!.lowercased())
                if title != nil || species != nil  || animal != nil{
                    return true
                }
                return false
            })
        }
        
        collectionView.reloadData()
    
    }
    
    ///Called when the search bar has to be either shown or dissmised
    @IBAction func searchButtonPressed(_ sender: AnyObject) {
        if !searchBar.isHidden{
            searching = false
            searchBar.resignFirstResponder()
            collectionView.reloadData()
            searchBar.isHidden = true
            navigationItem.rightBarButtonItem?.target = nil
            navigationItem.rightBarButtonItem?.action = nil
            if let bi = barButtonItem{
                self.navigationItem.rightBarButtonItem = bi
                barButtonItem = nil
            }
        }
        else{
            searchBar.isHidden = false
            searchBar.becomeFirstResponder()
            barButtonItem = self.navigationItem.rightBarButtonItem
            self.searchBar(searchBar, textDidChange: searchBar.text != nil ? searchBar.text! : "")
            let bbi = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(CatalogViewController.searchButtonPressed(_:)));
            navigationItem.rightBarButtonItem = bbi;
        }
    }

    ///This method is called when the user toggled between about us, animals, video and specials
    @IBAction func valueChanged(_ control : UISegmentedControl){
        
        switch control.selectedSegmentIndex
        {
        case 2:
            //self.navigationController!.navigationBar.topItem!.rightBarButtonItem = nil
            collectionView.isHidden = true
            secondaryView.isHidden = false
            specialsView.isHidden = true
        case 0:
            //self.navigationController!.navigationBar.topItem!.rightBarButtonItem = searchBarButtonItem
            collectionView.isHidden = false
            secondaryView.isHidden = true
            specialsView.isHidden = true
            collectionView.reloadData()
        case 1:
            //self.navigationController!.navigationBar.topItem!.rightBarButtonItem = searchBarButtonItem
            collectionView.isHidden = false
            secondaryView.isHidden = true
            specialsView.isHidden = true
            collectionView.reloadData()
        case 3:
            //self.navigationController!.navigationBar.topItem!.rightBarButtonItem = nil
            collectionView.isHidden = true
            secondaryView.isHidden = true
            specialsView.isHidden = false
        default:
            break;
        }

    }
    
    
    //MARK: View notifications
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.topItem?.title = NSLocalizedString("Home", comment: "")
        refreshUserColors()

    }
    
    
    //to change user type whenever the user has upgraded level, if not, just checking everytime we come back to the main view
    func refreshUserColors(){
    
        self.user = Usuario(object: PFUser.current()!, loadImage: true, imageLoaderObserver: nil, userTypeObserver: nil)
        self.user.refreshUserType()
        (self.navigationController! as! BondzuNavigationController).user = self.user

        if user.hasLoadedPriority{
            self.toolbar.barTintColor = user.type!.color
        }
        
        user.appendTypeLoadingObserver({
            [weak self]
            (_, type) -> (Bool) in
            
            if self == nil{ return false }
            
            if type != nil{
                self?.toolbar.barTintColor = type!.color
            }
            
            return true
            })

    }
    
    //at the beginning if the user is basic level type, he will get a screen with promotions of Bondzù's store
    //the promotions are displayed in an image, and that image is retrieved from the DB here.
    
    
    func getAdImage(){
        let queryy = PFQuery(className:"Publicidad")
        queryy.whereKeyExists("imagen")
        queryy.findObjectsInBackground {
            (objects: [PFObject]?, error: Error?) -> Void in
            if error == nil {
                if let objects = objects{
                    let firstObject = objects[0]
                    let file = firstObject["imagen"] as! PFFile
                    file.getDataInBackground() {
                        (imageData: Data?, error: Error?) -> Void in
                        if error == nil {
                            if let imageData = imageData {
                                self.newImage = UIImage(data: imageData)
                                self.setUpAds(self.newImage!)
                            }
                        }
                    }
                    
                }
            }
            else {
                print("Error: \(error!) error al buscar la imagen de publicidad")
            }
        }        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        Utiles.moveHairLine(false, navHairLine: self.navHairLine, toolbar: self.toolbar)
        if !searchBar.isHidden{
            searchButtonPressed(self)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("login counter \(loginCounter?.hashValue)")
        
        (self.navigationController! as! BondzuNavigationController).user = self.user
        
        self.animalEffectView.setImageArray(Constantes.animalArrayImages)
        
        self.heightBanner.constant = 0;
        self.navigationController?.navigationBar.barStyle = .black
        self.navigationController?.navigationBar.barTintColor = Constantes.COLOR_NARANJA_NAVBAR
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        
        let cellWidth = ( min(UIScreen.main.bounds.width , UIScreen.main.bounds.height) - 15 * NUMBER_ITEMS_ROW) / NUMBER_ITEMS_ROW
        let cellLayout = self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        cellLayout.itemSize = CGSize(width: cellWidth, height: cellWidth + 20)
        cellLayout.minimumInteritemSpacing = 5
        
        self.collectionView.backgroundView?.alpha = 0;
        
        
        self.navHairLine = Utiles.getHairLine(self.navigationController!.navigationBar)
        self.toolbar.barStyle = .black
        self.toolbar.barTintColor = Constantes.COLOR_NARANJA_NAVBAR
        
        if user.hasLoadedPriority{
            self.toolbar.barTintColor = user.type!.color
            if user.type!.priority == 0{
                getAdImage()
            }
        }
        
        user.appendTypeLoadingObserver({
            [weak self]
            (_, type) -> (Bool) in
            
            if self == nil{ return false }
            
            if type != nil{
                self?.toolbar.barTintColor = type!.color
                if type!.priority == 0 {
                    if let s = self{
                        s.getAdImage()
                    }
                }
            }
            
            return true
        })
      
        
        getAnimals();
       
        setUpSegmentedControl()

        //pull to refresh
        self.collectionView.addSubview(self.refreshControl)
                
        
    }
    
    
    //prepare and display the advertisement
    func setUpAds(_ image: UIImage){
        let firstPage = OnboardingContentViewController(title: "", body: "", image: nil, buttonText: "") { () -> Void in  }
        let onboardingVC: OnboardingViewController!
        onboardingVC = OnboardingViewController(backgroundImage: image, contents: [firstPage!])
    
        onboardingVC.allowSkipping = true
        onboardingVC.skipHandler = {() -> Void in
            onboardingVC.dismiss(animated: true, completion: nil)
            //counter ++
            self.loginCounter = self.loginCounter! + 1
        }
        onboardingVC.shouldMaskBackground = false
        onboardingVC.hidePageControl = true
        // if counter = 0
        if self.loginCounter == 0 {
            self.present(onboardingVC, animated: false, completion: nil)
        }
    }
    
    //pull to refresh
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(CatalogViewController.getAnimals), for: UIControlEvents.valueChanged)
        
        return refreshControl
    }()
    
    
    func setUpSegmentedControl(){
        self.segementedControl.selectedSegmentIndex = animalsIndex
        
        segementedControl.setTitle(NSLocalizedString("About us", comment:""), forSegmentAt: 2)
        segementedControl.setTitle(NSLocalizedString("Content", comment:""), forSegmentAt: 0)
        segementedControl.setTitle(NSLocalizedString("Video", comment:""), forSegmentAt: 1)
        segementedControl.setTitle(NSLocalizedString("Specials", comment:""), forSegmentAt: 3)
        
        collectionView.isHidden = false
        secondaryView.isHidden = true
        specialsView.isHidden = true
        
        self.segementedControl.tintColor = UIColor.white
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.hidesBackButton = true;
        Utiles.moveHairLine(true, navHairLine: self.navHairLine, toolbar: self.toolbar)
    }
    
    //MARK: Other controller stuff
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "catalogSegue"{
            let nextVC = segue.destination as! TabsViewController
            nextVC.animal = sender as! AnimalV2
            nextVC.user = self.user
            
        }
        else if segue.identifier == "capsule"{
            let nextVC = segue.destination as! VideoCapsulasViewController
            nextVC.capsule = sender as! Capsule
            nextVC.user = self.user
        }
        else if let nvc = segue.destination as? AccountViewController{
            nvc.user = self.user
        }

    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        let cellWidth = ( min(UIScreen.main.bounds.height, UIScreen.main.bounds.width) - 15 * NUMBER_ITEMS_ROW) / NUMBER_ITEMS_ROW
        let cellLayout = self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        cellLayout.itemSize = CGSize(width: cellWidth, height: cellWidth + 20)
        cellLayout.minimumInteritemSpacing = 5
    }
    
    
   //MARK: AnimalV2 Loading protocol
    
    func animalDidFailLoading(_ animal: AnimalV2) {
        
        self.animalsToShow.remove(at: self.animalsToShow.index(of: animal)!)
        print("no se pudo cargar animal \(animal.objectId)")
        self.toLoadAnimals -= 1
        
        if self.segementedControl.selectedSegmentIndex == self.animalsIndex {
            self.collectionView.reloadData()
        }
    }
    
    func animalDidFinishLoading(_ animal: AnimalV2) {
        self.toLoadAnimals -= 1
        print("To load animals: \(self.toLoadAnimals)")

        if self.segementedControl.selectedSegmentIndex == self.animalsIndex {
            self.collectionView.reloadData()
        }

    }
    
    func animalDidFinishLoadingPermissionType(_ animal: AnimalV2) {
        
        if toLoadAnimals != 0{ return }
        
        if segementedControl.selectedSegmentIndex == self.animalsIndex {
            if searching{
                if let index = searchedAnimals.index(of: animal){
                    self.collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
                }
            }
            else{
                if let index = animalsToShow.index(of: animal){
                    self.collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
                }
            }
        }
        
    }
    
    func animalDidFailedLoadingPermissionType(_ animal: AnimalV2) {
        
        if toLoadAnimals != 0{ return }
        
        if searching{
            if let index = searchedAnimals.index(of: animal){
                self.searchedAnimals.remove(at: index)
                if segementedControl.selectedSegmentIndex == self.animalsIndex {
                    self.collectionView.deleteItems(at: [IndexPath(item: index, section: 0)] )
                }
            }
            if let index = animalsToShow.index(of: animal){
                animalsToShow.remove(at: index)
            }
        }
        else{
            if let index = animalsToShow.index(of: animal){
                animalsToShow.remove(at: index)
                if segementedControl.selectedSegmentIndex == self.animalsIndex {
                    self.collectionView.deleteItems(at: [IndexPath(item: index, section: 0)])
                }
            }
        }
    }
}
