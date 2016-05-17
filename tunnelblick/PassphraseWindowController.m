/*
 * Copyright 2011, 2012, 2013, 2015 Jonathan K. Bullard. All rights reserved.
 *
 *  This file is part of Tunnelblick.
 *
 *  Tunnelblick is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License version 2
 *  as published by the Free Software Foundation.
 *
 *  Tunnelblick is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program (see the file COPYING included with this
 *  distribution); if not, write to the Free Software Foundation, Inc.,
 *  59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *  or see http://www.gnu.org/licenses/.
 */


#import "PassphraseWindowController.h"

#import "defines.h"
#import "helper.h"

#import "AuthAgent.h"
#import "MenuController.h"
#import "TBUserDefaults.h"
#import "UIHelper.h"


extern TBUserDefaults * gTbDefaults;

@implementation PassphraseWindowController

-(id) initWithDelegate: (id) theDelegate
{
    self = [super initWithWindowNibName: [UIHelper appendRTLIfRTLLanguage: @"PassphraseWindow"]];
    if (  ! self  ) {
        return nil;
    }
    
	[[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(applicationDidChangeScreenParametersNotificationHandler:)
                                                 name: NSApplicationDidChangeScreenParametersNotification
                                               object: nil];
    
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver: self
                                                           selector: @selector(wokeUpFromSleepHandler:)
                                                               name: NSWorkspaceDidWakeNotification
                                                             object: nil];
    
    delegate = [theDelegate retain];
    return self;
}

-(void) awakeFromNib
{
    [[self window] setTitle: NSLocalizedString(@"Tunnelblick: Passphrase Required", @"Window title")];
    
    [iconIV setImage: [NSApp applicationIconImage]];
    
	NSString * displayName = [[self delegate] displayName];
	NSString * groupMsg;
	NSString * group = credentialsGroupFromDisplayName(displayName);
	if (  group  ) {
		groupMsg = [NSString stringWithFormat: NSLocalizedString(@"\nusing %@ credentials.", @"Window text"),
					group];
	} else {
		groupMsg = @"";
	}
	
    NSString * localName = [((MenuController *)[NSApp delegate]) localizedNameForDisplayName: displayName];
    NSString * text = [NSString stringWithFormat:
                       NSLocalizedString(@"A passphrase is required to connect to\n  %@%@", @"Window text"),
                       localName,
					   groupMsg];
    [mainText setTitle: text];
    
    [saveInKeychainCheckbox setTitle: NSLocalizedString(@"Save in Keychain", @"Checkbox name")];
    
    NSString * autoConnectKey   = [displayName stringByAppendingString: @"autoConnect"];
    NSString * onSystemStartKey = [displayName stringByAppendingString: @"-onSystemStart"];
    BOOL connectOnSystemStart = (   [gTbDefaults boolForKey: autoConnectKey]
                                 && [gTbDefaults boolForKey: onSystemStartKey] );
    [saveInKeychainCheckbox setEnabled: ! connectOnSystemStart];

    BOOL rtl = [UIHelper languageAtLaunchWasRTL];
    
    CGFloat shift = [UIHelper setTitle: NSLocalizedString(@"OK", @"Button") ofControl: OKButton     shift: ( !rtl ) narrow: NO enable: YES];
    
    [UIHelper setTitle: NSLocalizedString(@"Cancel", @"Button")             ofControl: cancelButton shift: ( !rtl ) narrow: NO enable: YES];
    
    // Adjust position of Cancel button if the OK button got bigger or smaller
    [UIHelper shiftControl: cancelButton by: shift reverse: rtl];
    
    [self redisplay];
}

-(void) redisplayIfShowing
{
    if (  [delegate showingPassphraseWindow]  ) {
        [self redisplay];
    } else {
        NSLog(@"Cancelled redisplay of passphrase window because it is no longer showing");
    }
}

-(void) redisplay
{
    [cancelButton setEnabled: YES];
    [OKButton setEnabled: YES];
    [[self window] center];
    [[self window] display];
    [self showWindow: self];
    [NSApp activateIgnoringOtherApps: YES];
    [[self window] makeKeyAndOrderFront: self];
}

- (IBAction) cancelButtonWasClicked: sender
{
	(void) sender;
	
    [cancelButton setEnabled: NO];
    [OKButton setEnabled: NO];
    [NSApp abortModal];
}

- (IBAction) OKButtonWasClicked: sender
{
	(void) sender;
	
    if (  [[[self passphrase] stringValue] length] == 0  ) {
        TBRunAlertPanel(NSLocalizedString(@"Please enter VPN passphrase.", @"Window title"),
                        NSLocalizedString(@"The passphrase must not be empty!\nPlease enter VPN passphrase.", @"Window text"),
                        nil, nil, nil);
        
        [NSApp activateIgnoringOtherApps: YES];
        return;
    }
    [cancelButton setEnabled: NO];
    [OKButton setEnabled: NO];
    [NSApp stopModal];
}

-(void) applicationDidChangeScreenParametersNotificationHandler: (NSNotification *) n
{
 	(void) n;
    
	if (   [delegate showingPassphraseWindow]
		&& (! [gTbDefaults boolForKey: @"doNotRedisplayLoginOrPassphraseWindowAtScreenChangeOrWakeFromSleep"])  ) {
		NSLog(@"PassphraseWindowController: applicationDidChangeScreenParametersNotificationHandler: redisplaying passphrase window");
        [self performSelectorOnMainThread: @selector(redisplayIfShowing) withObject: nil waitUntilDone: NO];
	}
}

-(void) wokeUpFromSleepHandler: (NSNotification *) n
{
 	(void) n;
    
	if (   [delegate showingPassphraseWindow]
		&& (! [gTbDefaults boolForKey: @"doNotRedisplayLoginOrPassphraseWindowAtScreenChangeOrWakeFromSleep"])  ) {
		NSLog(@"PassphraseWindowController: didWakeUpFromSleepHandler: requesting redisplay of passphrase window");
        [self performSelectorOnMainThread: @selector(redisplayIfShowing) withObject: nil waitUntilDone: NO];
	}
}

-(void) dealloc {
    
    [delegate release]; delegate = nil;
    [[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver: self];
    [[NSNotificationCenter defaultCenter] removeObserver: self];
    
	[super dealloc];
}

- (NSString *) description
{
    return [NSString stringWithFormat:@"%@", [self class]];
}

-(NSTextField *) passphrase
{
    return [[passphrase retain] autorelease];
}

-(void) setPassphrase: (NSTextField *) newValue
{
    if (  passphrase != newValue  ) {
        [passphrase release];
        passphrase = (NSSecureTextField *) [newValue retain];
    }
}

-(BOOL) saveInKeychain
{
    if (  [saveInKeychainCheckbox state] == NSOnState  ) {
        return TRUE;
    } else {
        return FALSE;
    }
}

-(id) delegate
{
    return [[delegate retain] autorelease];
}

@end
