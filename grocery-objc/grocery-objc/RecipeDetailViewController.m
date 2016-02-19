//
//  RecipeDetailViewController.m
//  grocery-objc
//
//  Created by Henna Ahmed on 2/19/16.
//  Copyright © 2016 Shena Yoshida. All rights reserved.
//

#import "RecipeDetailViewController.h"
#import <UNIRest.h>


@interface RecipeDetailViewController ()
@property (weak, nonatomic) IBOutlet UILabel *recipeTitle;
@property (weak, nonatomic) IBOutlet UILabel *recipeIngredients;

@end

@implementation RecipeDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *foodURL = [NSString stringWithFormat:@"https://spoonacular-recipe-food-nutrition-v1.p.mashape.com/recipes/%@/information", self.recipeID];
    
    NSDictionary *headers = @{@"X-Mashape-Key": @"ebmr78QZnxmshZicMD43oVuhK1IYp1x9ZyNjsnmVvW62GxZpx9"};
    
    UNIUrlConnection *asyncConnection = [[UNIRest get:^(UNISimpleRequest *request) {
        [request setUrl:foodURL];
        [request setHeaders:headers];
    }] asJsonAsync:^(UNIHTTPJsonResponse *response, NSError *error) {
        
        
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:response.rawBody
                                                             options:kNilOptions
                                                               error:nil];
        
        NSArray *ingredients = [json objectForKey:@"extendedIngredients"];
        
        NSString * allIngredients = @"";
        
        for(NSDictionary * ingredient in ingredients){
            NSString * ingredientName = [ingredient objectForKey:@"originalString"];
            [allIngredients stringByAppendingString: [NSString stringWithFormat:@"%@\n", ingredientName]];
        }
        
        self.recipeTitle.text = [json objectForKey:@"title"];
        self.recipeIngredients.text = allIngredients;
        NSLog(@"%@", allIngredients);
        
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
