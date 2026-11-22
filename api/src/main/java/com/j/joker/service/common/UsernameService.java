package com.j.joker.service.common;

import com.j.joker.constants.Constants;
import com.j.joker.mapper.TUserMapper;
import com.j.joker.mapper.UsernameCredentialMapper;
import com.j.joker.model.TUser;
import com.j.joker.service.player.PlayerService;
import com.j.joker.utils.InfServerException;
import com.j.joker.vo.response.user.LoginVo;
import java.nio.charset.StandardCharsets;
import java.util.Locale;
import java.util.regex.Pattern;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.security.crypto.password.Pbkdf2PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
public class UsernameService {
    private static final Pattern NAME = Pattern.compile("[A-Za-z][A-Za-z0-9_]{2,19}");
    private final Pbkdf2PasswordEncoder passwords = Pbkdf2PasswordEncoder.defaultsForSpringSecurity_v5_8();
    private final String dummyHash = passwords.encode("unused-timing-placeholder");
    private final UsernameCredentialMapper credentials;
    private final TUserMapper users;
    private final PlayerService players;
    private final UserService sessions;

    public UsernameService(UsernameCredentialMapper credentials, TUserMapper users, PlayerService players, UserService sessions) {
        this.credentials = credentials;
        this.users = users;
        this.players = players;
        this.sessions = sessions;
    }

    public void register(String username, String password) {
        String name = validate(username, password);
        if (credentials.find(name) != null) {
            throw failure("用户名已被使用");
        }
        String hash = passwords.encode(password);
        long id = players.createUsernamePlayer(name);
        try {
            credentials.insert(name, id, hash);
        } catch (DuplicateKeyException e) {
            throw failure("用户名已被使用");
        }
    }

    public LoginVo login(String username, String password, int device) throws Exception {
        String name = validate(username, password);
        var credential = credentials.find(name);
        boolean matches = passwords.matches(password, credential == null ? dummyHash : credential.passwordHash());
        if (!matches || credential == null) {
            throw failure("用户名或密码错误");
        }
        TUser user = users.findById(credential.userId());
        if (user == null || !Constants.USER_NOT_DEPRECATED.equals(user.getDeprecated())) {
            throw failure("用户名或密码错误");
        }
        return sessions.finishLogin(user, device, null, null, null);
    }

    private String validate(String username, String password) {
        if (username == null || !NAME.matcher(username).matches()) {
            throw failure("用户名须为3至20位，以英文字母开头，可含字母、数字和下划线");
        }
        int bytes = password == null ? 0 : password.getBytes(StandardCharsets.UTF_8).length;
        if (bytes < 8 || bytes > 64 || password.isBlank()) {
            throw failure("密码长度须为8至64字节");
        }
        return username.toLowerCase(Locale.ROOT);
    }

    private static InfServerException failure(String message) {
        return new InfServerException(Constants.RETURN_CODE_FAIL, message);
    }
}
