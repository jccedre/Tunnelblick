//
//  SUSystemProfiler.m
//  Sparkle
//
//  Created by Andy Matuschak on 12/22/07.
//  Copyright 2007 Andy Matuschak. All rights reserved.
//  Adapted from Sparkle+, by Tom Harrington.
//

#import "SUSystemProfiler.h"

#import "SUHost.h"
#import <sys/sysctl.h>

@implementation SUSystemProfiler
+ (SUSystemProfiler *)sharedSystemProfiler
{
	static SUSystemProfiler *sharedSystemProfiler = nil;
	if (!sharedSystemProfiler)
		sharedSystemProfiler = [[self alloc] init];
	return sharedSystemProfiler;
}

- (NSMutableArray *)systemProfileArrayForHost:(SUHost *)host
{
	// Gather profile information and append it to the URL.
	NSMutableArray *profileArray = [NSMutableArray array];
	NSArray *profileDictKeys = [NSArray arrayWithObjects:@"key", @"displayKey", @"value", @"displayValue", nil];
	
	// OS version
	NSString *currentSystemVersion = [SUHost systemVersionString];
	if (currentSystemVersion != nil)
		[profileArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"osVersion",@"OS Version",currentSystemVersion,currentSystemVersion,nil] forKeys:profileDictKeys]];
	
	return profileArray;
}

@end
