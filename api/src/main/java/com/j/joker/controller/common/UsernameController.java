package com.j.joker.controller.common;

import com.j.joker.constants.Constants;
import com.j.joker.service.common.UsernameService;
import com.j.joker.utils.InfServerException;
import com.j.joker.vo.response.Response;
import java.util.Map;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/playerUser/username")
public class UsernameController {
    private final UsernameService usernames;

    public UsernameController(UsernameService usernames) {
        this.usernames = usernames;
    }

    public record Credentials(String username, String password, Integer device) {}

    @PostMapping(value = "/register", consumes = "application/json")
    public Response register(@RequestBody Credentials input) {
        usernames.register(input.username(), input.password());
        return new Response();
    }

    @PostMapping(value = "/login", consumes = "application/json")
    public Response login(@RequestBody Credentials input) throws Exception {
        var session = usernames.login(input.username(), input.password(), input.device() == null ? 3 : input.device());
        Response response = new Response();
        response.setData(Map.of("userId", session.getUserid(), "token", session.getToken()));
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
