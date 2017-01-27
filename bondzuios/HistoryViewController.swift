//
//  HistoryViewController.swift
//  bondzuios
//
//  Created by Daniela Becerra on 13/04/16.
//  Copyright © 2016 Bondzu. All rights reserved.
//

import UIKit

/* 
"Bondzù es una aplicación que permitirá a las personas formar un lazo especial con animales del zoológico, sin importar donde se encuentren. A través de esta aplicación los usuarios podrán adoptar, cuidar y ver crecer a sus cachorros favoritos. Usando dispositivos robóticos y juguetes, participarán en el bienestar animal y enriquecimiento ambiental para mantenerlos activos e incluso darles de comer. ¿Se imaginan hacer correr y saltar un tigre blanco persiguiendo a su presa? ¿O jugar juegos de mesa contra una familia monos capuchinos? Las personas podrán aprender sobre el cuidado de los animales y ayudarán a los zoológicos en sus tareas cotidianas, incluso cuando están cerrados.  Bondzù también estará en la web y plataformas móviles, para que no te pierdas ni un momento con tu cachorro ... ni siquiera su nacimiento!"
*/

 /*
Bondzù is an app that will enable people and zoo animals to form a special bond no matter wherever they are. Through this app users will adopt, care and watch grow their favorite cubs. Using robotic devices and toys they will participate in animal well-being and environmental enrichment to keep them active and even feed them.

Can you imagine making run and jump a white tiger pursuing its prey? Or playing board games against a capuchin monkeys family?

People will learn about animal caring and help zoos in their everyday tasks even when they're closed. And Bondzù will be on web and mobile platforms so you won't miss a moment with your cub... not even its birth!



*/


class HistoryViewController: UIViewController {

    
    @IBOutlet weak var animalEffectView: EffectBackgroundView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var historyLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        animalEffectView.setImageArray(Constantes.animalArrayImages)
        scrollView.contentSize.height = 1100
        scrollView.contentSize.width = self.view.frame.width
        customizeLabel()
    }
    
    func customizeLabel(){
        let sampleText = NSLocalizedString("info", comment: "description of what bondzu is")
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.justified
        
        let attributedString = NSAttributedString(string: sampleText,
            attributes: [
                NSParagraphStyleAttributeName: paragraphStyle,
                NSBaselineOffsetAttributeName: NSNumber(value: 0 as Float)
            ])
        
        historyLabel.attributedText = attributedString
    
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.topItem?.title = NSLocalizedString("History", comment: "")
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    
}
