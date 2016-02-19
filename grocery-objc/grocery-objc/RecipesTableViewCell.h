//
//  RecipesTableViewCell.h
//  grocery-objc
//
//  Created by Shena Yoshida on 2/19/16.
//  Copyright © 2016 Shena Yoshida. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecipesTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *recipeLabel;
@property (strong, nonatomic) IBOutlet UIImageView *recipeImage;

@end
