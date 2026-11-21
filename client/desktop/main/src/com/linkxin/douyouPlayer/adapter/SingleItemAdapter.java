package com.linkxin.douyouPlayer.adapter;

import java.util.List;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

/**
 * 单个item adapter
 * @author lxy
 *
 * @param <T>
 */
public abstract class SingleItemAdapter<T> extends CommonAdapter<T> {

	public SingleItemAdapter(Context context, List<T> datas) {
		super(context, datas);
		// TODO Auto-generated constructor stub
	}
	
	protected abstract int getLayoutId();
	protected abstract void onBindData(View convertView,T data,int position);
	@Override
	public View getView(int position, View convertView, ViewGroup parent) {
		// TODO Auto-generated method stub
		if (convertView == null) {
			convertView = LayoutInflater.from(context).inflate(getLayoutId(), null);
		}
		
		T data = datas.get(position);
		
		onBindData(convertView, data, position);
		
		return convertView;
	}
	
}
