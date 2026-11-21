package com.linkxin.douyouPlayer.vo;

import net.tsz.afinal.annotation.sqlite.Id;
import net.tsz.afinal.annotation.sqlite.Table;
import android.os.Parcel;
import android.os.Parcelable;

@Table(name = "goods")
public class LiveRoomGoods implements Comparable<LiveRoomGoods>,Parcelable {
	@Id(column = "id")
	private long id;
	private long goodsId;
	private String categoryPhoto;
	private String categoryName;
	private String categoryCode;
	private long categoryId;
	private String categoryType;
	private int categorySort;
	private String name;
	private String remark;
	private String photo;
	private int amount;
	private int price;
	private String priceShow;

	public long getId() {
		return id;
	}

	public void setId(long id) {
		this.id = id;
	}

	public long getGoodsId() {
		return goodsId;
	}

	public void setGoodsId(long goodsId) {
		this.goodsId = goodsId;
	}

	public String getCategoryPhoto() {
		return categoryPhoto;
	}

	public void setCategoryPhoto(String categoryPhoto) {
		this.categoryPhoto = categoryPhoto;
	}

	public String getCategoryName() {
		return categoryName;
	}

	public void setCategoryName(String categoryName) {
		this.categoryName = categoryName;
	}

	public String getCategoryCode() {
		return categoryCode;
	}

	public void setCategoryCode(String categoryCode) {
		this.categoryCode = categoryCode;
	}

	public long getCategoryId() {
		return categoryId;
	}

	public void setCategoryId(long categoryId) {
		this.categoryId = categoryId;
	}

	public String getCategoryType() {
		return categoryType;
	}

	public void setCategoryType(String categoryType) {
		this.categoryType = categoryType;
	}

	public int getCategorySort() {
		return categorySort;
	}

	public void setCategorySort(int categorySort) {
		this.categorySort = categorySort;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getRemark() {
		return remark;
	}

	public void setRemark(String remark) {
		this.remark = remark;
	}

	public String getPhoto() {
		return photo;
	}

	public void setPhoto(String photo) {
		this.photo = photo;
	}

	public int getAmount() {
		return amount;
	}

	public void setAmount(int amount) {
		this.amount = amount;
	}

	public int getPrice() {
		return price;
	}

	public void setPrice(int price) {
		this.price = price;
	}

	public String getPriceShow() {
		return priceShow;
	}

	public void setPriceShow(String priceShow) {
		this.priceShow = priceShow;
	}


	@Override
	public int compareTo(LiveRoomGoods another) {
		if (categorySort < another.getCategorySort()) {
			return -1;
		} else if (categorySort > another.getCategorySort()) {
			return 1;
		} else {
			if (price < another.getPrice()) {
				return -1;
			} else if (price > another.getPrice()) {
				return 1;
			} else {
				return 0;
			}
		}
	}

	@Override
	public int describeContents() {
		return 0;
	}

	@Override
	public void writeToParcel(Parcel dest, int flags) {
		dest.writeLong(this.id);
		dest.writeLong(this.goodsId);
		dest.writeString(this.categoryPhoto);
		dest.writeString(this.categoryName);
		dest.writeString(this.categoryCode);
		dest.writeLong(this.categoryId);
		dest.writeString(this.categoryType);
		dest.writeInt(this.categorySort);
		dest.writeString(this.name);
		dest.writeString(this.remark);
		dest.writeString(this.photo);
		dest.writeInt(this.amount);
		dest.writeInt(this.price);
		dest.writeString(this.priceShow);
	}

	public LiveRoomGoods() {
	}

	protected LiveRoomGoods(Parcel in) {
		this.id = in.readLong();
		this.goodsId = in.readLong();
		this.categoryPhoto = in.readString();
		this.categoryName = in.readString();
		this.categoryCode = in.readString();
		this.categoryId = in.readLong();
		this.categoryType = in.readString();
		this.categorySort = in.readInt();
		this.name = in.readString();
		this.remark = in.readString();
		this.photo = in.readString();
		this.amount = in.readInt();
		this.price = in.readInt();
		this.priceShow = in.readString();
	}

	public static final Parcelable.Creator<LiveRoomGoods> CREATOR = new Parcelable.Creator<LiveRoomGoods>() {
		@Override
		public LiveRoomGoods createFromParcel(Parcel source) {
			return new LiveRoomGoods(source);
		}

		@Override
		public LiveRoomGoods[] newArray(int size) {
			return new LiveRoomGoods[size];
		}
	};
}