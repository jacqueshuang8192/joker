package com.j.joker.controller.common;

import com.j.joker.constants.Constants;
import com.j.joker.service.common.UsernameService;
import com.j.joker.utils.InfServerException;
import com.j.joker.vo.response.Response;
import java.util.LinkedHashMap;
import java.util.Map;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/playerUser/username")
public class UsernameController {
    private final UsernameService usernames;

    public UsernameController(UsernameService usernames) {
        this.usernames = usernames;
    }

    public record Credentials(String username, String password, Integer device, boolean requestRecoveryCode) {}

    public record Change(String username, String oldPassword, String newPassword) {}
    public record Reset(String username, String recoveryCode, String newPassword) {}

    @ModelAttribute
    public void preventCaching(HttpServletResponse response) {
        response.setHeader("Cache-Control","no-store");
    }

    private Response recovery(String code) {
        var reply = new Response();
        if (code != null) reply.setData(Map.of("recoveryCode",code));
        return reply;
    }

    @PostMapping(value = "/changePassword", consumes = "application/json")
    public Response change(@RequestBody Change input) {
        return recovery(usernames.change(input.username(),input.oldPassword(),input.newPassword()));
    }

    @PostMapping(value = "/resetPassword", consumes = "application/json")
    public Response reset(@RequestBody Reset input) {
        return recovery(usernames.reset(input.username(),input.recoveryCode(),input.newPassword()));
    }

    @PostMapping(value = "/register", consumes = "application/json")
    public Response register(@RequestBody Credentials input) {
        return recovery(usernames.register(input.username(),input.password(),input.requestRecoveryCode()));
    }

    @PostMapping(value = "/login", consumes = "application/json")
    public Response login(@RequestBody Credentials input) throws Exception {
        var login = usernames.login(input.username(),input.password(),input.device()==null ? 3 : input.device(),input.requestRecoveryCode());
        Response response = new Response();
        var data = new LinkedHashMap<String,Object>();
        data.put("userId",login.session().getUserid());
        data.put("token",login.session().getToken());
        if (login.recoveryCode()!=null) data.put("recoveryCode",login.recoveryCode());
        response.setData(data);
        return response;
    }

    @ExceptionHandler(InfServerException.class)
    public Response failure(InfServerException ex) {
        Response response = new Response();
        response.setReturnCode(Constants.RETURN_CODE_FAIL);
        response.setError(ex.getErrorMsg());
        return response;
    }
}
