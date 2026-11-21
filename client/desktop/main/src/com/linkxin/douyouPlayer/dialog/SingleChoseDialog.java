package com.linkxin.douyouPlayer.dialog;

import android.app.Dialog;
import android.content.Context;
import android.view.MotionEvent;
import android.view.View;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.ListView;
import android.widget.TextView;
import com.linkxin.douyouPlayer.activity.nyq.R;
import com.linkxin.douyouPlayer.adapter.CommonAdapter.OnSelectedListener;
import com.linkxin.douyouPlayer.adapter.SingleItemAdapter;
import java.util.Arrays;
import java.util.List;

/**
 * 单选对话框弹窗
 * @author lxy
 *
 * @param <T>
 */
public class SingleChoseDialog<T> extends Dialog{

	public SingleChoseDialog(Context context,int theme) {
		super(context,theme);
		// TODO Auto-generated constructor stub
	}

    /**
     * 支付渠道回调
     */
    public static interface PaymentChannelListener{
        void onAlipay();
        void onWechatPay();
        void onUnionPay();
    }

}
