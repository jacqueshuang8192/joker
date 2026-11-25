package com.j.joker.service.common;

import com.j.joker.cache.CacheManager;
import com.j.joker.constants.Constants;
import com.j.joker.mapper.TUserMapper;
import com.j.joker.mapper.UsernameCredentialMapper;
import com.j.joker.model.TUser;
import com.j.joker.service.player.PlayerService;
import com.j.joker.utils.InfServerException;
import com.j.joker.vo.response.user.LoginVo;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.util.HexFormat;
import java.util.Locale;
import org.apache.commons.codec.digest.DigestUtils;
import java.util.regex.Pattern;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.security.crypto.password.Pbkdf2PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
public class UsernameService {
    private static final SecureRandom RANDOM = new SecureRandom();
    public record Login(LoginVo session, String recoveryCode) {}

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

    public String register(String username, String password, boolean enroll) {
        String name = validate(username, password);
        if (credentials.countByName(name) != 0) {
            throw failure("用户名已被使用");
        }
        String hash = passwords.encode(password);
        String code = enroll ? newCode() : null;
        long id = players.createUsernamePlayer(name);
        try {
            credentials.insert(name, id, hash, code == null ? null : digest(code));
        } catch (DuplicateKeyException e) {
            throw failure("用户名已被使用");
        }
        return code;
    }

    public Login login(String username, String password, int device, boolean enroll) throws Exception {
        String name = validate(username, password);
        var credential = credentials.lock(name);
        boolean matches = passwords.matches(password, credential == null ? dummyHash : credential.passwordHash());
        if (!matches || credential == null) {
            throw failure("用户名或密码错误");
        }
        TUser user = users.findById(credential.userId());
        if (user == null || !Constants.USER_NOT_DEPRECATED.equals(user.getDeprecated())) {
            throw failure("用户名或密码错误");
        }
        var session = sessions.finishLogin(user, device, null, null, null);
        String code = null;
        if (enroll && credential.recoveryHash() == null) {
            code = newCode();
            credentials.enroll(credential.userId(),digest(code));
        }
        return new Login(session,code);
    }

    public String change(String username, String oldPassword, String newPassword) {
        String name = validate(username,newPassword);
        validate(name,oldPassword);
        var credential = credentials.lock(name);
        boolean matches = passwords.matches(oldPassword, credential == null ? dummyHash : credential.passwordHash());
        if (!matches || credential == null) throw failure("用户名或原密码错误");
        if (oldPassword.equals(newPassword)) throw failure("新密码须与原密码不同");
        return replace(credential,newPassword);
    }

    public String reset(String username, String code, String newPassword) {
        String name = validate(username,newPassword);
        String compact = code == null || code.length()>80 ? "" : code.replace("-","").replace(" ","").toUpperCase(Locale.ROOT);
        if (!compact.matches("[0-9A-F]{32}")) throw failure("用户名或恢复码无效");
        var credential = credentials.lock(name);
        if (credential == null || credential.recoveryHash() == null ||
                !MessageDigest.isEqual(credential.recoveryHash(),digest(compact))) throw failure("用户名或恢复码无效");
        return replace(credential,newPassword);
    }

    private String replace(UsernameCredentialMapper.Credential credential, String password) {
        String code = newCode();
        credentials.replace(credential.userId(),passwords.encode(password),digest(code));
        // 登录和两种改密操作均持有本账号的行锁。撤销失败时服务事务回滚，可以用原凭据重试。
        var cache = CacheManager.getCache();
        try { cache.del("TOKEN_" + credential.userId()); }
        finally { CacheManager.releaseCache(cache); }
        return code;
    }

    private static String newCode() {
        byte[] entropy = new byte[16];
        RANDOM.nextBytes(entropy);
        return HexFormat.of().withUpperCase().formatHex(entropy);
    }

    private static byte[] digest(String code) {
        return DigestUtils.sha256(code.getBytes(StandardCharsets.US_ASCII));
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
