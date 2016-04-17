//
//  TeamViewController.swift
//  bondzuios
//
//  Created by Daniela Becerra on 13/04/16.
//  Copyright © 2016 Bondzu. All rights reserved.
//

import UIKit

class TeamViewController: UITableViewController {
    
    var nombres : [String] = []
    
    var puestos: [String] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: "TeamMemberCellTableViewCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: "cell")
        
         puestos = ["Profesor guía, fundador de proyecto", "Ejecutivo de proyecto", "Desarrollador iOS", "Desarrolladora iOS", "Desarrollador Android", "Diseño gráfico", "Diseño gráfico", "Comunicación", "Documentacion", "Colaborador voluntario", "Colaborador voluntario", "Colaborador voluntario", "Colaborador voluntario"]
        
         nombres = ["Jorge Huerta González", "Isaac Martínez Perrusquía", "Ricardo Lopez Fósil", "Daniela Becerra González", "Guillermo Arturo Hernández", "Laura Elena Diaz Rojas", "Kimberly Zacarías Coapa", "Rosario Rodriguez Robles", "Erika Tellez Eliosa", "Gabriela López", "Daniel Martin Diaz Rojas", "Jerassi Ferrer Alonso", "Ivan Xolocotzi Hernández"]
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let animalBackgroundView = EffectBackgroundView(frame : self.view.bounds)
        // Add a background view to the table view
        animalBackgroundView.setImageArray(Constantes.animalArrayImages)
        self.tableView.backgroundView = animalBackgroundView
    }
    
    override func viewDidAppear(animated: Bool) {
        self.navigationController?.navigationBar.topItem?.title = NSLocalizedString("Equipo", comment: "")
    }
    
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        return nombres.count
        
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
    }
    
    override func tableView(tableView: UITableView,cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! TeamMemberCellTableViewCell
        cell.teamName.text = nombres[indexPath.row]
        cell.teamRole.text = puestos[indexPath.row]
        
        return cell
    }

}
