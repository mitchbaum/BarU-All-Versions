//
//  OrgDetailsController.swift
//  BarU
//
//  Created by Mitch Baumgartner on 7/8/21.
//

import UIKit
import FirebaseAuth
import Firebase


class OrgDetailsController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        navigationItem.title = "Org Details"
        
        view.backgroundColor = UIColor.white

        setupUI()
    }
    
    // equation line
    let line: UILabel = {
        let line = UILabel()
        line.backgroundColor = UIColor.black
        // enable autolayout
        line.translatesAutoresizingMaskIntoConstraints = false
    
        return line
    }()
    
    // equation line
    let line2: UILabel = {
        let line = UILabel()
        line.backgroundColor = UIColor.black
        // enable autolayout
        line.translatesAutoresizingMaskIntoConstraints = false
    
        return line
    }()
    
    // equation line
    let line3: UILabel = {
        let line = UILabel()
        line.backgroundColor = UIColor.black
        // enable autolayout
        line.translatesAutoresizingMaskIntoConstraints = false
    
        return line
    }()
    
    // equation line
    let line4: UILabel = {
        let line = UILabel()
        line.backgroundColor = UIColor.black
        // enable autolayout
        line.translatesAutoresizingMaskIntoConstraints = false
    
        return line
    }()
    
    // equation line
    let line5: UILabel = {
        let line = UILabel()
        line.backgroundColor = UIColor.black
        // enable autolayout
        line.translatesAutoresizingMaskIntoConstraints = false
    
        return line
    }()
    
    // equation line
    let line6: UILabel = {
        let line = UILabel()
        line.backgroundColor = UIColor.black
        // enable autolayout
        line.translatesAutoresizingMaskIntoConstraints = false
    
        return line
    }()
    

    
    // create image picker option profile picture
    // lazy var enables self to be something other than nil, so that handleSelectPhoto actually works
    lazy var orgImageView: UIImageView = {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "pints_icon"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        // alters the squashed look to make the image appear normal in the view, fixes aspect ratio
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 50
        imageView.layer.borderColor = UIColor.matteBlack.cgColor
        imageView.layer.borderWidth = 0.8
        return imageView
        
    }()

    // create org name label
    let orgNameLabel: UILabel = {
        let label = UILabel()
        label.text = "Error"
        label.font = UIFont(name: "Rokkitt-SemiBold", size: 30)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        
        label.textColor = .black
        // enable autolayout
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    // create established label
    let establishedLabel: UILabel = {
        let label = UILabel()
        label.text = "Est."
        label.font = UIFont.italicSystemFont(ofSize: 12)
        label.textColor = .darkGray
        // enable autolayout
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    // create slogan label
    let sloganLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.italicSystemFont(ofSize: 18)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        // enable autolayout
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    // create custom label for updated label
    let updateLabel: UILabel = {
        let label = UILabel()
        label.text = "Updated"
        //label.font = UIFont.boldSystemFont(ofSize: 10)
        label.font = UIFont.italicSystemFont(ofSize: 12)
        label.textColor = .lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        //label.backgroundColor = .blue
        return label
    }()
    
    // create fast facts label
    let fastFactsLabel: UILabel = {
        let label = PaddingLabel(withInsets: 6,6,16,0) // padding up, down, left, right
        //let label = UILabel()
        let attributedString = NSMutableAttributedString.init(string: "Fast Facts")
        // Add Underline Style Attribute.
//        attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: 1, range:
//            NSRange.init(location: 0, length: attributedString.length));
        label.attributedText = attributedString
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .white
        label.backgroundColor = .logoRed
        //label.padding = UIEdgeInsets(top: 20, left: 32, bottom: 60, right: 80)
        // enable autolayout
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    // create cover label
    let coverLabel: UILabel = {
        let label = UILabel()
        label.text = "Tonight's Cover"
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 18)
        // enable autolayout
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // create cover label
    let coverMessage: UILabel = {
        let label = UILabel()
        label.text = " "
        label.textColor = .black
        // enable autolayout
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
   
    
    // create wait time label
    let waitTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "Current Wait Time"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .black
        // enable autolayout
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    
    // create wait time label
    let waitTimeMessage: UILabel = {
        let label = UILabel()
        label.text = " "
        label.textColor = .black
        // enable autolayout
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    
    // create at capacity label
    let atCapacityLabel: UILabel = {
        let label = UILabel()
        label.text = "At Capacity?"
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 18)
        // enable autolayout
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // create at capacity label
    let atCapacityMessage: UILabel = {
        let label = UILabel()
        label.text = " "
        label.textColor = .black
        // enable autolayout
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // create is it poppin label
    let poppinLabel: UILabel = {
        let label = UILabel()
        label.text = "Is it Poppin'?"
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 18)
        // enable autolayout
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // create is it poppin label message
    let poppinMessage: UILabel = {
        let label = UILabel()
        label.text = " "
        label.textColor = .black
        // enable autolayout
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // create drink specials label
    let drinkSpecialsLabel: UILabel = {
        let label = PaddingLabel(withInsets: 6,6,16,0) // padding up, down, left, right
        //let label = UILabel()
        let attributedString = NSMutableAttributedString.init(string: "Drink Specials")
        // Add Underline Style Attribute.
//        attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: 1, range:
//            NSRange.init(location: 0, length: attributedString.length));
        label.attributedText = attributedString
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .white
        label.backgroundColor = .logoRed
        //label.padding = UIEdgeInsets(top: 20, left: 32, bottom: 60, right: 80)
        // enable autolayout
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
//    let redBackgroundColor: UILabel = {
//        let label = UILabel()
//        label.backgroundColor = .logoRed
//        // enable autolayout
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
//    
    // create sunday specials
    let sundayLabel: UILabel = {
        let label = UILabel()
        label.text = "Sunday"
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 18)
        // enable autolayout
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // create sunday specials message
    let sundayMessage: UILabel = {
        let label = UILabel()
        label.text = " "
        label.textAlignment = .right
        label.textColor = .black
        label.font = UIFont.italicSystemFont(ofSize: 18)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        // enable autolayout
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    // create monday specials
    let mondayLabel: UILabel = {
        let label = UILabel()
        label.text = "Monday"
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 18)
        // enable autolayout
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // create monday specials message
    let mondayMessage: UILabel = {
        let label = UILabel()
        label.text = " "
        label.textAlignment = .right
        label.textColor = .black
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.font = UIFont.italicSystemFont(ofSize: 18)
        // enable autolayout
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // create tueday specials
    let tuesdayLabel: UILabel = {
        let label = UILabel()
        label.text = "Tueday"
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 18)
        // enable autolayout
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // create tuesday specials message
    let tuesdayMessage: UILabel = {
        let label = UILabel()
        label.text = " "
        label.textAlignment = .right
        label.textColor = .black
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.font = UIFont.italicSystemFont(ofSize: 18)
        // enable autolayout
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // create wednesday specials
    let wednesdayLabel: UILabel = {
        let label = UILabel()
        label.text = "Wednesday"
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 18)
        // enable autolayout
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // create wednesday specials message
    let wednesdayMessage: UILabel = {
        let label = UILabel()
        label.text = " "
        label.textAlignment = .right
        label.textColor = .black
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.font = UIFont.italicSystemFont(ofSize: 18)
        
        // enable autolayout
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // create thursday specials
    let thursdayLabel: UILabel = {
        let label = UILabel()
        label.text = "Thursday"
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 18)
        // enable autolayout
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // create thursday specials message
    let thursdayMessage: UILabel = {
        let label = UILabel()
        label.text = " "
        label.textAlignment = .right
        label.textColor = .black
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.font = UIFont.italicSystemFont(ofSize: 18)
        // enable autolayout
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // create friday specials
    let fridayLabel: UILabel = {
        let label = UILabel()
        label.text = "Friday"
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 18)
        // enable autolayout
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // create friday specials message
    let fridayMessage: UILabel = {
        let label = UILabel()
        label.text = " "
        label.textAlignment = .right
        label.textColor = .black
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.font = UIFont.italicSystemFont(ofSize: 18)
        // enable autolayout
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // create saturday specials
    let saturdayLabel: UILabel = {
        let label = UILabel()
        label.text = "Saturday"
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 18)
        // enable autolayout
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // create saturday specials message
    let saturdayMessage: UILabel = {
        let label = UILabel()
        label.text = " "
        label.textAlignment = .right
        label.textColor = .black
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.font = UIFont.italicSystemFont(ofSize: 18)
        
        // enable autolayout
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // create drink specials label
    let announcementsLabel: UILabel = {
        let label = PaddingLabel(withInsets: 6,6,16,0)
        let attributedString = NSMutableAttributedString.init(string: "Announcements")
        // Add Underline Style Attribute.
//        attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: 1, range:
//            NSRange.init(location: 0, length: attributedString.length));
        label.attributedText = attributedString
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .white
        label.backgroundColor = .logoRed
        // enable autolayout
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // create text field for announcements
    let announcementsMessage: UILabel = {
        let label = UILabel()
        label.text = " "
        label.textColor = .black
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.font = UIFont.italicSystemFont(ofSize: 18)
        // enable autolayout, without this constraints wont load properly
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // add scroll to view controller
    let scrollView : UIScrollView = {
        let view = UIScrollView()
        //view.frame = self.view.bounds
        //view.contentInsetAdjustmentBehavior = .never
        view.translatesAutoresizingMaskIntoConstraints = false
        //view.contentSize = contentViewSize
        view.backgroundColor = .white
        return view
    }()
    
    let containerView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        //view.frame.size = contentViewSize
        view.backgroundColor = .white
        return view
    }()
    
    let barInfoBackgroundColorView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .blue
        return view
    }()
    
    // all code to add any layout UI elements
    private func setupUI() {
        self.view.addSubview(scrollView)
        scrollView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        scrollView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        self.scrollView.addSubview(containerView)
        containerView.leftAnchor.constraint(equalTo: scrollView.leftAnchor).isActive = true
        containerView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        containerView.rightAnchor.constraint(equalTo: scrollView.rightAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        
//        self.view.addSubview(barInfoBackgroundColorView)
//        barInfoBackgroundColorView.leftAnchor.constraint(equalTo: scrollView.leftAnchor).isActive = true
//        barInfoBackgroundColorView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
//        barInfoBackgroundColorView.rightAnchor.constraint(equalTo: scrollView.rightAnchor).isActive = true
//        barInfoBackgroundColorView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true


        print("self.view.frame.height = ", self.view.frame.height)
        print("self.containerView.frame.height = ", self.containerView.frame.height)
        print("self.scrollView.frame.height = ", self.scrollView.frame.height)

        //add image picker view
        containerView.addSubview(orgImageView)
        // gives padding of image from top
        orgImageView.topAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        orgImageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        //orgImageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor, constant: -100).isActive = true
        orgImageView.leftAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.leftAnchor, constant: 16).isActive = true
        orgImageView.widthAnchor.constraint(equalToConstant: 100).isActive = true

        // add and position name label
        containerView.addSubview(orgNameLabel)
        orgNameLabel.topAnchor.constraint(equalTo: orgImageView.topAnchor).isActive = true
        // move label to the right a bit
        orgNameLabel.leftAnchor.constraint(equalTo: orgImageView.rightAnchor, constant: 32).isActive = true

        //orgNameLabel.widthAnchor.constraint(equalToConstant: 150).isActive = true
        orgNameLabel.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -16).isActive = true
        //orgNameLabel.heightAnchor.constraint(equalToConstant: 35).isActive = true


        // add and position last name label
        containerView.addSubview(establishedLabel)
        establishedLabel.topAnchor.constraint(equalTo: orgNameLabel.bottomAnchor).isActive = true
        // move label to the right a bit
        establishedLabel.leftAnchor.constraint(equalTo: orgImageView.rightAnchor, constant: 40).isActive = true

        establishedLabel.widthAnchor.constraint(equalToConstant: 150).isActive = true
        //nameLabel.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        establishedLabel.heightAnchor.constraint(equalToConstant: 15).isActive = true


        // add and position coc label
        containerView.addSubview(sloganLabel)
        sloganLabel.topAnchor.constraint(equalTo: establishedLabel.bottomAnchor, constant: 8).isActive = true
        // move label to the right a bit
        sloganLabel.leftAnchor.constraint(equalTo: orgImageView.rightAnchor, constant: 32).isActive = true
        sloganLabel.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -16).isActive = true
        //sloganLabel.heightAnchor.constraint(equalToConstant: 25).isActive = true

        // add and position coc label
        containerView.addSubview(updateLabel)
        updateLabel.topAnchor.constraint(equalTo: sloganLabel.bottomAnchor).isActive = true
        // move label to the right a bit
        updateLabel.leftAnchor.constraint(equalTo: orgImageView.rightAnchor, constant: 32).isActive = true
        updateLabel.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        updateLabel.heightAnchor.constraint(equalToConstant: 25).isActive = true
        
        // add and position deductible label
        containerView.addSubview(fastFactsLabel)
        fastFactsLabel.topAnchor.constraint(equalTo: updateLabel.bottomAnchor, constant: 10).isActive = true
        // move label to the right a bit
        fastFactsLabel.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        //drinkSpecialsLabel.widthAnchor.constraint(equalToConstant: 150).isActive = true
        fastFactsLabel.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true


        // add and position invoice label
        containerView.addSubview(coverLabel)
        coverLabel.topAnchor.constraint(equalTo: fastFactsLabel.bottomAnchor, constant: 10).isActive = true
        // move label to the right a bit
        coverLabel.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 16).isActive = true
        coverLabel.widthAnchor.constraint(equalToConstant: 150).isActive = true
        //nameLabel.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        coverLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true

        // add and position deductible textfield element to the right of the nameLabel
        containerView.addSubview(coverMessage)
        //coverMessage.leftAnchor.constraint(equalTo: coverLabel.rightAnchor, constant: 5).isActive = true
        coverMessage.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -16).isActive = true
        coverMessage.bottomAnchor.constraint(equalTo: coverLabel.bottomAnchor).isActive = true
        coverMessage.topAnchor.constraint(equalTo: coverLabel.topAnchor).isActive = true



        // add and position deductible label
        containerView.addSubview(waitTimeLabel)
        waitTimeLabel.topAnchor.constraint(equalTo: coverLabel.bottomAnchor).isActive = true
        // move label to the right a bit
        waitTimeLabel.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 16).isActive = true
        //waitTimeLabel.widthAnchor.constraint(equalToConstant: 150).isActive = true
        //nameLabel.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        waitTimeLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true

        // add and position deductible textfield element to the right of the nameLabel
        containerView.addSubview(waitTimeMessage)
        //waitTimeMessage.leftAnchor.constraint(equalTo: waitTimeLabel.rightAnchor, constant: 5).isActive = true
        waitTimeMessage.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -16).isActive = true
        waitTimeMessage.bottomAnchor.constraint(equalTo: waitTimeLabel.bottomAnchor).isActive = true
        waitTimeMessage.topAnchor.constraint(equalTo: waitTimeLabel.topAnchor).isActive = true
        // to fill entire view
        //nameLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

        // add and position school selector label
        containerView.addSubview(atCapacityLabel)
        atCapacityLabel.topAnchor.constraint(equalTo: waitTimeLabel.bottomAnchor).isActive = true
        // move label to the right a bit
        atCapacityLabel.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 16).isActive = true
        atCapacityLabel.widthAnchor.constraint(equalToConstant: 150).isActive = true
        //nameLabel.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        atCapacityLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true

        // add and position deductible textfield element to the right of the nameLabel
        containerView.addSubview(atCapacityMessage)
        //atCapacityMessage.leftAnchor.constraint(equalTo: atCapacityLabel.rightAnchor, constant: 5).isActive = true
        atCapacityMessage.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -16).isActive = true
        atCapacityMessage.bottomAnchor.constraint(equalTo: atCapacityLabel.bottomAnchor).isActive = true
        atCapacityMessage.topAnchor.constraint(equalTo: atCapacityLabel.topAnchor).isActive = true

        // add and position deductible label
        containerView.addSubview(poppinLabel)
        poppinLabel.topAnchor.constraint(equalTo: atCapacityLabel.bottomAnchor).isActive = true
        // move label to the right a bit
        poppinLabel.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 16).isActive = true
        poppinLabel.widthAnchor.constraint(equalToConstant: 150).isActive = true
        //nameLabel.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        poppinLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true

        // add poppin switch
        containerView.addSubview(poppinMessage)
        //poppinMessage.leftAnchor.constraint(equalTo: poppinLabel.rightAnchor, constant: 5).isActive = true
        poppinMessage.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -16).isActive = true
        poppinMessage.bottomAnchor.constraint(equalTo: poppinLabel.bottomAnchor).isActive = true
        poppinMessage.topAnchor.constraint(equalTo: poppinLabel.topAnchor).isActive = true

        // add and position deductible label
        containerView.addSubview(drinkSpecialsLabel)
        drinkSpecialsLabel.topAnchor.constraint(equalTo: poppinLabel.bottomAnchor, constant: 10).isActive = true
        // move label to the right a bit
        drinkSpecialsLabel.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        //drinkSpecialsLabel.widthAnchor.constraint(equalToConstant: 150).isActive = true
        drinkSpecialsLabel.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        
//        containerView.addSubview(redBackgroundColor)
//        redBackgroundColor.topAnchor.constraint(equalTo: drinkSpecialsLabel.topAnchor).isActive = true
//        // move label to the right a bit
//        redBackgroundColor.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
//        redBackgroundColor.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        

        // add and position deductible label
        containerView.addSubview(sundayLabel)
        sundayLabel.topAnchor.constraint(equalTo: drinkSpecialsLabel.bottomAnchor, constant: 10).isActive = true
        // move label to the right a bit
        sundayLabel.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 16).isActive = true
        sundayLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        //nameLabel.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true

        // add poppin switch
        containerView.addSubview(sundayMessage)
        sundayMessage.leftAnchor.constraint(equalTo: sundayLabel.rightAnchor, constant: 10).isActive = true
        sundayMessage.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -16).isActive = true
        //sundayMessage.bottomAnchor.constraint(equalTo: sundayLabel.bottomAnchor).isActive = true
        sundayMessage.topAnchor.constraint(equalTo: sundayLabel.topAnchor).isActive = true
        //sundayMessage.widthAnchor.constraint(equalToConstant: 100).isActive = true
        
        containerView.addSubview(line)
        line.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -16).isActive = true
        line.topAnchor.constraint(equalTo: sundayMessage.bottomAnchor, constant: 10).isActive = true
        line.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        line.leftAnchor.constraint(equalTo: sundayLabel.leftAnchor).isActive = true

        

        // add and position deductible label
        containerView.addSubview(mondayLabel)
        mondayLabel.topAnchor.constraint(equalTo: line.bottomAnchor, constant: 10).isActive = true
        // move label to the right a bit
        mondayLabel.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 16).isActive = true
        mondayLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        //nameLabel.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true

        // add poppin switch
        containerView.addSubview(mondayMessage)
        mondayMessage.leftAnchor.constraint(equalTo: mondayLabel.rightAnchor, constant: 10).isActive = true
        mondayMessage.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -16).isActive = true
        //mondayMessage.bottomAnchor.constraint(equalTo: mondayLabel.bottomAnchor).isActive = true
        mondayMessage.topAnchor.constraint(equalTo: mondayLabel.topAnchor).isActive = true
        
        containerView.addSubview(line2)
        line2.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -16).isActive = true
        line2.topAnchor.constraint(equalTo: mondayMessage.bottomAnchor, constant: 10).isActive = true
        line2.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        line2.leftAnchor.constraint(equalTo: mondayLabel.leftAnchor).isActive = true

        // add and position deductible label
        containerView.addSubview(tuesdayLabel)
        tuesdayLabel.topAnchor.constraint(equalTo: line2.bottomAnchor, constant: 10).isActive = true
        // move label to the right a bit
        tuesdayLabel.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 16).isActive = true
        tuesdayLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        //nameLabel.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true

        // add poppin switch
        containerView.addSubview(tuesdayMessage)
        tuesdayMessage.leftAnchor.constraint(equalTo: tuesdayLabel.rightAnchor, constant: 10).isActive = true
        tuesdayMessage.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -16).isActive = true
        //tuesdayMessage.bottomAnchor.constraint(equalTo: tuesdayLabel.bottomAnchor).isActive = true
        tuesdayMessage.topAnchor.constraint(equalTo: tuesdayLabel.topAnchor).isActive = true
        
        containerView.addSubview(line3)
        line3.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -16).isActive = true
        line3.topAnchor.constraint(equalTo: tuesdayMessage.bottomAnchor, constant: 10).isActive = true
        line3.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        line3.leftAnchor.constraint(equalTo: tuesdayLabel.leftAnchor).isActive = true

        // add and position deductible label
        containerView.addSubview(wednesdayLabel)
        wednesdayLabel.topAnchor.constraint(equalTo: line3.bottomAnchor, constant: 10).isActive = true
        // move label to the right a bit
        wednesdayLabel.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 16).isActive = true
        wednesdayLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        //nameLabel.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true

        // add poppin switch
        containerView.addSubview(wednesdayMessage)
        wednesdayMessage.leftAnchor.constraint(equalTo: wednesdayLabel.rightAnchor, constant: 10).isActive = true
        wednesdayMessage.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -16).isActive = true
        //wednesdayMessage.bottomAnchor.constraint(equalTo: wednesdayLabel.bottomAnchor).isActive = true
        wednesdayMessage.topAnchor.constraint(equalTo: wednesdayLabel.topAnchor).isActive = true
        
        containerView.addSubview(line4)
        line4.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -16).isActive = true
        line4.topAnchor.constraint(equalTo: wednesdayMessage.bottomAnchor, constant: 10).isActive = true
        line4.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        line4.leftAnchor.constraint(equalTo: wednesdayLabel.leftAnchor).isActive = true

        // add and position deductible label
        containerView.addSubview(thursdayLabel)
        thursdayLabel.topAnchor.constraint(equalTo: line4.bottomAnchor, constant: 10).isActive = true
        // move label to the right a bit
        thursdayLabel.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 16).isActive = true
        thursdayLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        //nameLabel.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true

        // add poppin switch
        containerView.addSubview(thursdayMessage)
        thursdayMessage.leftAnchor.constraint(equalTo: thursdayLabel.rightAnchor, constant: 10).isActive = true
        thursdayMessage.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -16).isActive = true
        //thursdayMessage.bottomAnchor.constraint(equalTo: thursdayLabel.bottomAnchor).isActive = true
        thursdayMessage.topAnchor.constraint(equalTo: thursdayLabel.topAnchor).isActive = true
        
        containerView.addSubview(line5)
        line5.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -16).isActive = true
        line5.topAnchor.constraint(equalTo: thursdayMessage.bottomAnchor, constant: 10).isActive = true
        line5.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        line5.leftAnchor.constraint(equalTo: thursdayLabel.leftAnchor).isActive = true

        // add and position deductible label
        containerView.addSubview(fridayLabel)
        fridayLabel.topAnchor.constraint(equalTo: line5.bottomAnchor, constant: 10).isActive = true
        // move label to the right a bit
        fridayLabel.leftAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.leftAnchor, constant: 16).isActive = true
        fridayLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        //nameLabel.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true

        // add poppin switch
        containerView.addSubview(fridayMessage)
        fridayMessage.leftAnchor.constraint(equalTo: fridayLabel.rightAnchor, constant: 10).isActive = true
        fridayMessage.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -16).isActive = true
        //fridayMessage.bottomAnchor.constraint(equalTo: fridayLabel.bottomAnchor).isActive = true
        fridayMessage.topAnchor.constraint(equalTo: fridayLabel.topAnchor).isActive = true
        
        containerView.addSubview(line6)
        line6.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -16).isActive = true
        line6.topAnchor.constraint(equalTo: fridayMessage.bottomAnchor, constant: 10).isActive = true
        line6.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        line6.leftAnchor.constraint(equalTo: fridayLabel.leftAnchor).isActive = true

        // add and position deductible label
        containerView.addSubview(saturdayLabel)
        saturdayLabel.topAnchor.constraint(equalTo: line6.bottomAnchor, constant: 10).isActive = true
        // move label to the right a bit
        saturdayLabel.leftAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.leftAnchor, constant: 16).isActive = true
        saturdayLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        //nameLabel.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true

        // add poppin switch
        containerView.addSubview(saturdayMessage)
        saturdayMessage.leftAnchor.constraint(equalTo: saturdayLabel.rightAnchor, constant: 10).isActive = true
        saturdayMessage.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -16).isActive = true
        //saturdayMessage.bottomAnchor.constraint(equalTo: saturdayLabel.bottomAnchor).isActive = true
        saturdayMessage.topAnchor.constraint(equalTo: saturdayLabel.topAnchor).isActive = true

        // add and position deductible label
        containerView.addSubview(announcementsLabel)
        announcementsLabel.topAnchor.constraint(equalTo: saturdayMessage.bottomAnchor, constant: 10).isActive = true
        // move label to the right a bit
        announcementsLabel.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        //announcementsLabel.widthAnchor.constraint(equalToConstant: 150).isActive = true
        announcementsLabel.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true

        // add poppin switch
        containerView.addSubview(announcementsMessage)
        announcementsMessage.topAnchor.constraint(equalTo: announcementsLabel.bottomAnchor, constant: 10).isActive = true
        // move label to the right a bit
        announcementsMessage.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 16).isActive = true
        announcementsMessage.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -16).isActive = true
        //announcementsTextField.heightAnchor.constraint(equalToConstant: 100).isActive = true
        announcementsMessage.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16.0).isActive = true
        //containerView.bottomAnchor.constraint(equalTo: announcementsMessage.bottomAnchor, constant: -16).isActive = true
////
        
        
        // to fill entire view
        //nameLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        
//        // add and position datepicker element
//        view.addSubview(datePicker)
//        datePicker.topAnchor.constraint(equalTo: deductibleLabel.bottomAnchor).isActive = true
//        datePicker.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
//        datePicker.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
//        datePicker.bottomAnchor.constraint(equalTo: lightBlueBackgroundView.bottomAnchor).isActive = true
        
    }
    
}
