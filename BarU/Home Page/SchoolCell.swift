//
//  SchoolCell.swift
//  BarU
//
//  Created by Mitch Baumgartner on 7/6/21.
//

import UIKit

class SchoolCell: UITableViewCell {

    static let identifier = "SchoolCell"
    // school logo
    let schoolLogo: UIImageView = {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "hawkeye-logo"))
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        // circular picture
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
//        imageView.layer.borderColor = UIColor.matteBlack.cgColor
//        imageView.layer.borderWidth = 0.8
        return imageView
    }()
    
    // create custom label for bar name
    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "BAR NAME"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        //label.backgroundColor = .yellow
        return label
    }()
    
    // create custom label for school city and state
    let cityStateLabel: UILabel = {
        let label = UILabel()
        label.text = "City, State"
        //label.font = UIFont.boldSystemFont(ofSize: 16)
        label.font = UIFont.italicSystemFont(ofSize: 12)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        //label.backgroundColor = .green
        return label
    }()
    

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = UIColor.matteBlack
        // placement of the image in cell
        addSubview(schoolLogo)
        schoolLogo.heightAnchor.constraint(equalToConstant: 35).isActive = true
        schoolLogo.widthAnchor.constraint(equalToConstant: 35).isActive = true
        schoolLogo.leftAnchor.constraint(equalTo: leftAnchor, constant: 16).isActive = true
        schoolLogo.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        // placement of file name in cell
        addSubview(nameLabel)
        nameLabel.leftAnchor.constraint(equalTo: schoolLogo.rightAnchor, constant: 16).isActive = true
        nameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
        nameLabel.heightAnchor.constraint(equalToConstant: 26).isActive = true
        //nameLabel.widthAnchor.constraint(equalToConstant: 40).isActive = true
    
        // placement of file message in cell
        addSubview(cityStateLabel)
        cityStateLabel.leftAnchor.constraint(equalTo: schoolLogo.rightAnchor, constant: 20).isActive = true
        cityStateLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor).isActive = true
        //cityStateLabel.widthAnchor.constraint(equalToConstant: 90).isActive = true
        cityStateLabel.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        //messageLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -36).isActive = true
        
    
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


