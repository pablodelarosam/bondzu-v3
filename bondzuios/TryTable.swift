//
//  TryTable.swift
//  bondzuios
//
//  Created by Daniela Becerra on 17/04/16.
//  Copyright © 2016 Bondzu. All rights reserved.
//

import UIKit

class TryTable: UITableViewController {

    @IBOutlet var mytableview: UITableView!
    
    var nombres : [String]!
    
    var puestos: [String]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        puestos = ["Profesor guía, fundador de proyecto", "Ejecutivo de proyecto", "Desarrollador iOS", "Desarrolladora iOS", "Desarrollador Android", "Diseño gráfico", "Diseño gráfico", "Comunicación", "Documentacion", "Colaborador voluntario", "Colaborador voluntario", "Colaborador voluntario", "Colaborador voluntario"]
        
        nombres = ["Jorge Huerta González", "Isaac Martínez Perrusquía", "Ricardo Lopez Fósil", "Daniela Becerra González", "Guillermo Arturo Hernández", "Laura Elena Diaz Rojas", "Kimberly Zacarías Coapa", "Rosario Rodriguez Robles", "Erika Tellez Eliosa", "Gabriela López", "Daniel Martin Diaz Rojas", "Jerassi Ferrer Alonso", "Ivan Xolocotzi Hernández"]
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        let nib = UINib(nibName: "TeamMemberCellTableViewCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: "cell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return nombres.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! TeamMemberCellTableViewCell
        cell.teamName.text = nombres[indexPath.row]
        cell.teamRole.text = puestos[indexPath.row]


        return cell
    }
    

    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }
    

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
