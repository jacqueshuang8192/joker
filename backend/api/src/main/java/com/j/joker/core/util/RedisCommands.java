package com.j.joker.core.util;

import java.time.Duration;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.function.Function;
import org.apache.log4j.Logger;
import redis.clients.jedis.Jedis;
import redis.clients.jedis.JedisPool;
import redis.clients.jedis.JedisPoolConfig;
import redis.clients.jedis.args.ListPosition;

/** Redis commands shared by the game's three configurable connections. */
public abstract class RedisCommands {
    private final Logger logger = Logger.getLogger(getClass());
    private final JedisPool pool;

    RedisCommands(String port) {
        var config = new JedisPoolConfig();
        config.setMaxTotal(100000);
        config.setMaxIdle(20000);
        config.setMaxWait(Duration.ofSeconds(100));
        config.setTestOnBorrow(true);
        String host = ConfigUtil.get("redis.ip");
        int redisPort = Integer.parseInt(port);
        pool = GameRedisPool.create(config, host, redisPort, 100000);
    }

    final <T> T execute(Function<Jedis, T> command, T onFailure) {
        try (Jedis jedis = pool.getResource()) {
            return command.apply(jedis);
        } catch (Exception e) {
            logger.error(e.getMessage());
            return onFailure;
        }
    }

    public static void returnResource(JedisPool pool, Jedis jedis) {
        if (jedis != null) {
            jedis.close();
        }
    }

    public String get(String key) {
        return execute(jedis -> jedis.get(key), null);
    }

    public String set(String key, String value) {
        return execute(jedis -> jedis.set(key, value), "0");
    }

    public Long del(String... keys) {
        return execute(jedis -> jedis.del(keys), 0L);
    }

    public Long append(String key, String str) {
        return execute(jedis -> jedis.append(key, str), 0L);
    }

    public Boolean exists(String key) {
        return execute(jedis -> jedis.exists(key), false);
    }

    public Long setnx(String key, String value) {
        return execute(jedis -> jedis.setnx(key, value), 0L);
    }

    public String setex(String key, String value, int seconds) {
        return execute(jedis -> jedis.setex(key, seconds, value), null);
    }

    public Long setrange(String key, String str, int offset) {
        return execute(jedis -> jedis.setrange(key, offset, str), 0L);
    }

    public List<String> mget(String... keys) {
        return execute(jedis -> jedis.mget(keys), null);
    }

    public String mset(String... keysvalues) {
        return execute(jedis -> jedis.mset(keysvalues), null);
    }

    public Long msetnx(String... keysvalues) {
        return execute(jedis -> jedis.msetnx(keysvalues), 0L);
    }

    public String getset(String key, String value) {
        return execute(jedis -> jedis.getSet(key, value), null);
    }

    public String getrange(String key, int startOffset, int endOffset) {
        return execute(jedis -> jedis.getrange(key, startOffset, endOffset), null);
    }

    public Long incr(String key) {
        return execute(jedis -> jedis.incr(key), null);
    }

    public Long incrBy(String key, Long integer) {
        return execute(jedis -> jedis.incrBy(key, integer), null);
    }

    public Long decr(String key) {
        return execute(jedis -> jedis.decr(key), null);
    }

    public Long decrBy(String key, Long integer) {
        return execute(jedis -> jedis.decrBy(key, integer), null);
    }

    public Long serlen(String key) {
        return execute(jedis -> jedis.strlen(key), null);
    }

    public Long hset(String key, String field, String value) {
        return execute(jedis -> jedis.hset(key, field, value), null);
    }

    public Long hsetnx(String key, String field, String value) {
        return execute(jedis -> jedis.hsetnx(key, field, value), null);
    }

    public String hmset(String key, Map<String, String> hash) {
        return execute(jedis -> jedis.hmset(key, hash), null);
    }

    public String hget(String key, String field) {
        return execute(jedis -> jedis.hget(key, field), null);
    }

    public List<String> hmget(String key, String... fields) {
        return execute(jedis -> jedis.hmget(key, fields), null);
    }

    public Long hincrby(String key, String field, Long value) {
        return execute(jedis -> jedis.hincrBy(key, field, value), null);
    }

    public Boolean hexists(String key, String field) {
        return execute(jedis -> jedis.hexists(key, field), false);
    }

    public Long hlen(String key) {
        return execute(jedis -> jedis.hlen(key), null);
    }

    public Long hdel(String key, String... fields) {
        return execute(jedis -> jedis.hdel(key, fields), null);
    }

    public Set<String> hkeys(String key) {
        return execute(jedis -> jedis.hkeys(key), null);
    }

    public List<String> hvals(String key) {
        return execute(jedis -> jedis.hvals(key), null);
    }

    public Map<String, String> hgetall(String key) {
        return execute(jedis -> jedis.hgetAll(key), null);
    }

    public Long lpush(String key, String... strs) {
        return execute(jedis -> jedis.lpush(key, strs), null);
    }

