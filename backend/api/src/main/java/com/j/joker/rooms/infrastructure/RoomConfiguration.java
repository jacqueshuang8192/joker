package com.j.joker.rooms.infrastructure;

import com.j.joker.rooms.application.DouniuRoomPasswordService;
import com.j.joker.rooms.application.RoomPasswords;
import com.j.joker.rooms.application.RoomUnlocks;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.env.Environment;
import org.springframework.security.crypto.password.Pbkdf2PasswordEncoder;

@Configuration(proxyBeanMethods = false)
class RoomConfiguration {
    @Bean
    DouniuRoomPasswordService roomPasswordsService(RoomPasswords passwords, RoomUnlocks unlocks, Environment env) {
        return new DouniuRoomPasswordService(passwords, unlocks, Pbkdf2PasswordEncoder.defaultsForSpringSecurity_v5_8(),
                "game-java".equals(env.getProperty("JOKER_DOUNIU_RUNTIME")));
    }
}
