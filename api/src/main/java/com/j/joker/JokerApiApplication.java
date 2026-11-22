package com.j.joker;

import io.swagger.v3.oas.annotations.OpenAPIDefinition;
import io.swagger.v3.oas.annotations.info.Info;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.mongo.MongoAutoConfiguration;
import org.springframework.boot.autoconfigure.quartz.QuartzAutoConfiguration;
import org.springframework.context.annotation.ImportResource;

@SpringBootApplication(exclude = {QuartzAutoConfiguration.class, MongoAutoConfiguration.class})
@ImportResource({"classpath:applicationContext.xml", "classpath:applicationContext-quartz.xml"})
@OpenAPIDefinition(info = @Info(title = "富湘系统API接口管理", version = "1.0"))
public class JokerApiApplication {
    public static void main(String[] args) {
        SpringApplication.run(JokerApiApplication.class, args);
    }
}
