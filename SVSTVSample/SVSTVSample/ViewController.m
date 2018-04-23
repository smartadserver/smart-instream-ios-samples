//
//  ViewController.m
//  SVSTVSample
//
//  Created by Thomas Geley on 09/04/2018.
//  Copyright © 2018 Smart Adserver. All rights reserved.
//

#import "ViewController.h"
#import "PlayerViewController.h"

@interface ViewController ()
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // Setup version label - not relevant for integration
    self.versionLabel.text = [NSString stringWithFormat:@"Smart - Instream SDK v%@", [SVSConfiguration sharedInstance].version];    
}


- (IBAction)openPlayer:(id)sender {
    PlayerViewController *nextController = [self.storyboard instantiateViewControllerWithIdentifier:@"AVPlayerViewController"];
    [self.navigationController pushViewController:nextController animated:YES];
}

@end
