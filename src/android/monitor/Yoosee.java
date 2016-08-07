package com.weforpay.plugin.yoosee;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaWebView;
import org.json.JSONArray;
import org.json.JSONException;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Handler;
import android.util.Log;


public class Yoosee extends CordovaPlugin {
	final String TAG = "Yoosee";
	
	final static String ACTION_LOOK_OK = "yoosee.look.ok";
	final static String ACTION_LOOK_FAIL = "yoosee.look.fail";
	
	boolean mInited = false;
	@Override
	public boolean execute(String action, JSONArray args,
			CallbackContext callbackContext) throws JSONException {
		if(!this.mInited){
			this.init();
		}
		if ( action.equalsIgnoreCase("init") ) {	
			this.init();
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
	
	void init(){
		mContext = this.cordova.getActivity();
		mCordovaHander = new Handler();
		this.mInited = true;
		
	}
	@Override
	public void initialize(CordovaInterface cordova, CordovaWebView webView) {
		// TODO Auto-generated method stub
		this.init();
		this.regFilter();
		super.initialize(cordova, webView);
	}
	
	@Override
	public void onDestroy() {
		// TODO Auto-generated method stub
		this.mContext.unregisterReceiver(this.mReceiver);		
		super.onDestroy();
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
		this.mSeeCallback = callbackContext;
	}	
	
	 public BroadcastReceiver mReceiver = new BroadcastReceiver() {
	        @Override
	        public void onReceive(Context context, Intent intent) {
	            if(intent.getAction().equals("yoosee.look.ok")){
	            	if(mSeeCallback != null){
	            		mSeeCallback.success();
	            	}
	            }else if(intent.getAction().equals("yoosee.look.fail")){
	            	if(mSeeCallback != null){
	            		mSeeCallback.error(-1);
	            	}
	            }
	        }
	    };
    public void regFilter() {
        IntentFilter filter = new IntentFilter();
        filter.addAction(Yoosee.ACTION_LOOK_OK);
        filter.addAction(Yoosee.ACTION_LOOK_FAIL);        
        this.mContext.registerReceiver(mReceiver, filter);
    }
}
