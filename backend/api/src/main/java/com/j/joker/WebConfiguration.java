package com.j.joker;

import com.alibaba.druid.support.jakarta.WebStatFilter;
import com.j.joker.interceptor.TokenInterceptor;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import org.springframework.boot.web.embedded.tomcat.TomcatServletWebServerFactory;
import org.springframework.boot.web.server.WebServerFactoryCustomizer;
import org.springframework.boot.web.servlet.FilterRegistrationBean;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.io.Resource;
import org.springframework.core.io.support.PathMatchingResourcePatternResolver;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration(proxyBeanMethods = false)
class WebConfiguration implements WebMvcConfigurer {
    private final TokenInterceptor tokenInterceptor;

    WebConfiguration(TokenInterceptor tokenInterceptor) {
        this.tokenInterceptor = tokenInterceptor;
    }

    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(tokenInterceptor).excludePathPatterns(
                "/", "/playerUser/OAuthCheck", "/playerUser/quickRegister", "/playerUser/quickRegisterByPhone",
                "/playerUser/username/register", "/playerUser/username/login",
                "/playerUser/username/changePassword", "/playerUser/username/resetPassword",
                "/playerUser/uploadPhoto", "/userLogin", "/sfPay/*Callback*", "/sfPay/rongZhouPayOrder",
                "/payOrderCallback", "/version/queryVersion", "/roomCard/deductCard", "/freeGame/A2IcreateFreeGame");
    }

    @Bean
    FilterRegistrationBean<WebStatFilter> druidStatistics() {
        var filter = new FilterRegistrationBean<>(new WebStatFilter());
        filter.addInitParameter("exclusions", "*.js,*.gif,*.jpg,*.png,*.css,*.ico,/druid/*");
        return filter;
    }

    // Jasper needs a filesystem document root. Only unpack the application's JSP resources.
    @Bean
    WebServerFactoryCustomizer<TomcatServletWebServerFactory> jspDocumentRoot() throws IOException {
        Path root = Files.createTempDirectory("joker-jsp-");
        root.toFile().deleteOnExit();
        var resolver = new PathMatchingResourcePatternResolver();
        for (Resource jsp : resolver.getResources("classpath*:jsp/**/*.jsp")) {
            String location = jsp.getURL().toExternalForm();
            Path target = root.resolve(location.substring(location.lastIndexOf("/jsp/") + 5)).normalize();
            if (!target.startsWith(root)) {
                throw new IOException("Invalid packaged JSP path");
            }
            Files.createDirectories(target.getParent());
            target.getParent().toFile().deleteOnExit();
            try (var stream = jsp.getInputStream()) {
                Files.copy(stream, target);
            }
            target.toFile().deleteOnExit();
        }
        return factory -> factory.setDocumentRoot(root.toFile());
    }
}
