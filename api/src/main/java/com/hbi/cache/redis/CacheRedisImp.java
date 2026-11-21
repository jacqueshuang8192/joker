package com.hbi.cache.redis;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import com.alibaba.fastjson.JSON;
import com.core.util.ApplicationContextHelper;
import com.hbi.cache.ICache;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import redis.clients.jedis.BinaryClient.LIST_POSITION;
import redis.clients.jedis.ShardedJedis;
import redis.clients.jedis.ShardedJedisPool;

public class CacheRedisImp implements ICache {

	private static ShardedJedisPool pool;
	private static final Log log = LogFactory.getLog(CacheRedisImp.class);
	private ShardedJedis jedis;

	private static final String RESULT_OK = "OK";

	private static final int RESULT_OK_CODE = 1;

	private CacheRedisImp() {

	}

	static {
//		ApplicationContext context = new ClassPathXmlApplicationContext("applicationContext.xml");
//
//		pool = (ShardedJedisPool)context.getBean("jedis");
		try {
//			System.out.println("redis--->start");
			pool = (ShardedJedisPool)ApplicationContextHelper.getBean("jedis");
		} catch (Exception e) {
			new CacheRedisImp();//防止静态代码块抛异常导致没有被类加载器加载
		}
	}

	public static CacheRedisImp getInstance() {
		if (pool == null) {
			pool = (ShardedJedisPool)ApplicationContextHelper.getBean("jedis");
		}
		CacheRedisImp instance = new CacheRedisImp();

		instance.jedis = pool.getResource();
		return instance;
	}

	@SuppressWarnings("deprecation")
	public static void releaseCache(CacheRedisImp imp) {
//		pool.returnResource(imp.jedis);
		imp.jedis.close();
	}

	@Override
	public boolean set(String key, String value) {
		// TODO Auto-generated method stub
		return RESULT_OK.equals(jedis.set(key, value));
	}

	@Override
	public String get(String key) {
		// TODO Auto-generated method stub
		return jedis.get(key);
	}

	@Override
	public boolean setObj(String key, Object value) {
		// TODO Auto-generated method stub
		return RESULT_OK.equals(jedis.set(key, JSON.toJSONString(value)));
	}

	@Override
	public <T> T getObj(String key, Class<T> clazz) {
		// TODO Auto-generated method stub
		return JSON.parseObject(jedis.get(key), clazz);
	}

	@Override
    public Long hlen(String key) {
        return jedis.hlen(key);
    }

	@Override
	public List<String> lgetAll(String key) {
		// TODO Auto-generated method stub
		return jedis.lrange(key, 0, -1);
	}

	@Override
	public Long del(String key) {
		// TODO Auto-generated method stub
		return jedis.del(key);
	}

	@Override
	public Long hset(String key, String field, String value) {
		// TODO Auto-generated method stub
		return jedis.hset(key, field, value);
	}

	@Override
	public String hget(String key, String field) {
		// TODO Auto-generated method stub
		return jedis.hget(key, field);
	}

	@Override
	public Long hsetObj(String key, String field, Object value) {
		// TODO Auto-generated method stub
		return jedis.hset(key, field, JSON.toJSONString(value));
	}

	@Override
	public <T> T hgetObj(String key, String field, Class<T> clazz) {
		// TODO Auto-generated method stub
		return JSON.parseObject(jedis.hget(key, field), clazz);
	}

	@Override
	public boolean hmset(String key, Map<String, String> keyValues) {
		// TODO Auto-generated method stub
		return RESULT_OK.equals(jedis.hmset(key, keyValues));
	}

	@Override
	public List<String> hmget(String key, String... fields) {
		// TODO Auto-generated method stub
		return jedis.hmget(key, fields);
	}

	@Override
	public boolean hmsetObjects(String key, Map<String, Object> keyValues) {
		// TODO Auto-generated method stub
		Map<String, String> map = new HashMap<String, String>();

		for (String keyTemp : keyValues.keySet()) {
			map.put(keyTemp, JSON.toJSONString(keyValues.get(keyTemp)));
		}

		return RESULT_OK.equals(jedis.hmset(key, map));
	}

