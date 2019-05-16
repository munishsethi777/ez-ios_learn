//
//  bottonView.swift
//  RightManagement
//
//  Created by Baljeet Gaheer on 08/02/18.
//  Copyright © 2018 Munish Sethi. All rights reserved.
//

class bottomView: UIView {
    
    let dashedBorder = CAShapeLayer()
    let gradient = CAGradientLayer()
    var gradientColor:[Any] = []
    override init(frame: CGRect) {
        super.init(frame: frame)
        //commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //commonInit()
    }
    
    func commonInit() {
        //custom initialization
        gradient.frame =  self.bounds
        gradient.colors = gradientColor
        let shape = CAShapeLayer()
        shape.lineWidth = 4
        shape.path =  UIBezierPath(rect: self.bounds).cgPath
        shape.strokeColor = UIColor.black.cgColor
        shape.fillColor = UIColor.clear.cgColor
        gradient.mask = shape
        self.layer.addSublayer(gradient)
    }
    
    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        let shape = gradient.mask as! CAShapeLayer
        shape.path = UIBezierPath(rect: self.bounds).cgPath
        gradient.mask = shape
        gradient.frame = self.bounds
    }
}
