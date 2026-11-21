package com.core.config;

import org.apache.log4j.PropertyConfigurator;

import javax.servlet.ServletContext;
import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

public class Log4jInitListener implements ServletContextListener {

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        ServletContext context = sce.getServletContext();
        
        // 获取 webapp 根目录路径
        String webAppRoot = context.getRealPath("/");
        if (webAppRoot == null) {
            // 如果 getRealPath 返回 null，使用当前工作目录
            webAppRoot = System.getProperty("user.dir");
        }
        
        // 设置 webapp.root 系统属性
        System.setProperty("webapp.root", webAppRoot);
        
        try {
            // 尝试从 classpath 加载
            InputStream is = getClass().getClassLoader().getResourceAsStream("log4j.properties");
            if (is != null) {
                Properties props = new Properties();
                props.load(is);
                is.close();

                // 确保日志目录存在
                File logDir = new File(webAppRoot, "logs");
                if (!logDir.exists()) {
                    logDir.mkdirs();
                }

                PropertyConfigurator.configure(props);
                System.out.println("Log4j initialized successfully from classpath, webapp.root=" + webAppRoot);
            } else {
                System.out.println("log4j.properties not found in classpath");
            }
        } catch (IOException e) {
            e.printStackTrace();
            System.out.println("Failed to initialize Log4j: " + e.getMessage());
        }
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        // 清理资源
    }
}
