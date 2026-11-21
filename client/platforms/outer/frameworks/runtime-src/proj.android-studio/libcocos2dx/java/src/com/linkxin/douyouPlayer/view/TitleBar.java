package com.linkxin.douyouPlayer.view;

import android.app.Activity;
import android.content.Context;
import android.content.res.Resources;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.linkxin.douyouPlayer.activity.nyq.R;

/**
 * 导航栏控件
 * Created by lxy on 2016/5/4.
 */
public class TitleBar extends RelativeLayout{

    private LinearLayout llBackward;
    private Button leftBt;
    private TextView titleTv;
    private LinearLayout llForward;
    private Button rightBt;
    private Button rightTxtBt;
    private TextView tvForward;

    private Resources res;
    private Activity activity;

    //左边按钮回调事件
    private OnClickListener onBackwardListenr;
    //右边按钮回调事件
    private OnClickListener onForwardListenr;

    public TitleBar(Context context) {
        this(context,null);
    }

    public TitleBar(Context context, AttributeSet attrs) {
        this(context, attrs,0);

    }

    public TitleBar(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init(context);
    }

    private void init(Context context){
        if (context instanceof Activity){
            activity = (Activity) context;
        }
        res = context.getResources();
        View view = LayoutInflater.from(context).inflate(R.layout.lay_head,null);
        this.addView(view);

        llBackward = getViewById(R.id.ll_backward);
        leftBt = getViewById(R.id.left_bt);
        titleTv = getViewById(R.id.title_tv);
        llForward = getViewById(R.id.ll_forward);
        rightBt = getViewById(R.id.right_bt);
        rightTxtBt = getViewById(R.id.right_txt_bt);
        tvForward = getViewById(R.id.tv_forward);

        leftBt.setClickable(false);

        /**
         * 左边按钮默认事件
         */
        llBackward.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                if (activity !=null){
                    activity.finish();
                }
            }
        });

    }

    //================leftBt start===============

    public void setLeftBtBackgroundResource(int resId){
        leftBt.setBackgroundResource(resId);
    }

    public void setLeftBtBackgroudColor(int color){
        leftBt.setBackgroundColor(color);
    }

    public void showLeftBt(){
        leftBt.setVisibility(VISIBLE);
    }

    public void hideLeftBt(){
        leftBt.setVisibility(GONE);
    }

    //================leftBt start===============

    //================RightBt start===============

    public void setRightBtBackgroundResource(int resId){
        rightBt.setBackgroundResource(resId);
    }

    public void setRightBtBackgroudColor(int color){
        rightBt.setBackgroundColor(color);
    }

    public void showRightBt(){
        rightBt.setVisibility(VISIBLE);
    }

    public void hideRightBt(){
        rightBt.setVisibility(GONE);
    }

    //================RightBt start===============


    //================title start===============
    public void setTitleText(String text){
        titleTv.setText(text);
        titleTv.setVisibility(VISIBLE);
    }

    public void setTitleText(int resId){
        titleTv.setText(resId);
        titleTv.setVisibility(VISIBLE);
    }

    public void showTitleView(){
        titleTv.setVisibility(VISIBLE);
    }

    public void hideTitleView(){
        titleTv.setVisibility(GONE);
    }
    //================title end===============

    //================forward tv start===============
    public void setForwardText(String text){
        tvForward.setText(text);
        tvForward.setVisibility(VISIBLE);
    }

    public void setForwardText(int resId){
        tvForward.setText(resId);
        tvForward.setVisibility(VISIBLE);
    }

    public void showForwardTextView(){
        tvForward.setVisibility(VISIBLE);
    }

    public void hideForwardTextView(){
        tvForward.setVisibility(GONE);
    }
    //================forward tv end===============

    public void showTitleBar(){
        this.setVisibility(VISIBLE);
    }

    public void hideTitleBar(){
        this.setVisibility(GONE);
    }

    public void setInvisible(){
        this.setVisibility(INVISIBLE);
    }

    //================callback===============
    public void setOnForwardListenr(OnClickListener onForwardListenr) {
        this.onForwardListenr = onForwardListenr;
        llForward.setOnClickListener(onForwardListenr);
    }

    public void setOnBackwardListenr(OnClickListener onBackwardListenr) {
        this.onBackwardListenr = onBackwardListenr;
        llBackward.setOnClickListener(onBackwardListenr);
    }

    public void setActivity(Activity activity) {
        this.activity = activity;
    }

    private <V> V getViewById(int viewId){
        return (V) findViewById(viewId);
    }

    public LinearLayout getLlBackward() {
        return llBackward;
    }

    public Button getLeftBt() {
        return leftBt;
    }

    public TextView getTitleTv() {
        return titleTv;
    }

    public LinearLayout getLlForward() {
        return llForward;
    }

    public Button getRightBt() {
        return rightBt;
    }

    public Button getRightTxtBt() {
        return rightTxtBt;
    }

    public TextView getTvForward() {
        return tvForward;
    }
}

