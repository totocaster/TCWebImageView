//
//  TCImageViewDemoAppDelegate.m
//  TCImageViewDemo
//
//  Created by Toto Tvalavadze on 2/17/11.
//  Copyright 2011 63BITS. All rights reserved.
//

#import "TCImageViewDemoAppDelegate.h"
#import "TCImageView.h"

@implementation TCImageViewDemoAppDelegate


@synthesize window=_window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    TCImageView *image = [[TCImageView alloc] initWithURL:[NSURL URLWithString:@"http://farm6.static.flickr.com/5051/5459247881_ec423d6611_b.jpg"] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    image.frame = CGRectMake(10.0, 50.0, 300.0, 200.0);
    image.caching = YES; // Remove line or change to NO to disable off-line caching
    
    [image loadImage];
    
    [self.window addSubview:image];
    
    // Override point for customization after application launch.
    [self.window makeKeyAndVisible];
    return YES;
}


- (void)applicationWillTerminate:(UIApplication *)application
{

}

- (void)dealloc
{
    [_window release];
    [super dealloc];
}

@end
