#import <UIKit/UIKit2.h>
#import <AVFoundation/AVFoundation.h>
//#define isiOS7 (kCFCoreFoundationVersionNumber >= 800.00)
//i guess the methods between 6 and 7 remain the same.

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
- (id)startSpeakingString:(id)string toURL:(id)url 
withLanguageCode:(id)code; 
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

//%group iOS6
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
//Lockscreen
%hook SBAwayBulletinListItem
- (id)initWithBulletin:(id)arg1 andObserver:(id)arg
{
	VSSpeechSynthesizer *speech = [[NSClassFromString(@"VSSpeechSynthesizer") alloc] init];
	[speech setRate:(float)1.0];
	if((self == %orig) &&  lockscreen)
	{
		NSString* textToSpeak = [NSString stringWithFormat:@"New %@ notification from: %@, %@.",[self _appName],[self title],[self message]];
		[speech startSpeakingString:textToSpeak];
	}
       return %orig; 
}

//%end
%end



static void updatedPrefs(CFNotificationCenterRef center,void *observer,CFStringRef name,const void *object,CFDictionaryRef userInfo) {
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



%ctor {
	%init();
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, updatedPrefs, CFSTR("com.ridan.auditus/ReloadPrefs"), NULL, CFNotificationSuspensionBehaviorCoalesce);
/*
	if (isiOS7) {
		%init(iOS7);
	} else {
		%init(iOS6);
	}
*/
}

