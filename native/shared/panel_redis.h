#pragma once

#include <hiredis.h>
#include <cstdlib>
#include <cstring>

// The container launcher supplies one panel endpoint for every logical game connection.
inline redisContext* connectGameRedis(const char* host, int port, const char* password = "") {
    const char* user = NULL;
    const char* panelHost = std::getenv("JOKER_REDIS_HOST");
    if (panelHost != NULL) {
        host = panelHost;
        port = std::atoi(std::getenv("JOKER_REDIS_PORT"));
        password = std::getenv("JOKER_REDIS_PASSWORD");
        user = std::getenv("JOKER_REDIS_USER");
    }
    redisContext* connection = redisConnect(host, port);
    if (!connection || connection->err || !password || !*password) return connection;

    const char* args[] = {"AUTH", password, NULL};
    int count = 2;
    if (user && *user) {
        args[1] = user;
        args[2] = password;
        count = 3;
    }
    redisReply* reply = static_cast<redisReply*>(redisCommandArgv(connection, count, args, NULL));
    if (!reply || reply->type != REDIS_REPLY_STATUS || std::strcmp(reply->str, "OK") != 0) {
        connection->err = REDIS_ERR_OTHER;
        std::strcpy(connection->errstr, "Redis authentication failed");
    }
    if (reply) freeReplyObject(reply);
    return connection;
}
