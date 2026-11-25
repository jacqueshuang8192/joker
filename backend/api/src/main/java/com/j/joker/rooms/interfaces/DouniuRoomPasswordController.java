package com.j.joker.rooms.interfaces;

import lombok.RequiredArgsConstructor;
import com.j.joker.rooms.application.DouniuRoomPasswordService;
import com.j.joker.utils.InfServerException;
import com.j.joker.vo.response.Response;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
public class DouniuRoomPasswordController {
    private final DouniuRoomPasswordService passwords;

    @PostMapping("/freeGame/unlockDouniuRoom")
    public Response unlock(@RequestParam("XYUid") long uid, @RequestParam("XYToken") String token,
                           @RequestParam("activityId") long activity, @RequestParam("password") String password) {
        Response result = new Response();
        try {
            passwords.unlock(uid, token, activity, password);
        } catch (InfServerException denied) {
            result.setReturnCode(denied.getErrorCode());
            result.setError(denied.getErrorMsg());
        }
        return result;
    }
}
