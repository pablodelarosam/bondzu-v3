//
//  AdopedAnimalsViewController.swift
//  bondzuios
//
//  Created by Ricardo Lopez Focil on 9/29/15.
//  Copyright © 2015 Bondzu. All rights reserved.
//  Archivo Localizado

import UIKit
import Parse

class AdopedAnimalsViewController: UITableViewController, AnimalV2LoadingProtocol {

    
    var loaded = false
    var animals : [AnimalV2]!
    
    var user : Usuario!
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationItem.title = NSLocalizedString("Adopted Animals", comment: "")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let user = Usuario(object: PFUser.current()!, imageLoaderObserver: nil)
        
        Constantes.get_bondzu_queue().async{
            let (completed , animals) = user.getAdoptedAnimals(self)
            DispatchQueue.main.async{
                if completed{
                    self.animals = animals!
                }
                else{
                    self.animals = [AnimalV2]()
                    
                    let controller = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("Something went wront, please try again later", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
                    controller.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertActionStyle.cancel, handler: {
                        _ in
                    }))
                    self.present(controller, animated: true, completion: nil)
                    
                }
                self.loaded = true
                self.tableView.reloadData()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !loaded{
            return 1
        }
        return animals.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "watchAdoptedAnimal", sender: animals[indexPath.row])
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if !loaded{
            return tableView.dequeueReusableCell(withIdentifier: "Loading")!
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "content") as! AdoptedAnimalTableViewCell
        cell.animalImage.image = animals[indexPath.row].image
        cell.name.text = animals[indexPath.row].name
        cell.animalDescription.text = animals[indexPath.row].specie
        
        if let iv = cell.animalImage as? CircledImageView{

            if animals[indexPath.row].hasLoadedPermission{
                iv.setBorderOfColor(animals[indexPath.row].requiredPermission!.color, width: 3)
            }
            else{
                iv.setBorderOfColor(UIColor.white, width: 3)

                animals[indexPath.row].addObserverToRequiredType({
                    [weak self]
                    (animal) -> () in
                    
                    guard let s = self else{
                        return
                    }
                    
                    if animal.hasLoadedPermission{
                        tableView.cellForRow(at: IndexPath(item: s.animals.index(of: animal)!, section: 0))
                    }
                })
                
            }
        }
        
        
        
        return cell
    }
    
    
    //MARK: AnimalV2LoadingProtocol implementation
    
    /**
    This method is an empty implementation. In case of error nothing will happen
    
    - parameter animal: The animal that have failed loading
    */
    func animalDidFailLoading(_ animal: AnimalV2) {}
    
    
    /**
     This method reload the cell asocioated with the animal that has just loaded.
     Imlplementation of AnimalV2LoadingProtocol
     
     - parameter animal: The animal that has just loaded
     */
    func animalDidFinishLoading(_ animal: AnimalV2) {
        DispatchQueue.main.async{
            //Workaround. Sometimes the elements are cached so this method is called even before the array is returned. Anyway even if the method does not process the event after the array is loaded reload table is called and fixes all not set images.
            if self.animals != nil{
                let index = self.animals.index(of: animal)
                if let index = index{
                    self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let nextVC = segue.destination as? TabsViewController{
            nextVC.animal = sender as! AnimalV2
            nextVC.user = self.user
        }
    }
    
    
    //TODO: Empty implementation 
    func animalDidFailedLoadingPermissionType(_ animal: AnimalV2) {}
    
    func animalDidFinishLoadingPermissionType(_ animal: AnimalV2) {}
}

