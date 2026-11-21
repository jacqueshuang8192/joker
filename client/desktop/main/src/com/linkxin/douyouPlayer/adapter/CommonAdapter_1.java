package com.linkxin.douyouPlayer.adapter;

import java.util.List;

import com.linkxin.douyouPlayer.util.ViewHolderUtils;

import android.content.Context;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;

/**
 * 通用adapter
 * @author lxy
 *
 * @param <T>
 */
public abstract class CommonAdapter<T> extends BaseAdapter {
	
	protected Context context;
	protected List<T> datas;
	protected OnSelectedListener<T> listener;
	
	public CommonAdapter(Context context, List<T> datas) {
		super();
		this.context = context;
		this.datas = datas;
	}
	
	@Override
	abstract public View getView(int position, View convertView, ViewGroup parent);
	
	public void setListener(OnSelectedListener<T> l){
		this.listener = l;
	}
	
	public Context getContext(){
		return context;
	}
	
	public List<T> getDatas(){
		return datas;
	}
	
	public T getItemData(int position){
		return datas.get(position);
	}
	
	public void setDatas(List<T> datas){
		this.datas = datas;
	}
	
	public void addDatas(List<T> list){
		if (datas !=null && list !=null) {
			datas.addAll(list);
            notifyDataSetChanged();
		}

	}

    public void updateDatas(List<T> list){
        datas.clear();
        addDatas(list);
    }
	
	public void add(T data){
		if (datas !=null && data !=null) {
			datas.add(data);
			notifyDataSetChanged();
		}
	}
	
	public void remove(T data){
		if (datas !=null && data !=null) {
			datas.remove(data);
			notifyDataSetChanged();
		}
	}
	
	public void remove(int position){
		if (datas !=null) {
			datas.remove(position);
			notifyDataSetChanged();
		}
	}
	

	@Override
	public int getCount() {
		// TODO Auto-generated method stub
		return datas == null?0:datas.size();
	}

	@Override
	public T getItem(int position) {
		// TODO Auto-generated method stub
		return datas.get(position);
	}

	@Override
	public long getItemId(int position) {
		// TODO Auto-generated method stub
		return position;
	}
	
	public static interface OnSelectedListener<T>{
		public void onSelected(View view,T data,int position);
	}
	
	protected <V extends View> V findView(View convertView,int id){
		return ViewHolderUtils.findView(convertView, id);
	}
}
