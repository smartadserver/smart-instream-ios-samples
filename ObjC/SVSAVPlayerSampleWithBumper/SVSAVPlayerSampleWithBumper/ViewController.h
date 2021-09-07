//
//  ViewController.h
//  SVSAVPlayerSample
//
//  Created by glaubier on 17/01/2018.
//  Copyright © 2018 Smart AdServer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideoContainerView.h"

@interface ViewController : UIViewController

@property (nonatomic, weak) IBOutlet VideoContainerView *videoContainerView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *topConstraint;
@property (nonatomic, weak) IBOutlet UILabel *versionLabel;

@property (weak, nonatomic) IBOutlet UIImageView *beginBumperImageView;
@property (weak, nonatomic) IBOutlet UIImageView *endBumperImageView;


@end

