
var argscheck = require('cordova/argscheck'),
    utils = require('cordova/utils'),
    exec = require('cordova/exec'),
    channel = require('cordova/channel');



exports.see = function(callId,callPwd,title,ok,err){
	exec(ok,err, 'yoosee', 'see', [callId,callPwd,title]);
}



