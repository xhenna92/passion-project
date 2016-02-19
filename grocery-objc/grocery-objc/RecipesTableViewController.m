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

@interface RecipesTableViewController ()
    @property (nonatomic) NSMutableArray * recipes;
    @property (nonatomic) NSMutableArray * aboutToExpire;
    @property (nonatomic) foodModel *sharedManager;

@end

@implementation RecipesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
        
        if([foodDate compare:nextWeek]<1){
            [self.aboutToExpire addObject:key];
        }
    }
    
    //make a call to the recipe API

    [self fetchAPIData];
    
    
}

- (void)fetchAPIData {
    NSString *foodURL = [NSString stringWithFormat:@"https://spoonacular-recipe-food-nutrition-v1.p.mashape.com/recipes/findByIngredients?ingredients=%@", [self.aboutToExpire componentsJoinedByString:@","]];
    
    NSDictionary *headers = @{@"X-Mashape-Key": @"ebmr78QZnxmshZicMD43oVuhK1IYp1x9ZyNjsnmVvW62GxZpx9"};
    
    UNIUrlConnection *asyncConnection = [[UNIRest get:^(UNISimpleRequest *request) {
        [request setUrl:foodURL];
        [request setHeaders:headers];
    }] asJsonAsync:^(UNIHTTPJsonResponse *response, NSError *error) {
        
        
        NSArray *json = [NSJSONSerialization JSONObjectWithData:response.rawBody
                                                             options:kNilOptions
                                                               error:nil];
        self.recipes = [json mutableCopy];
        
        [self.tableView reloadData];
        
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RecipeCellIdentifier" forIndexPath:indexPath];
    NSDictionary * recipe = self.recipes[indexPath.row];
    NSLog(@"%@", recipe);
    cell.textLabel.text = [recipe objectForKey:@"title"];
    
//    NSData * imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: [recipe objectForKey:@"image"]]];
//    cell.imageView.image = [UIImage imageWithData: imageData];
    
    return cell;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    RecipeDetailViewController *destViewController = segue.destinationViewController;
    destViewController.recipeID = [self.recipes[indexPath.row] objectForKey:@"id"];
    
}



/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
