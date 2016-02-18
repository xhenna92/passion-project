//
//  ViewController.m
//  grocery-objc
//
//  Created by Shena Yoshida on 2/16/16.
//  Copyright © 2016 Shena Yoshida. All rights reserved.
//

#import "ViewController.h"
#import "FoodResult.h"
#import <UNIRest.h>

@interface ViewController ()



@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self fetchAPIData];
    

    
    
    
    
    

}

- (void)fetchAPIData {
    
    // These code snippets use an open-source library. http://unirest.io/objective-c
    NSDictionary *headers = @{@"X-Mashape-Key": @"ebmr78QZnxmshZicMD43oVuhK1IYp1x9ZyNjsnmVvW62GxZpx9"};
   
    UNIUrlConnection *asyncConnection = [[UNIRest get:^(UNISimpleRequest *request) {
        [request setUrl:@"https://spoonacular-recipe-food-nutrition-v1.p.mashape.com/food/ingredients/autocomplete?query=appl"];
        [request setHeaders:headers];
    }] asJsonAsync:^(UNIHTTPJsonResponse *response, NSError *error) {
       
        NSInteger code = response.code;
        NSDictionary *responseHeaders = response.headers;
        UNIJsonNode *body = response.body;
        NSData *rawBody = response.rawBody;
        
        NSLog(@"body: %@", body);
        
        NSLog(@"raw body: %@", rawBody);
        NSLog(@"response headers: %@", responseHeaders);
        
        
        
    }];
    
}


@end
