//
//  ViewController.h
//  soundLEvelDemo
//
//  Created by Bogdan Laukhin on 4/6/17.
//  Copyright © 2017 ua.org. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>


@protocol UserSignOutProtocol <NSObject>

- (void)userDidSignOutWithviewController:(UIViewController *)viewController;

@end


@interface ViewController : UITableViewController

@property (assign, nonatomic)   BOOL isHearingDamageRisk;
@property (weak, nonatomic)     id<UserSignOutProtocol> delegate;

@end

