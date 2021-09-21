//
//  CrewCell.swift
//  BarU
//
//  Created by Mitch Baumgartner on 7/10/21.
//

import UIKit

class CrewCell: UITableViewCell {
    
    static let identifier = "CrewCell"
    // profile pic
    let profilePicImageView: UIImageView = {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "profile_pic_icon"))
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        // circular picture
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        imageView.layer.borderColor = UIColor.matteBlack.cgColor
        imageView.layer.borderWidth = 0.8
        return imageView
    }()
    
    // create custom label for bar name
    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Crew member name note found."
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        //label.backgroundColor = .yellow
        return label
    }()
    

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = UIColor.white
        // placement of the image in cell
        addSubview(profilePicImageView)
        profilePicImageView.heightAnchor.constraint(equalToConstant: 45).isActive = true
        profilePicImageView.widthAnchor.constraint(equalToConstant: 45).isActive = true
        profilePicImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 16).isActive = true
        profilePicImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        // placement of file name in cell
        addSubview(nameLabel)
        nameLabel.leftAnchor.constraint(equalTo: profilePicImageView.rightAnchor, constant: 16).isActive = true
        nameLabel.heightAnchor.constraint(equalToConstant: 26).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        //nameLabel.widthAnchor.constraint(equalToConstant: 40).isActive = true
    
        
    
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


