var PushNotification = function(){
  // Call this to register for push notifications. Content of [options] depends on whether we are working with APNS (iOS) or GCM (Android)
  this.register = function(successCallback, errorCallback, options){
    errorCallback = ( errorCallback ) ? errorCallback : console.warn;

    if( typeof errorCallback != 'function' ){
      return console.log('PushNotification.register failure: failure parameter not a function');
    }
    if( typeof successCallback != 'function' ){
      return console.log('PushNotification.register failure: success callback parameter must be a function');
    }
    cordova.exec(successCallback, errorCallback, 'PushPlugin', 'register', [options]);
  }

  // Call this to unregister for push notifications
  this.unregister = function(successCallback, errorCallback, options){
    errorCallback = ( errorCallback ) ? errorCallback : console.warn;

    if( typeof errorCallback != 'function' ){
      return console.log('PushNotification.unregister failure: failure parameter not a function');
    }
    if( typeof successCallback != 'function'){
      return console.log('PushNotification.unregister failure: success callback parameter must be a function');
    }
    cordova.exec(successCallback, errorCallback, 'PushPlugin', 'unregister', [options]);
  }

  // Call this if you want to show toast notification on WP8
  this.showToastNotification = function (successCallback, errorCallback, options){
    errorCallback = ( errorCallback ) ? errorCallback : console.warn;

    if( typeof errorCallback != 'function' ){
      return console.log('PushNotification.register failure: failure parameter not a function');
    }
    cordova.exec(successCallback, errorCallback, 'PushPlugin', 'showToastNotification', [options]);
  }

  // Call this to set the application icon badge
  this.setApplicationIconBadgeNumber = function(successCallback, errorCallback, badge){
    errorCallback = ( errorCallback ) ? errorCallback : console.warn;

    if( typeof errorCallback != 'function' ){
      return console.log('PushNotification.setApplicationIconBadgeNumber failure: failure parameter not a function');
    }
    if( typeof successCallback != 'function' ){
      return console.log('PushNotification.setApplicationIconBadgeNumber failure: success callback parameter must be a function');
    }
    cordova.exec(successCallback, errorCallback, 'PushPlugin', 'setApplicationIconBadgeNumber', [{badge: badge}]);
  }

  // Call this to get current icon badge number
  // this.getApplicationIconBadgeNumber = function(successCallback, errorCallback, options){
  //   errorCallback = ( errorCallback ) ? errorCallback : console.warn;

  //   if( typeof errorCallback != 'function' ){
  //     return console.log('PushNotification.getApplicationIconBadgeNumber failure: failure parameter not a function');
  //   }
  //   if( typeof successCallback != 'function' ){
  //     return console.log('PushNotification.getApplicationIconBadgeNumber failure: success callback parameter must be a function');
  //   }
  //   cordova.exec(successCallback, errorCallback, 'PushPlugin', 'getApplicationIconBadgeNumber', [options]);
  // }
};
//-------------------------------------------------------------------

module.exports = new PushNotification();
