/*
  Copyright 2009-2011 Urban Airship Inc. All rights reserved.

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:

  1. Redistributions of source code must retain the above copyright notice, this
  list of conditions and the following disclaimer.

  2. Redistributions in binaryform must reproduce the above copyright notice,
  this list of conditions and the following disclaimer in the documentation
  and/or other materials provided withthe distribution.

  THIS SOFTWARE IS PROVIDED BY THE URBAN AIRSHIP INC``AS IS'' AND ANY EXPRESS OR
  IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
  MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
  EVENT SHALL URBAN AIRSHIP INC OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
  INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
  BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
  OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
  ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/
#import "PushPlugin.h"

@implementation PushPlugin

@synthesize notificationMessage;
@synthesize isInline;

@synthesize callbackId;
@synthesize callback;

- (void)pluginInitialize
{
  // NSLog(@"PUSH PLUGIN INITIALIZE");
  // Check if user has remote notifications enabled
  if( ![self pushEnabled] ){
    // if are not enabled, addObserver for registration
    [[NSNotificationCenter defaultCenter] addObserver:self
                                            selector:@selector(RemoteNotificationRegistrationSuccess:)
                                            name:@"CDVRemoteNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                            selector:@selector(RemoteNotificationRegistrationFail:)
                                            name:@"CDVRemoteNotificationError" object:nil];
  }

  [[NSNotificationCenter defaultCenter] addObserver:self
                                          selector:@selector(RemoteNotificationChecker:)
                                          name:@"UIApplicationDidFinishLaunchingNotification" object:nil];
}

// This code will be called immediately after application:didFinishLaunchingWithOptions:. We need
// to process notifications in cold-start situations
- (void)RemoteNotificationChecker:(NSNotification *)notification
{
  // NSDictionary *pushDic = [launchOptions objectForKey:@"UIApplicationLaunchOptionsRemoteNotificationKey"];
  // if( pushDic != nil ){
  //   NSLog(@"DIC: %@", pushDic);
  // }

  NSDictionary *launchOptions = [notification userInfo];
  if( launchOptions ){
    // LANCIARE LA NOTIFICA PUSH VERSO IL JAVASCRIPT
    NSLog(@"PLUGIN - RemoteNotificationChecker NOTIF %@", [launchOptions objectForKey: @"UIApplicationLaunchOptionsRemoteNotificationKey"]);
    // self.launchNotification = [launchOptions objectForKey: @"UIApplicationLaunchOptionsRemoteNotificationKey"];
  }
}

#if !TARGET_IPHONE_SIMULATOR
-(void)RemoteNotificationRegistrationSuccess:(NSNotification *)notification
{
  NSString *token = [notification object];
  [self successWithMessage:[NSString stringWithFormat:@"%@", token]];
}
#endif

-(void)RemoteNotificationRegistrationFail:(NSError *)error
{
  NSLog(@"PLUGIN - RemoteNotificationRegistrationFail %@", error);
}

- (void)unregister:(CDVInvokedUrlCommand*)command;
{
  self.callbackId = command.callbackId;

  [[UIApplication sharedApplication] unregisterForRemoteNotifications];
  [self successWithMessage:@"unregistered"];
}

- (void)register:(CDVInvokedUrlCommand*)command;
{
  self.callbackId = command.callbackId;

  NSMutableDictionary* options = [command.arguments objectAtIndex:0];

  self.callback = [options objectForKey:@"ecb"];
  isInline = NO;

  if( [[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)] ){
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert) categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
  }else {
    UIRemoteNotificationType myTypes = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound;
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:myTypes];
  }

  if( notificationMessage )         // if there is a pending startup notification
       [self notificationReceived]; // go ahead and process it
}

/*
- (void)isEnabled:(NSMutableArray *)arguments withDict:(NSMutableDictionary *)options {
  UIRemoteNotificationType type = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
  NSString *jsStatement = [NSString stringWithFormat:@"navigator.PushPlugin.isEnabled = %d;", type != UIRemoteNotificationTypeNone];
  NSLog(@"JSStatement %@",jsStatement);
}
*/

- (BOOL)pushEnabled
{
  UIApplication *application = [UIApplication sharedApplication];
  if( [application respondsToSelector:@selector(isRegisteredForRemoteNotifications)] ){
    return [application isRegisteredForRemoteNotifications];
  }else {
    UIRemoteNotificationType types = [application enabledRemoteNotificationTypes];
    return (types & UIRemoteNotificationTypeAlert);
  }
}

- (void)notificationReceived {
    NSLog(@"Notification received");
    if( notificationMessage && self.callback ){
        // Using mutabledictonary to add "foreground" key (using only "aps" key ...)
        NSMutableDictionary *mutable = [[notificationMessage objectForKey:@"aps"] mutableCopy];
        [mutable setObject:[NSNumber numberWithInt:isInline?1:0] forKey:@"foreground"];
        isInline = NO;
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:mutable options:0 error:&error];
        if( jsonData ){
            NSString *JSONString = [[NSString alloc] initWithBytes:[jsonData bytes] length:[jsonData length] encoding:NSUTF8StringEncoding];
            NSString * jsCallBack = [NSString stringWithFormat:@"%@(%@);", self.callback, JSONString];
            [self.webView stringByEvaluatingJavaScriptFromString:jsCallBack];
        } else {
            NSLog(@"PushPlugin::notificationReceived - invalid json: %@", error);
        }
        notificationMessage = nil;
    }
}

- (void)setApplicationIconBadgeNumber:(CDVInvokedUrlCommand *)command {

  self.callbackId = command.callbackId;

  NSMutableDictionary* options = [command.arguments objectAtIndex:0];
  int badge = [[options objectForKey:@"badge"] intValue] ?: 0;

  [[UIApplication sharedApplication] setApplicationIconBadgeNumber:badge];

  [self successWithMessage:[NSString stringWithFormat:@"app badge count set to %d", badge]];
}

// - (void)getApplicationIconBadgeNumber:(CDVInvokedUrlCommand *)command {
//   DLog(@"getApplicationIconBadgeNumber:%@", command);

//   [self.callbackIds setValue:command.callbackId forKey:@"getApplicationIconBadgeNumber"];

//   CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:[UIApplication sharedApplication].applicationIconBadgeNumber];

//   [self successWithMessage:@"unregistered"];

// [self writeJavascript:[pluginResult toSuccessCallbackString:[self.callbackIds valueForKey:@"getApplicationIconBadgeNumber"]]];

// }

-(void)successWithMessage:(NSString *)message
{
  CDVPluginResult *commandResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:message];
  [self.commandDelegate sendPluginResult:commandResult callbackId:self.callbackId];
}

-(void)failWithMessage:(NSString *)message withError:(NSError *)error
{
  NSString *errorMessage = (error) ? [NSString stringWithFormat:@"%@ - %@", message, [error localizedDescription]] : message;
  CDVPluginResult *commandResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:errorMessage];
  [self.commandDelegate sendPluginResult:commandResult callbackId:self.callbackId];
}
@end
