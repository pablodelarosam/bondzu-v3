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
    
 //   var puestos: [String] = []
    
    var puestosEnIngles: [String] = []
    
    var roles: [String] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: "TeamMemberCellTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "cell")
        
//         puestos = ["Profesor guía, fundador de proyecto", "Ejecutivo de proyecto", "Desarrollador iOS", "Desarrolladora iOS", "Desarrollador Android", "Diseño gráfico", "Diseño gráfico", "Comunicación", "Documentación", "Colaborador voluntario", "Colaborador voluntario", "Colaborador voluntario", "Colaborador voluntario"]
        
        puestosEnIngles = ["Founder of the project", "Project executive", "iOS developer", "iOS developer", "Android developer", "Graphic design", "Graphic design", "Communication", "Documentation", "Volunteer colaborator", "Volunteer colaborator", "Volunteer colaborator", "Volunteer colaborator"]
        
         nombres = ["Jorge Huerta González", "Isaac Martínez Perrusquía", "Ricardo Lopez Fósil", "Daniela Becerra González", "Guillermo Arturo Hernández", "Laura Elena Diaz Rojas", "Kimberly Zacarías Coapa", "Rosario Rodriguez Robles", "Erika Tellez Eliosa", "Gabriela López", "Daniel Martin Diaz Rojas", "Jerassi Ferrer Alonso", "Ivan Xolocotzi Hernández"]
        
        for i in 0..<puestosEnIngles.count {
            roles.append(NSLocalizedString("\(puestosEnIngles[i])", comment: ""))
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let animalBackgroundView = EffectBackgroundView(frame : self.view.bounds)
        // Add a background view to the table view
        animalBackgroundView.setImageArray(Constantes.animalArrayImages)
        self.tableView.backgroundView = animalBackgroundView
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.topItem?.title = NSLocalizedString("Team", comment: "")
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        return nombres.count
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    override func tableView(_ tableView: UITableView,cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TeamMemberCellTableViewCell
        cell.teamName.text = nombres[indexPath.row]
        cell.teamRole.text = roles[indexPath.row]
        
        return cell
    }

}
