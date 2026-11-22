package com.j.joker.server;

import java.io.IOException;

import org.mortbay.jetty.Connector;
import org.mortbay.jetty.Server;
import org.mortbay.jetty.nio.SelectChannelConnector;
import org.mortbay.jetty.webapp.WebAppContext;


class JettyServer {

    int port = 8080;
    String webContext = "/hbi_interface";
    String resourceBase = "./src/main/webapp";

    public JettyServer(String configFile) throws IOException {
    }

    public void startServer() {
        try{
            Server server = new Server();
            Connector connector = new SelectChannelConnector();
            connector.setPort(port);
            server.setConnectors(new Connector[] { connector });
            WebAppContext webapp = new WebAppContext();
            webapp.setContextPath(webContext);
            webapp.setResourceBase(resourceBase);
            server.setHandler(webapp);
            server.start();
            server.join();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}

/**
 * 
  * @author liangxx(xxliang@travelsky.com) 2013-11-20
  * @version 1.0
  * @modifyed by liangxx(xxliang@travelsky.com) description
  * @Function 类功能说明
 */
public class StartApplication {
    /**
     * 
      * main(这里用一句话描述这个方法的作用)
      * @param args
      * @throws Exception
     */
    public static void main(String[] args) throws Exception {
        JettyServer server = new JettyServer(null);
        server.startServer();
    }
}
