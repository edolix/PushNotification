#import "AppDelegate+notification.h"
#import "PushPlugin.h"
#import <objc/runtime.h>

@implementation AppDelegate (notification)

NSDictionary *launchNotification;

- (id) getCommandInstance:(NSString*)className
{
    return [self.viewController getCommandInstance:className];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSLog(@"didReceiveNotification");
    // //zero badge
    // application.applicationIconBadgeNumber = 0;
    // Get application state for iOS4.x+ devices, otherwise assume active
    UIApplicationState appState = UIApplicationStateActive;
    if( [application respondsToSelector:@selector(applicationState)] ){
        appState = application.applicationState;
    }

    if( appState == UIApplicationStateActive ){
        PushPlugin *pushHandler = [self getCommandInstance:@"PushPlugin"];
        pushHandler.notificationMessage = userInfo;
        pushHandler.isInline = YES;
        [pushHandler notificationReceived];
    }else {
        //save it for later launch
        launchNotification = userInfo;
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    if( launchNotification ){
       PushPlugin *pushHandler = [self getCommandInstance:@"PushPlugin"];
       pushHandler.notificationMessage = launchNotification;
       [pushHandler performSelectorOnMainThread:@selector(notificationReceived) withObject:pushHandler waitUntilDone:NO];
       launchNotification = nil;
    }
}

- (void)dealloc
{
}
@end
