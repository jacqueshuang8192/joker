package com.hbi.vo.response.user;

import com.hbi.vo.response.base.BaseResultVo;
import io.swagger.v3.oas.annotations.media.Schema;

public class UserVo extends BaseResultVo {

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	@Schema(title = "姓名", required = true)
	private String name;
	@Schema(title = "昵称", required = true)
	private String nickName;
	@Schema(title = "图像", required = true)
	private String photoURL;
	@Schema(title = "性别", required = true)
	private String sex;
	@Schema(title = "生日", required = true)
	private String birthday;
	@Schema(title = "省份", required = true)
	private String province;
	@Schema(title = "省份ID", required = true)
	private String provinceId;
	@Schema(title = "城市", required = true)
	private String city;
	@Schema(title = "城市ID", required = true)
	private String cityId;
	@Schema(title = "个性签名", required = true)
	private String sign;
	@Schema(title = "所属公会", required = true)
	private String society;
	@Schema(title = "公会ID", required = true)
	private Long societyId;
	@Schema(title = "状态,0：离线；1：在线；2：正在直播；3：正在直播，同时玩游戏", required = true)
	private String status;
	@Schema(title = "游戏名称", required = true)
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
