//
//  UHAppDelegate.m
//  UnHider
//
//  Created by Benjamin Marten on 02.11.13.
//  Copyright (c) 2013 Benjamin Marten. All rights reserved.
//

#import "UHAppDelegate.h"
#import "UHStatusItemView.h"
#import "LaunchAtLoginController.h"
#import "CoreFoundation/CoreFoundation.h"

@interface UHAppDelegate()

@property NSStatusItem *statusItem;
@property NSMenu *menu;
@property UHStatusItemView *statusItemView;
@property BOOL visible;
@property LSSharedFileListRef loginItems;
@property LaunchAtLoginController *launchController;
@property NSWindow *firstLaunchWindow;

@end

@implementation UHAppDelegate

- (void) applicationDidFinishLaunching:(NSNotification *)notification
{
//    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"already_launched"];
//    [[NSUserDefaults standardUserDefaults]synchronize];
//
    
    CFStringRef applicationID = CFSTR("com.apple.finder");
    CFStringRef fullScreenKey = CFSTR("AppleShowAllFiles");
    Boolean     booleanValue, success;
    
    booleanValue = CFPreferencesGetAppBooleanValue(fullScreenKey,applicationID,&success);
    
    NSLog(@"succes reading: %hhu, value: %hhu", success, booleanValue);
    
    if (success)
    {
        _visible = booleanValue;
    }

    _launchController = [[LaunchAtLoginController alloc] init];
    
    NSZone *menuZone = [NSMenu menuZone];
    _menu = [[NSMenu allocWithZone:menuZone] init];
    
    _statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];
    [_statusItem setHighlightMode:NO];
    
    _statusItemView = [[UHStatusItemView alloc] init];
    if (_visible == YES)
    {
        _statusItemView.image = [NSImage imageNamed:@"unhider_on"];
    }
    else
    {
        _statusItemView.image = [NSImage imageNamed:@"unhider_off"];
    }
    
    _statusItemView.alternateImage = [NSImage imageNamed:@"menu_alt.png"];
    _statusItemView.target = self;
    _statusItemView.action = @selector(toggleHiddenFiles);
    _statusItemView.rightAction = @selector(showMenu);
    _statusItem.view = _statusItemView;
    
    [self showStartUpImage];
}

- (void)useRetina
{
    float displayScale = 1;
    if ([[NSScreen mainScreen] respondsToSelector:@selector(backingScaleFactor)])
    {
        NSArray *screens = [NSScreen screens];
        for (int i = 0; i < [screens count]; i++)
        {
            float s = [[screens objectAtIndex:i] backingScaleFactor];
            if (s > displayScale)
                displayScale = s;
        }
    }
}

- (void)showStartUpImage
{
    [[NSUserDefaults standardUserDefaults] synchronize];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"already_launched"] == NO)
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"already_launched"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        _firstLaunchWindow = [[NSWindow alloc] init];
        NSRect frame = NSMakeRect(_statusItemView.window.frame.origin.x - 343, _statusItemView.window.frame.origin.y - 225, 450, 225);
        NSUInteger styleMask =    NSBorderlessWindowMask;
        NSRect rect = [NSWindow contentRectForFrameRect:frame styleMask:styleMask];
        _firstLaunchWindow =  [[NSWindow alloc] initWithContentRect:rect styleMask:NSBorderlessWindowMask backing: NSBackingStoreBuffered    defer:NO];
        [_firstLaunchWindow makeKeyAndOrderFront: _firstLaunchWindow];
        [_firstLaunchWindow setLevel:NSPopUpMenuWindowLevel];
        
        [_firstLaunchWindow setExcludedFromWindowsMenu:YES];
        [_firstLaunchWindow setMovableByWindowBackground:NO];
        
        [_firstLaunchWindow setOpaque:NO];
        [_firstLaunchWindow setBackgroundColor:[NSColor clearColor]];
        
        [_firstLaunchWindow setHasShadow:NO];
        [_firstLaunchWindow useOptimizedDrawing:YES];
        
        [_firstLaunchWindow setReleasedWhenClosed:NO];
        
        NSImageView *image = [[NSImageView alloc] initWithFrame:frame];
        
        if ([[[NSLocale preferredLanguages] firstObject]  isEqual: @"de"])
        {
            [image setImage: [NSImage imageNamed:@"startup_de"]];
        }
        else
        {
            [image setImage: [NSImage imageNamed:@"startup"]];
        }
        
        [_firstLaunchWindow setContentView:image];
        
        [NSEvent addGlobalMonitorForEventsMatchingMask:NSLeftMouseDownMask handler:^(NSEvent *event) {
            [_firstLaunchWindow orderOut:self];
        }];
    }
}

- (void)showMenu
{
    if(self.statusItemView.clicked)
    {
        NSMenuItem *menuItem;
        
        _menu = [[NSMenu alloc] init];
        menuItem = [_menu addItemWithTitle:NSLocalizedString(@"About UnHider", nil) action:@selector(about) keyEquivalent:@""];
        [_menu addItem:[NSMenuItem separatorItem]];
        menuItem = [_menu addItemWithTitle:NSLocalizedString(@"Start on System Startup", nil) action:@selector(startAtSystemLaunch) keyEquivalent:@""];
        [_menu addItem:[NSMenuItem separatorItem]];
        [menuItem setState:[_launchController launchAtLogin]];
        menuItem = [_menu addItemWithTitle:NSLocalizedString(@"Quit UnHider", nil) action:@selector(quit) keyEquivalent:@""];
        [menuItem setTarget:self];
        
        [_menu setDelegate:self];
        
        [self.statusItem popUpStatusItemMenu:_menu];
    }
}

- (void)startAtSystemLaunch
{
    if ([_launchController launchAtLogin] == YES)
    {
        [_launchController setLaunchAtLogin:NO];
    }
    else
    {
        [_launchController setLaunchAtLogin:YES];
    }
}

- (void)about
{
    [_aboutWindow setIsVisible:YES];
    
    [NSApp activateIgnoringOtherApps:YES];
}

- (void)menuDidClose:(NSMenu *)menu NS_AVAILABLE_MAC(10_5)
{
    [_statusItemView setHighlight:NO];
}

- (void)quit
{
    [NSApp terminate: self];
}

- (void)toggleHiddenFiles
{
    _visible = [[self runScript:@"toggle.sh"] boolValue];
    
    if (_visible == YES)
    {
        [_statusItemView setImage:[NSImage imageNamed:@"unhider_off"]];
    }
    else
    {
        [_statusItemView setImage:[NSImage imageNamed:@"unhider_on"]];
    }
    [_statusItemView setNeedsDisplay:YES];
}

- (NSString *)runScript:(NSString*)scriptName
{
    NSTask *task;
    task = [[NSTask alloc] init];
    [task setLaunchPath: @"/bin/sh"];
    
    NSArray *arguments;
    NSString* newpath = [NSString stringWithFormat:@"%@/%@",[[NSBundle mainBundle] resourcePath], scriptName];
    //    NSLog(@"shell script path: %@",newpath);
    arguments = [NSArray arrayWithObjects:newpath, nil];
    [task setArguments: arguments];
    
    NSPipe *pipe;
    pipe = [NSPipe pipe];
    [task setStandardOutput: pipe];
    
    NSFileHandle *file;
    file = [pipe fileHandleForReading];
    
    [task launch];
    
    NSData *data;
    data = [file readDataToEndOfFile];
    
    NSString *string;
    string = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    //    NSLog (@"script returned:\n%@", string);
    
    return string;
}

@end
