//
//  CustomTableViewCell.swift
//  Assesment_05
//
//  Created by  shawn on 13/01/2017.
//  Copyright © 2017 shawn. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {

    @IBOutlet weak var labelPhotoDescription: UILabel!
    @IBOutlet weak var labelPhotoFilename: UILabel!
    @IBOutlet weak var imageViewThumbnail: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
