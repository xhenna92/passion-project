//
//  InventoryTableViewCell.h
//  grocery-objc
//
//  Created by Shena Yoshida on 2/18/16.
//  Copyright © 2016 Shena Yoshida. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InventoryTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *labelFood;
@property (weak, nonatomic) IBOutlet UILabel *labelDate;

@end
