package com.weforpay.plugin.yoosee;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.json.JSONArray;
import org.json.JSONException;
import android.content.Context;
import android.content.Intent;
import android.os.Handler;


public class Yoosee extends CordovaPlugin {
	final String TAG = "Yoosee";
	
	boolean mInited = false;
	@Override
	public boolean execute(String action, JSONArray args,
			CallbackContext callbackContext) throws JSONException {
		if(!this.mInited){
			this.init(args, callbackContext);
		}
		if ( action.equalsIgnoreCase("init") ) {	
			this.init(args,callbackContext);
            return true;
        }else if ( action.equalsIgnoreCase("see") ) {
            this.see(args, callbackContext);
            return true;        
        }
		return super.execute(action, args, callbackContext);
	}
	
	CallbackContext mSeeCallback = null;
	
	Context mContext = null;
	Handler mCordovaHander  = null;
	
	void init(JSONArray args,
			CallbackContext callbackContext){
		mContext = this.cordova.getActivity();
		mCordovaHander = new Handler();
		
	}
	void see(JSONArray args,
			CallbackContext callbackContext) throws JSONException{	
		String callId = args.getString(0);
		String callPwd =  args.getString(1);
		String title = args.getString(2);
		Intent intent = new Intent(this.mContext,LoginActivity.class);
        intent.putExtra("callId", callId);
        intent.putExtra("callPwd",callPwd);
        intent.putExtra("title", title);
		this.mContext.startActivity(intent);
		callbackContext.success();
	}	
}
