package com.weforpay.plugin.yoosee;

import com.u.telecare.k10app.R;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import com.p2p.core.BaseMonitorActivity;
import com.p2p.core.P2PHandler;
import com.p2p.core.P2PView;

/**
 * Created by wzy on 2016/6/14.
 */
public class MonitorActivity extends BaseMonitorActivity implements View.OnClickListener {
	private final String TAG = "MonitorActivity";
    public static String P2P_ACCEPT = "com.yoosee.P2P_ACCEPT";
    public static String P2P_READY = "com.yoosee.P2P_READY";
    public static String P2P_REJECT = "com.yoosee.P2P_REJECT";
    private String userId,pwd,callId,callPwd;
    boolean connected = false;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_monito);
        
        regFilter();
    }

   


    @Override
    protected void onResume() {
        super.onResume();
        pView = (P2PView) findViewById(R.id.pview);
        initP2PView(7);
        setMute(true);  //璁剧疆鎵嬫満闈欓煶
        P2PHandler.getInstance().openAudioAndStartPlaying(1);//鎵撳紑闊抽骞跺噯澶囨挱鏀撅紝calllType涓巆all鏃秚ype涓�鑷�
        Bundle b = this.getIntent().getExtras();
        if(b != null){
        	this.userId = b.getString("userId");
            this.callId = b.getString("callId");
            this.callPwd = b.getString("callPwd");
            String title = b.getString("title");
            this.setTitle(title);
            this.connect();	
        }
    }


    @Override
    protected void onP2PViewSingleTap() {

    }

    @Override
    protected void onCaptureScreenResult(boolean isSuccess, int prePoint) {
       
    }

    @Override
    public int getActivityInfo() {
        return 0;
    }

    @Override
    protected void onGoBack() {

    }

    @Override
    protected void onGoFront() {

    }

    @Override
    protected void onExit() {

    }
    void connect(){
        pwd = P2PHandler.getInstance().EntryPassword(callPwd);//缂佸繗绻冩潪顒佸床閸氬海娈戠拋鎯ь槵鐎靛棛鐖�
        
        try{
            P2PHandler.getInstance().call(userId, pwd, true, 1,callId, "", "", 2,callId);        	
        }catch(Exception e){
        	e.printStackTrace();
        }
    	this.connected = false;
    }
    @Override
    public void onClick(View v) {
        
    }

    public void regFilter() {
        IntentFilter filter = new IntentFilter();
        filter.addAction(P2P_REJECT);
        filter.addAction(P2P_ACCEPT);
        filter.addAction(P2P_READY);
        registerReceiver(mReceiver, filter);
    }

    @Override
    public void onPause(){
    	super.onPause();
		P2PHandler.getInstance().reject();
    }

	@Override
    public void onDestroy() {
        super.onDestroy();
        unregisterReceiver(mReceiver);
    }

    public BroadcastReceiver mReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            if(intent.getAction().equals(P2P_ACCEPT)){
            	MonitorActivity.this.connected = true;
            }else if(intent.getAction().equals(P2P_READY)){
            }else if(intent.getAction().equals(P2P_REJECT)){
            	if(MonitorActivity.this.connected == false){
            		MonitorActivity.this.connect();
            		Log.d(TAG, "recalling");
            	}
            }
        }
    };
}
