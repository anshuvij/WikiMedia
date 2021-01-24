//
//  CustomCell.swift
//  BooksHandler
//
//  Created by Anshu Vij on 1/7/21.
//

import UIKit

class CustomCell: UITableViewCell {

   
    @IBOutlet weak var imageViewImage: CustomImageView!
    @IBOutlet weak var labelView: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.imageViewImage.layer.cornerRadius = self.imageViewImage.frame.size.width / 2
        self.imageViewImage.clipsToBounds  = true
        self.imageViewImage.layer.borderWidth = 0.5
        self.imageViewImage.layer.borderColor = UIColor.systemGray3.cgColor
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 2, left: 0, bottom: 2, right: 0))
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
