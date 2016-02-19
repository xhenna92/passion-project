//
//  foodModel.h
//  grocery-objc
//
//  Created by Henna Ahmed on 2/19/16.
//  Copyright © 2016 Shena Yoshida. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface foodModel : NSObject
{
    NSMutableArray *foodData;
}

@property (nonatomic, retain) NSMutableArray *foodData;

+ (id)sharedManager;

@end


