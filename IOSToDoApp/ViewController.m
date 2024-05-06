//
//  ViewController.m
//  IOSToDoApp
//
//  Created by Salma on 17/04/2024.
//

#import "ViewController.h"
#import "MyTabBarController.h" // Import the tab bar view controller class

#import "SVGKit.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)gotoTabbar:(id)sender {
    // Instantiate the tab bar view controller
    MyTabBarController *tabBarController = [self.storyboard instantiateViewControllerWithIdentifier:@"tabBar_screen"];
    
    // Push the tab bar controller onto the navigation stack
    [self.navigationController pushViewController:tabBarController animated:YES];
}

@end
