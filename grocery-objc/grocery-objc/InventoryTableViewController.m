//
//  InventoryTableViewController.m
//  grocery-objc
//
//  Created by Shena Yoshida on 2/17/16.
//  Copyright © 2016 Shena Yoshida. All rights reserved.
//

#import "InventoryTableViewController.h"
#import "AddFoodViewController.h"
#import "NSDate+RelativeTime.h"
#import "InventoryTableViewCell.h"
#import <Firebase/Firebase.h>


@interface InventoryTableViewController ()

@property (nonatomic) NSMutableArray *foods;
@property (nonatomic) NSDictionary *jsonFoods;

@end

@implementation InventoryTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // set up custom cell
    UINib *nib = [UINib nibWithNibName:@"InventoryTableViewCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"cellIdentifier"];
    
    // set height of cell to adjust to text
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 50;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                                initWithTitle:@"Add"
                                                style:UIBarButtonSystemItemAdd
                                                target:self
                                                action:@selector(addFood:)];
    
    self.foods = [[NSMutableArray alloc] init];
    

    
    
    
//    // test array:
//    NSArray *array = @[@"bread", @"eggs", @"fish", @"eggplant", @"banannas", @"shrimp", @"apples", @"roast beef", @"mushrooms", @"butter", @"hot sauce", @"pickles", @"marmalade", @"ketchup", @"mustard", @"broccoli", @"bacon", @"spinach", @"chicken", @"cheese"];
//    
//    self.foods = [[NSMutableArray alloc]initWithArray:array];
//   
//    
//    // append emoji
//    NSMutableString *withEmoji = [[NSMutableString alloc] init];
//    NSMutableArray *itemsToRemove = [[NSMutableArray alloc] init];
//    
//    for (NSString *item in self.foods) {
//        
//        
//        if ([item  isEqualToString: @"chicken"]) {
//            withEmoji = [NSMutableString stringWithFormat:@"🐔 %@", item];
//            [itemsToRemove addObject:item]; // collect items to remove from array
//        }
//        else if ([item  isEqualToString: @"bread"]) {
//            withEmoji = [NSMutableString stringWithFormat:@"🍞 %@", item];
//            [itemsToRemove addObject:item];
//        }
//        else if ([item  isEqualToString: @"eggs"]) {
//            withEmoji = [NSMutableString stringWithFormat:@"🍳 %@", item];
//            [itemsToRemove addObject:item];
//        }
//        else if ([item  isEqualToString: @"fish"]) {
//            withEmoji = [NSMutableString stringWithFormat:@"🐟 %@", item];
//            [itemsToRemove addObject:item];
//        }
//        else if ([item  isEqualToString: @"bread"]) {
//            withEmoji = [NSMutableString stringWithFormat:@"🍞 %@", item];
//            [itemsToRemove addObject:item];
//        }
//        else if ([item  isEqualToString: @"eggplant"]) {
//            withEmoji = [NSMutableString stringWithFormat:@"🍆 %@", item];
//            [itemsToRemove addObject:item];
//        }
//        else if ([item  isEqualToString: @"banannas"]) {
//            withEmoji = [NSMutableString stringWithFormat:@"🍌 %@", item];
//            [itemsToRemove addObject:item];
//        }
//        else if ([item  isEqualToString: @"shrimp"]) {
//            withEmoji = [NSMutableString stringWithFormat:@"🍤 %@", item];
//            [itemsToRemove addObject:item];
//        }
//        else if ([item  isEqualToString: @"apples"]) {
//            withEmoji = [NSMutableString stringWithFormat:@"🍎 %@", item];
//            [itemsToRemove addObject:item];
//        }
//        else if ([item  isEqualToString: @"beef"]) {
//            withEmoji = [NSMutableString stringWithFormat:@"🐮 %@", item];
//            [itemsToRemove addObject:item];
//        }
//        else if ([item  isEqualToString: @"mushrooms"]) {
//            withEmoji = [NSMutableString stringWithFormat:@"🍄 %@", item];
//            [itemsToRemove addObject:item];
//        }
//        else if ([item  isEqualToString: @"butter"]) {
//            withEmoji = [NSMutableString stringWithFormat:@"✨ %@", item];
//            [itemsToRemove addObject:item];
//        }
//        else if ([item  isEqualToString: @"hot sauce"]) {
//            withEmoji = [NSMutableString stringWithFormat:@"🌶 %@", item];
//            [itemsToRemove addObject:item];
//        }
//        else if ([item  isEqualToString: @"tomato"]) {
//            withEmoji = [NSMutableString stringWithFormat:@"🍅 %@", item];
//            [itemsToRemove addObject:item];
//        }
//        else if ([item  isEqualToString: @"broccoli"]) {
//            withEmoji = [NSMutableString stringWithFormat:@"🌳 %@", item];
//            [itemsToRemove addObject:item];
//        }
//        else if ([item  isEqualToString: @"spinach"]) {
//            withEmoji = [NSMutableString stringWithFormat:@"🌱 %@", item];
//            [itemsToRemove addObject:item];
//        }
//        else if ([item  isEqualToString: @"bacon"]) {
//            withEmoji = [NSMutableString stringWithFormat:@"🐷 %@", item];
//            [itemsToRemove addObject:item];
//        }
////         else {
////           withEmoji = [NSMutableString stringWithFormat:@"🍽 %@", item];
////            [itemsToRemove addObject:item];
////            }
//        }
//    
//    [self.foods insertObject:withEmoji atIndex:0];
//    [self.foods removeObjectsInArray:itemsToRemove];
}

-(void)viewDidAppear:(BOOL)animated{
    [self.foods removeAllObjects];
    // read data
    Firebase *myRootRef = [[Firebase alloc] initWithUrl:@"https://scorching-heat-3082.firebaseio.com/Grocery-List"];
    [myRootRef observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        if (snapshot.value != [NSNull null]) {
        self.jsonFoods = snapshot.value;
        self.foods = [self.jsonFoods.allKeys mutableCopy];
        [self.tableView reloadData];
        }
        
    }];
}

-(IBAction)addFood:(id)sender{
   AddFoodViewController * vc = [self.storyboard instantiateViewControllerWithIdentifier:@"addFoodVC"];
    [self presentViewController:vc animated:YES completion:nil];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.foods.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    InventoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellIdentifier" forIndexPath:indexPath];
    
    NSString *key = self.foods[indexPath.row];
    NSString *emoji = [[self.jsonFoods objectForKey:key] objectForKey:@"emoji"];
    NSString *displayName = [NSString stringWithFormat:@"%@%@", key, emoji];
    NSTimeInterval interval = [[[self.jsonFoods objectForKey:key] objectForKey:@"Expiration Date"] doubleValue];
    NSDate * date = [NSDate dateWithTimeIntervalSince1970:interval];
    NSString *time_ago = [date relativeTime];
    
    
    
    cell.labelFood.text = displayName;
    cell.labelDate.text = time_ago;
    
    
    return cell;
}



- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {

    
    
    return YES;
}




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
#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
