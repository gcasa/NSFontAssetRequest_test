//
//  AppDelegate.m
//  NSFontAssetRequest_test
//
//  Created by Gregory Casamento on 9/6/25.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (strong) IBOutlet NSWindow *window;
@property (strong) IBOutlet NSTextField *fontNameField;
@property (strong) IBOutlet NSButton *button;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
        // NSArray *downloaded = [request downloadedFontDescriptors];
    // NSLog(@"downloaded = %@", downloaded);
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


- (BOOL)applicationSupportsSecureRestorableState:(NSApplication *)app {
    return YES;
}

- (IBAction) downloadFont: (id)sender
{
    // Insert code here to initialize your application
    NSFontDescriptor *descriptor = [NSFontDescriptor fontDescriptorWithName: [self.fontNameField stringValue] size: 12.0];
    NSArray *fontDescriptors = [NSArray arrayWithObject: descriptor];
    NSFontAssetRequest *request = [[NSFontAssetRequest alloc]
                                   initWithFontDescriptors: fontDescriptors
                                   options: NSFontAssetRequestOptionUsesStandardUI];
    
    [request downloadFontAssetsWithCompletionHandler:^BOOL(NSError * _Nullable error) {
        if (error != NULL)
        {
            NSLog(@"Downloaded with completion code %@", error);
            return NO;
        }
        return YES;
    }];
}
@end
