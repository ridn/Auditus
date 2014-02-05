#import <UIKit/UIKit2.h>
#import <AVFoundation/AVFoundation.h>
#import "BulletinBoard/BulletinBoard.h"

#define isiOS7 (kCFCoreFoundationVersionNumber >= 800.00)

//static NSString* const filePath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Library/Preferences/"] stringByAppendingPathComponent:[NSString stringWithFormat: @"com.ridan.auditus.plist"]];
static NSString* const filePath = @"/var/mobile/Library/Preferences/com.ridan.auditus.plist";
static NSMutableDictionary* plist = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
static BOOL isDuplicate = NO;
static BOOL isEnabled = [[plist objectForKey:@"isEnabled"]boolValue];
BOOL lockscreen;
BOOL homeAndInApp;
int enabled; 

id previousItem;

@interface VSSpeechSynthesizer : NSObject 
{ 
} 

+ (id)availableLanguageCodes; 
+ (BOOL)isSystemSpeaking; 
- (id)startSpeakingString:(id)string; 
- (id)startSpeakingString:(id)string toURL:(id)url; 
- (id)startSpeakingString:(id)string toURL:(id)url withLanguageCode:(id)code; 
- (float)rate;		   // default rate: 1 
- (id)setRate:(float)rate; 
- (float)pitch; 	  // default pitch: 0.5
- (id)setPitch:(float)pitch; 
- (float)volume;       // default volume: 0.8
- (id)setVolume:(float)volume; 
@end

@interface SBBulletinBannerItem
- (id)_appName;
- (id)title;
- (id)message;
- (id)_initWithSeedBulletin:(id)arg1 additionalBulletins:(id)arg2 andObserver:(id)arg3;
@end
@interface SBBulletinBannerView
- (id)initWithItem:(id)arg1;
- (id)bannerItem;
@end


void refreshPrefs()
{
	plist = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
	isEnabled = [[plist objectForKey:@"isEnabled"]boolValue];
	enabled = (isEnabled) ? [[plist objectForKey:@"enabled"]intValue] : 3;
	switch (enabled) {
		case 0:
			lockscreen = YES;
			homeAndInApp = YES;
			break;
		case 1:
			lockscreen = YES;
			homeAndInApp = NO;
			break;
		case 2:
			lockscreen = NO;
			homeAndInApp = YES;
			break;
		case 3:
			lockscreen = NO;
			homeAndInApp = NO;
			break;
		default:
			lockscreen = YES;
			homeAndInApp = YES;
			break;
		
			}

}
static void updatedPrefs(CFNotificationCenterRef center,void *observer,CFStringRef name,const void *object,CFDictionaryRef userInfo) {
	void refreshPrefs();
}
%group iOS6
// from SpringBoard (iOS6)
//%hook SBBulletinBannerView
%hook SBBulletinBannerItem
/* check if headphones are plugged in
%new
- (BOOL)ttstIsHeadsetPluggedIn {
    AVAudioSessionRouteDescription* route = [[[AVAudioSession] sharedInstance] currentRoute];
    for (AVAudioSessionPortDescription* desc in [route outputs]) {
	if ([[desc portType] isEqualToString:AVAudioSessionPortHeadphones])
	    return YES;
    }
    return NO;
}
*/
- (id)_initWithSeedBulletin:(id)arg1 additionalBulletins:(id)arg2 andObserver:(id)arg3
//- (id)initWithItem:(id)arg1
{
	refreshPrefs();
	VSSpeechSynthesizer *speech = [[NSClassFromString(@"VSSpeechSynthesizer") alloc] init];
	[speech setRate:(float)1.0];

	if((self == %orig) && homeAndInApp)
	{
		if(previousItem == arg1)
	 	{
			 isDuplicate = YES;
		 }else{
			 isDuplicate = NO;
	 	}
	previousItem = arg1;

	NSString* textToSpeak = [NSString stringWithFormat:@"New %@ notification from: %@, %@.",[self _appName],[self title],[self message]];

	//if([self ttstIsHeadsetPluggedIn])
	//guess this method is called twice as the message comes through twice.
	//checking for dupilicate message, to insure message not repeated
	if(!isDuplicate)[speech startSpeakingString:textToSpeak];

       }
       return %orig; 
}

%end
//Lockscreen (iOS6)
%hook SBAwayBulletinListItem
- (id)initWithBulletin:(id)arg1 andObserver:(id)arg
{
	refreshPrefs();
	VSSpeechSynthesizer *speech = [[NSClassFromString(@"VSSpeechSynthesizer") alloc] init];
	[speech setRate:(float)1.0];
	if((self == %orig) &&  lockscreen)
	{
		NSString* textToSpeak = [NSString stringWithFormat:@"New notification from: %@, %@.",[self title],[self message]];
		[speech startSpeakingString:textToSpeak];
	}
       return %orig; 
}

%end
%end

%group iOS7
//from SpringBoard (iOS7)
%hook SBBulletinBannerController
- (void)observer:(id)observer addBulletin:(BBBulletinRequest *)bulletin forFeed:(int)feed
{
	%orig;
	refreshPrefs();
	AVSpeechSynthesizer *speech = [[AVSpeechSynthesizer alloc] init];

	if(homeAndInApp)
	{
		NSString* textToSpeak = [NSString stringWithFormat:@"New notification from: %@, %@.",bulletin.title,bulletin.message];
		AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:textToSpeak];
		[speech speakUtterance:utterance];
	}

}
%end
//LockScreen (iOS7)
%hook SBLockScreenNotificationListController
- (void)observer:(id)observer addBulletin:(BBBulletinRequest *)bulletin forFeed:(int)feed
{
	%orig;
	refreshPrefs();
	AVSpeechSynthesizer *speech = [[AVSpeechSynthesizer alloc] init];

	if(homeAndInApp)
	{
		NSString* textToSpeak = [NSString stringWithFormat:@"New notification from: %@, %@.",bulletin.title,bulletin.message];
		AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:textToSpeak];
		[speech speakUtterance:utterance];
	}

}
%end
%end





%ctor {
	%init();
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, updatedPrefs, CFSTR("com.ridan.auditus/ReloadPrefs"), NULL, CFNotificationSuspensionBehaviorCoalesce);
	if (isiOS7) {
		%init(iOS7);
	} else {
		%init(iOS6);
	}
}