    public Long rpush(String key, String... strs) {
        return execute(jedis -> jedis.rpush(key, strs), null);
    }

    public Long linsert(String key, ListPosition where, String pivot, String value) {
        return execute(jedis -> jedis.linsert(key, where, pivot, value), null);
    }

    public String lset(String key, Long index, String value) {
        return execute(jedis -> jedis.lset(key, index, value), null);
    }

    public Long lrem(String key, long count, String value) {
        return execute(jedis -> jedis.lrem(key, count, value), null);
    }

    public String ltrim(String key, long start, long end) {
        return execute(jedis -> jedis.ltrim(key, start, end), null);
    }

    public synchronized String lpop(String key) {
        return execute(jedis -> jedis.lpop(key), null);
    }

    public synchronized String rpop(String key) {
        return execute(jedis -> jedis.rpop(key), null);
    }

    public String rpoplpush(String srckey, String dstkey) {
        return execute(jedis -> jedis.rpoplpush(srckey, dstkey), null);
    }

    public String lindex(String key, long index) {
        return execute(jedis -> jedis.lindex(key, index), null);
    }

    public Long llen(String key) {
        return execute(jedis -> jedis.llen(key), null);
    }

    public List<String> lrange(String key, long start, long end) {
        return execute(jedis -> jedis.lrange(key, start, end), null);
    }

    public Long sadd(String key, String... members) {
        return execute(jedis -> jedis.sadd(key, members), null);
    }

    public Long srem(String key, String... members) {
        return execute(jedis -> jedis.srem(key, members), null);
    }

    public String spop(String key) {
        return execute(jedis -> jedis.spop(key), null);
    }

    public Set<String> sdiff(String... keys) {
        return execute(jedis -> jedis.sdiff(keys), null);
    }

    public Long sdiffstore(String dstkey, String... keys) {
        return execute(jedis -> jedis.sdiffstore(dstkey, keys), null);
    }

    public Set<String> sinter(String... keys) {
        return execute(jedis -> jedis.sinter(keys), null);
    }

    public Long sinterstore(String dstkey, String... keys) {
        return execute(jedis -> jedis.sinterstore(dstkey, keys), null);
    }

    public Set<String> sunion(String... keys) {
        return execute(jedis -> jedis.sunion(keys), null);
    }

    public Long sunionstore(String dstkey, String... keys) {
        return execute(jedis -> jedis.sunionstore(dstkey, keys), null);
    }

    public Long smove(String srckey, String dstkey, String member) {
        return execute(jedis -> jedis.smove(srckey, dstkey, member), null);
    }

    public Long scard(String key) {
        return execute(jedis -> jedis.scard(key), null);
    }

    public Boolean sismember(String key, String member) {
        return execute(jedis -> jedis.sismember(key, member), null);
    }

    public String srandmember(String key) {
        return execute(jedis -> jedis.srandmember(key), null);
    }

    public Set<String> smembers(String key) {
        return execute(jedis -> jedis.smembers(key), null);
    }

    public Long zadd(String key, double score, String member) {
        return execute(jedis -> jedis.zadd(key, score, member), null);
    }

    public Long zrem(String key, String... members) {
        return execute(jedis -> jedis.zrem(key, members), null);
    }

    public Double zincrby(String key, double score, String member) {
        return execute(jedis -> jedis.zincrby(key, score, member), null);
    }

    public Long zrank(String key, String member) {
        return execute(jedis -> jedis.zrank(key, member), null);
    }

    public Long zrevrank(String key, String member) {
        return execute(jedis -> jedis.zrevrank(key, member), null);
    }

    public Set<String> zrevrange(String key, long start, long end) {
        return execute(jedis -> new LinkedHashSet<>(jedis.zrevrange(key, start, end)), null);
    }

    public Set<String> zrangebyscore(String key, String max, String min) {
        return execute(jedis -> new LinkedHashSet<>(jedis.zrevrangeByScore(key, max, min)), null);
    }

    public Set<String> zrangeByScore(String key, double max, double min) {
        return execute(jedis -> new LinkedHashSet<>(jedis.zrevrangeByScore(key, max, min)), null);
    }

    public Long zcount(String key, String min, String max) {
        return execute(jedis -> jedis.zcount(key, min, max), null);
    }

    public Long zcard(String key) {
        return execute(jedis -> jedis.zcard(key), null);
    }

    public Double zscore(String key, String member) {
        return execute(jedis -> jedis.zscore(key, member), null);
    }

    public Long zremrangeByRank(String key, long start, long end) {
        return execute(jedis -> jedis.zremrangeByRank(key, start, end), null);
    }

    public Long zremrangeByScore(String key, double start, double end) {
        return execute(jedis -> jedis.zremrangeByScore(key, start, end), null);
    }

    public Set<String> keys(String pattern) {
        return execute(jedis -> jedis.keys(pattern), null);
    }

    public String type(String key) {
        return execute(jedis -> jedis.type(key), null);
    }
}
