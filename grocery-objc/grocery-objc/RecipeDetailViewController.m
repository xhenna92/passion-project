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
@property (weak, nonatomic) IBOutlet UIImageView *recipeImage;

@property (weak, nonatomic) IBOutlet UILabel *recipeInstructions;

@end

@implementation RecipeDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.navigationController.navigationBar setTranslucent:NO];
    [self.tabBarController.tabBar setTranslucent:NO];

    
    NSString *foodURL = [NSString stringWithFormat:@"https://spoonacular-recipe-food-nutrition-v1.p.mashape.com/recipes/%@/information", self.recipeID];
    
    NSDictionary *headers = @{@"X-Mashape-Key": @"ebmr78QZnxmshZicMD43oVuhK1IYp1x9ZyNjsnmVvW62GxZpx9"};
    
    UNIUrlConnection *asyncConnection = [[UNIRest get:^(UNISimpleRequest *request) {
        [request setUrl:foodURL];
        [request setHeaders:headers];
    }] asJsonAsync:^(UNIHTTPJsonResponse *response, NSError *error) {
        
        
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:response.rawBody
                                                             options:kNilOptions
                                                               error:nil];
        
        //NSString *image = [json objectForKey:@"image"];
        //
        //[json objectForKey:@"readyInMinutes"];
        //[json objectForKey:@"servings"];
        // sourceUrl
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.recipeTitle.text = [json objectForKey:@"title"];
            self.recipeInstructions.text = [self convertHTML:[json objectForKey:@"instructions"]];
            NSData * imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: [json objectForKey:@"image"]]];
            self.recipeImage.image = [UIImage imageWithData: imageData];
            NSArray *ingredients = [json objectForKey:@"extendedIngredients"];
            NSMutableString* allIngredients = [NSMutableString stringWithCapacity:150];
            
            for(NSDictionary * ingredient in ingredients){
                NSString * ingredientName = [ingredient objectForKey:@"originalString"];
                [allIngredients appendFormat:@"%@\n", ingredientName];
               
            }
            self.recipeIngredients.text = allIngredients;
        });
        
        
        
    }];
    
}

-(NSString *)convertHTML:(NSString *)html {
    
    NSScanner *myScanner;
    NSString *text = nil;
    myScanner = [NSScanner scannerWithString:html];
    
    while ([myScanner isAtEnd] == NO) {
        
        [myScanner scanUpToString:@"<" intoString:NULL] ;
        
        [myScanner scanUpToString:@">" intoString:&text] ;
        
        html = [html stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>", text] withString:@""];
    }
    //
    html = [html stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    return html;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
