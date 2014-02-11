//
//  UHAppDelegate.h
//  UnHider
//
//  Created by Benjamin Marten on 02.11.13.
//  Copyright (c) 2013 Benjamin Marten. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface UHAppDelegate : NSObject <NSApplicationDelegate, NSMenuDelegate, NSWindowDelegate>

@property (unsafe_unretained) IBOutlet NSWindow *aboutWindow;

@end
