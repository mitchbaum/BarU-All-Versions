//
//  BarCell.swift
//  BarU
//
//  Created by Mitch Baumgartner on 7/2/21.
//

import UIKit

class OrgCell: UITableViewCell {
    
    static let identifier = "OrgCell"
    
    // bar logo
    let orgImageView: UIImageView = {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "pints_icon"))
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        //imageView.backgroundColor = UIColor.logoRed
        // circular picture
        imageView.layer.cornerRadius = 30 // this value needs to be half the size of the height to make the image circular
        imageView.clipsToBounds = true
        imageView.layer.borderColor = UIColor.matteBlack.cgColor
        imageView.layer.borderWidth = 0.8
        return imageView
    }()
    
    // create custom label for bar name
    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "BAR NAME"
        //label.font = UIFont.boldSystemFont(ofSize: 26)
        label.font = UIFont(name: "Rokkitt-SemiBold", size: 30)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        //label.backgroundColor = .yellow
        return label
    }()
    
    
    // wait time image
    let waitTimeImageView: UIImageView = {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "wait_time_icon"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        // circular picture
        //imageView.layer.cornerRadius = 30 // this value needs to be half the size of the height to make the image circular
        imageView.clipsToBounds = true
//        imageView.layer.borderColor = UIColor.darkBlue.cgColor
//        imageView.layer.borderWidth = 0.8
        return imageView
    }()
    
    // create custom label for bar wait time
    let waitTimeMessage: UILabel = {
        let label = UILabel()
        label.text = "5 min"
        label.font = UIFont.italicSystemFont(ofSize: 16)
        //label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        //label.backgroundColor = .green
        return label
    }()
    
    // cover image
    let coverImageView: UIImageView = {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "cover_icon"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        // circular picture
        //imageView.layer.cornerRadius = 30 // this value needs to be half the size of the height to make the image circular
        imageView.clipsToBounds = true
//        imageView.layer.borderColor = UIColor.darkBlue.cgColor
//        imageView.layer.borderWidth = 0.8
        return imageView
    }()
    
    // create custom label for bar cover
    let coverMessage: UILabel = {
        let label = UILabel()
        label.text = "$10"
        label.font = UIFont.italicSystemFont(ofSize: 16)
        //label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        //label.backgroundColor = .green
        return label
    }()
    
    // poppin image icon
    let poppinImageView: UIImageView = {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "poppin_icon"))
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        // circular picture
        //imageView.layer.cornerRadius = 30 // this value needs to be half the size of the height to make the image circular
        imageView.clipsToBounds = true
//        imageView.layer.borderColor = UIColor.darkBlue.cgColor
//        imageView.layer.borderWidth = 0.8
        return imageView
    }()
    
    
    // create custom label for poppin cover
    let poppinMessage: UILabel = {
        let label = UILabel()
        label.text = "Yes"
        label.font = UIFont.italicSystemFont(ofSize: 16)
        //label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        //label.backgroundColor = .green
        return label
    }()
    
    // create custom label for updated label
    let updateLabel: UILabel = {
        let label = UILabel()
        label.text = "Updated 3 min ago"
        //label.font = UIFont.boldSystemFont(ofSize: 10)
        label.font = UIFont.italicSystemFont(ofSize: 12)
        label.textColor = .lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        //label.backgroundColor = .blue
        return label
    }()
    
    let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = .offWhite
        view.layer.cornerRadius = 15
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        // color of table view cell
        backgroundColor = UIColor.matteBlack
        
        addSubview(cardView)
        cardView.topAnchor.constraint(equalTo: topAnchor, constant: 5).isActive = true
        cardView.leftAnchor.constraint(equalTo: leftAnchor, constant: 8).isActive = true
        cardView.rightAnchor.constraint(equalTo: rightAnchor, constant: -8).isActive = true
        cardView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5).isActive = true
        
        
        // placement of the image in cell
        addSubview(orgImageView)
        orgImageView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        orgImageView.widthAnchor.constraint(equalToConstant: 60).isActive = true
        orgImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 16).isActive = true
        orgImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        // placement of file name in cell
        addSubview(nameLabel)
        nameLabel.leftAnchor.constraint(equalTo: orgImageView.rightAnchor, constant: 16).isActive = true
        nameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        //nameLabel.widthAnchor.constraint(equalToConstant: 40).isActive = true
    
        // placement of file message in cell
        addSubview(waitTimeImageView)
        waitTimeImageView.leftAnchor.constraint(equalTo: orgImageView.rightAnchor, constant: 16).isActive = true
        waitTimeImageView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8).isActive = true
        waitTimeImageView.heightAnchor.constraint(equalToConstant: 20).isActive = true
        waitTimeImageView.widthAnchor.constraint(equalToConstant: 20).isActive = true
        //waitTimeLabel.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        //messageLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -36).isActive = true
        
        // placement of file message in cell
        addSubview(waitTimeMessage)
        waitTimeMessage.leftAnchor.constraint(equalTo: waitTimeImageView.rightAnchor, constant: 5).isActive = true
        waitTimeMessage.topAnchor.constraint(equalTo: waitTimeImageView.topAnchor).isActive = true
        //waitTimeMessage.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        waitTimeMessage.bottomAnchor.constraint(equalTo: waitTimeImageView.bottomAnchor).isActive = true
        //messageLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -36).isActive = true

        
        // placement of file message in cell
        addSubview(coverImageView)
        coverImageView.leftAnchor.constraint(equalTo: waitTimeMessage.rightAnchor, constant: 8).isActive = true
        coverImageView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8).isActive = true
        coverImageView.heightAnchor.constraint(equalToConstant: 20).isActive = true
        coverImageView.widthAnchor.constraint(equalToConstant: 20).isActive = true
        //waitTimeLabel.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        //messageLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -36).isActive = true
        
        
        // placement of file message in cell
        addSubview(coverMessage)
        coverMessage.leftAnchor.constraint(equalTo: coverImageView.rightAnchor, constant: 5).isActive = true
        coverMessage.topAnchor.constraint(equalTo: coverImageView.topAnchor).isActive = true
        //waitTimeMessage.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        coverMessage.bottomAnchor.constraint(equalTo: coverImageView.bottomAnchor).isActive = true
        //messageLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -36).isActive = true
        
        // placement of file message in cell
        addSubview(poppinImageView)
        poppinImageView.leftAnchor.constraint(equalTo: coverMessage.rightAnchor, constant: 8).isActive = true
        poppinImageView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8).isActive = true
        poppinImageView.heightAnchor.constraint(equalToConstant: 20).isActive = true
        poppinImageView.widthAnchor.constraint(equalToConstant: 20).isActive = true
        //waitTimeLabel.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        //messageLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -36).isActive = true

        // placement of file message in cell
        addSubview(poppinMessage)
        poppinMessage.leftAnchor.constraint(equalTo: poppinImageView.rightAnchor, constant: 5).isActive = true
        poppinMessage.topAnchor.constraint(equalTo: poppinImageView.topAnchor).isActive = true
        //waitTimeMessage.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        poppinMessage.bottomAnchor.constraint(equalTo: poppinImageView.bottomAnchor).isActive = true
        //messageLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -36).isActive = true

        // placement of timestamp label in cell
        addSubview(updateLabel)
        updateLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -16).isActive = true
        updateLabel.topAnchor.constraint(equalTo: waitTimeImageView.bottomAnchor, constant: 8).isActive = true
        updateLabel.leftAnchor.constraint(equalTo: orgImageView.rightAnchor, constant: 16).isActive = true
        //closedLabel.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

        //timestampLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -16).isActive = true
        //timestampLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

