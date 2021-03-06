//
//  RecipesTableViewController.m
//  grocery-objc
//
//  Created by Henna Ahmed on 2/19/16.
//  Copyright © 2016 Shena Yoshida. All rights reserved.
//

#import "RecipesTableViewController.h"
#import "FoodResult.h"
#import <UNIRest.h>
#import "foodModel.h"
#import "RecipeDetailViewController.h"
#import "RecipesTableViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface RecipesTableViewController ()
@property (nonatomic) NSMutableArray * recipes;
@property (nonatomic) NSMutableArray * aboutToExpire;
@property (nonatomic) foodModel *sharedManager;

@end

@implementation RecipesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // set up custom cell
    UINib *nib = [UINib nibWithNibName:@"RecipesTableViewCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"recipeIdentifier"];
    
    // set height of cell to adjust to text
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 50;
    
    self.tableView.backgroundColor = [UIColor colorWithRed:248.0/255.0 green:213.0/255.0 blue:199.0/255.0 alpha:1];
    self.tableView.backgroundView.backgroundColor = [UIColor colorWithRed:248.0/255.0 green:213.0/255.0 blue:199.0/255.0 alpha:1];
    
    [self.navigationController.navigationBar setTranslucent:NO];
    [self.tabBarController.tabBar setTranslucent:NO];

    
    self.recipes = [[NSMutableArray alloc]init];
    self.aboutToExpire = [[NSMutableArray alloc]init];
    self.sharedManager = [foodModel sharedManager];
    NSDate *today = [NSDate date];
    NSDate *nextWeek  = [today dateByAddingTimeInterval: 1209600.0];
    
    //determine which ingredients are about to expire
    for (NSDictionary* food in self.sharedManager.foodData) {
        NSString *key = [[food allKeys] firstObject];
        NSTimeInterval interval = [[[food objectForKey:key] objectForKey: @"Expiration Date"] doubleValue];
        NSDate * foodDate = [NSDate dateWithTimeIntervalSince1970:interval];
        
        if([foodDate compare:nextWeek]<1 && [foodDate compare:[NSDate date]]>0){
            [self.aboutToExpire addObject:key];
        }
    }
    
    //make a call to the recipe API
    [self fetchAPIData];
    
    
}

- (void)fetchAPIData {
    NSString *foodURL = [NSString stringWithFormat:@"https://spoonacular-recipe-food-nutrition-v1.p.mashape.com/recipes/findByIngredients?ingredients=%@&number=20", [self.aboutToExpire componentsJoinedByString:@","]];
    
    NSDictionary *headers = @{@"X-Mashape-Key": @"ebmr78QZnxmshZicMD43oVuhK1IYp1x9ZyNjsnmVvW62GxZpx9"};
    
    UNIUrlConnection *asyncConnection = [[UNIRest get:^(UNISimpleRequest *request) {
        [request setUrl:foodURL];
        [request setHeaders:headers];
    }] asJsonAsync:^(UNIHTTPJsonResponse *response, NSError *error) {
        
        if (error) {
            NSLog(@"%@", error);
        }
        else{
            NSArray *json = [NSJSONSerialization JSONObjectWithData:response.rawBody
                                                            options:kNilOptions
                                                              error:nil];
            self.recipes = [json mutableCopy];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }
        
        
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.recipes.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    RecipesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"recipeIdentifier" forIndexPath:indexPath];
    NSDictionary * recipe = self.recipes[indexPath.row];
    cell.recipeLabel.text = [recipe objectForKey:@"title"];
    
    cell.clipsToBounds = YES;
    
    // stretch cell separators across entire view
    cell.preservesSuperviewLayoutMargins = false;
    cell.separatorInset = UIEdgeInsetsZero;
    cell.layoutMargins = UIEdgeInsetsZero;
    
    [cell.recipeImage sd_setImageWithURL:[NSURL URLWithString:[recipe objectForKey:@"image"]]
                      placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    
//    NSData * imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: [recipe objectForKey:@"image"]]];
//    cell.recipeImage.image = [UIImage imageWithData: imageData];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    
    [self performSegueWithIdentifier:@"recipedetailsegue" sender:nil];
    
    
}



-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    
    
    RecipeDetailViewController *destViewController = segue.destinationViewController;
    destViewController.recipeID = [self.recipes[indexPath.row] objectForKey:@"id"];
    
}

@end
