//
//  SchesCell.swift
//  Vocaco
//
//  Created by 赵偲垚 on 2020/09/29.
//

import UIKit

class SchesCell: UITableViewCell {

    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var checkMark: UIImageView!
    @IBOutlet weak var word: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
