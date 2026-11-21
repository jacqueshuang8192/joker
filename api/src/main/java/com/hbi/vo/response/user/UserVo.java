package com.hbi.vo.response.user;

import com.hbi.vo.response.base.BaseResultVo;
import com.wordnik.swagger.annotations.ApiModelProperty;

public class UserVo extends BaseResultVo {

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	@ApiModelProperty(value = "姓名", required = true)
	private String name;
	@ApiModelProperty(value = "昵称", required = true)
	private String nickName;
	@ApiModelProperty(value = "图像", required = true)
	private String photoURL;
	@ApiModelProperty(value = "性别", required = true)
	private String sex;
	@ApiModelProperty(value = "生日", required = true)
	private String birthday;
	@ApiModelProperty(value = "省份", required = true)
	private String province;
	@ApiModelProperty(value = "省份ID", required = true)
	private String provinceId;
	@ApiModelProperty(value = "城市", required = true)
	private String city;
	@ApiModelProperty(value = "城市ID", required = true)
	private String cityId;
	@ApiModelProperty(value = "个性签名", required = true)
	private String sign;
	@ApiModelProperty(value = "所属公会", required = true)
	private String society;
	@ApiModelProperty(value = "公会ID", required = true)
	private Long societyId;
	@ApiModelProperty(value = "状态,0：离线；1：在线；2：正在直播；3：正在直播，同时玩游戏", required = true)
	private String status;
	@ApiModelProperty(value = "游戏名称", required = true)
	private String playingGame;
	private Long attack;
	private Long defense;
	private Long life;

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getNickName() {
		return nickName;
	}

	public void setNickName(String nickName) {
		this.nickName = nickName;
	}

	public String getPhotoURL() {
		return photoURL;
	}

	public void setPhotoURL(String photoURL) {
		this.photoURL = photoURL;
	}

	public String getSex() {
		return sex;
	}

	public void setSex(String sex) {
		this.sex = sex;
	}

	public String getBirthday() {
		return birthday;
	}

	public void setBirthday(String birthday) {
		this.birthday = birthday;
	}

	public String getProvince() {
		return province;
	}

	public void setProvince(String province) {
		this.province = province;
	}

	public String getProvinceId() {
		return provinceId;
	}

	public void setProvinceId(String provinceId) {
		this.provinceId = provinceId;
	}

	public String getCity() {
		return city;
	}

	public void setCity(String city) {
		this.city = city;
	}

	public String getCityId() {
		return cityId;
	}

	public void setCityId(String cityId) {
		this.cityId = cityId;
	}

	public String getSign() {
		return sign;
	}

	public void setSign(String sign) {
		this.sign = sign;
	}

	public String getSociety() {
		return society;
	}

	public void setSociety(String society) {
		this.society = society;
	}

	public Long getSocietyId() {
		return societyId;
	}

	public void setSocietyId(Long societyId) {
		this.societyId = societyId;
	}

	public String getStatus() {
		return status;
	}

	public void setStatus(String status) {
		this.status = status;
	}

	public String getPlayingGame() {
		return playingGame;
	}

	public void setPlayingGame(String playingGame) {
		this.playingGame = playingGame;
	}

    public Long getAttack() {
        return attack;
    }

    public void setAttack(Long attack) {
        this.attack = attack;
    }

    public Long getDefense() {
        return defense;
    }

    public void setDefense(Long defense) {
        this.defense = defense;
    }

    public Long getLife() {
        return life;
    }

    public void setLife(Long life) {
        this.life = life;
    }

}