	@Override
	public <T> List<T> hmgetObjects(String key, Class<T> clazz, String... fields) {
		// TODO Auto-generated method stub
		List<String> jsonStrs = jedis.hmget(key, fields);

		if (jsonStrs != null) {
			List<T> list = new ArrayList<T>();
			for (String json : jsonStrs) {
				list.add(JSON.parseObject(json, clazz));
			}

			return list;
		}

		return null;
	}

	@Override
	public Long hincrby(String key, String field, int num) {
		// TODO Auto-generated method stub
		return jedis.hincrBy(key, field, num);
	}

	@Override
	public boolean hdel(String key, String... fields) {
		// TODO Auto-generated method stub
		return jedis.hdel(key, fields) == RESULT_OK_CODE;
	}

	@Override
	public Map<String, String> hgetAll(String key) {
		// TODO Auto-generated method stub
		return jedis.hgetAll(key);
	}

	@Override
	public <T> Map<String, T> hgetAll(String key, Class<T> clazz) {
		Map<String, String> strMap = jedis.hgetAll(key);

		Map<String, T> result = new HashMap<String, T>();
		for (String keyT : strMap.keySet()) {
			result.put(keyT, JSON.parseObject(strMap.get(keyT), clazz));
		}

		return result;
	}

	@Override
	public Long lpush(String key, String... values) {
		// TODO Auto-generated method stub
		return jedis.lpush(key, values);
	}

	@Override
	public Long rpush(String key, String... values) {
		// TODO Auto-generated method stub
		return jedis.rpush(key, values);
	}

	@Override
	public Long rpush(String key, List<String> list) {
	    String[] values = list.toArray(new String[list.size()]);
	    return jedis.rpush(key, values);
	}

	@Override
	public String lpop(String key) {
		// TODO Auto-generated method stub
		return jedis.lpop(key);
	}

	@Override
	public String rpop(String key) {
		// TODO Auto-generated method stub
		return jedis.rpop(key);
	}

	@Override
	public String lindex(String key, int index) {
		// TODO Auto-generated method stub
		return jedis.lindex(key, index);
	}

	@Override
	public long llen(String key) {
		// TODO Auto-generated method stub
		return jedis.llen(key);
	}

	@Override
	public Long linsertAfter(String key, String pivot, String value) {
		// TODO Auto-generated method stub
		return jedis.linsert(key, LIST_POSITION.AFTER, pivot, value);
	}

	@Override
	public Long linsertBefore(String key, String pivot, String value) {
		// TODO Auto-generated method stub
		return jedis.linsert(key, LIST_POSITION.BEFORE, pivot, value);
	}

	@Override
	public Long lrem(String key, long count, String value) {
		// TODO Auto-generated method stub
		return jedis.lrem(key, count, value);
	}

	@Override
	public boolean lset(String key, long index, String value) {
		// TODO Auto-generated method stub
		return jedis.lset(key, index, value).equals(RESULT_OK);
	}

    @Override
    public Set<String> keys(String key) {
        // TODO Auto-generated method stub
        return jedis.getShard("").keys(key);
    }

    @Override
    public Long sadd(String key, String... members) {
        // TODO Auto-generated method stub
        return jedis.sadd(key, members);
    }

    @Override
    public Set<String> smembers(String key) {
        // TODO Auto-generated method stub
        return jedis.smembers(key);
    }

    @Override
    public Long srem(String key, String... members) {
        // TODO Auto-generated method stub
        return jedis.srem(key, members);
    }

    @Override
    public Boolean sismember(String key, String member) {
        // TODO Auto-generated method stub
        return jedis.sismember(key, member);
    }

	@Override
	public Long setnx(String key, String value) {
		return jedis.setnx(key, value);
	}

	@Override
	public Long expire(String key, int seconds) {
		return jedis.expire(key, seconds);
	}

	@Override
	public boolean exist(String key) {
		return jedis.exists(key);
	}

	@Override
	public String setex(String key, int seconds, String value) {
		return jedis.setex(key, seconds,value);
	}


}
