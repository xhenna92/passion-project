//
//  FoodResult.h
//  grocery-objc
//
//  Created by Shena Yoshida on 2/17/16.
//  Copyright © 2016 Shena Yoshida. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FoodResult : NSObject

// for fridge inventory
@property (nonatomic) NSString *foodTitle;
@property (nonatomic) NSDate *foodExpirationDate;
@property (nonatomic) NSDate *foodDateAdded;

// for API results
@property (nonatomic) NSString *recipeName;
@property (nonatomic) NSString *recipeImage;
@property (nonatomic) NSString *recipeIngredients;
@property (nonatomic) NSString *recipeDescription;
@property (nonatomic) NSString *recipeDirections;

@end
