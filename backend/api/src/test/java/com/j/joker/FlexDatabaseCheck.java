package com.j.joker;

import com.j.joker.core.util.RedisCommands;
import com.j.joker.core.util.RedisUtil;
import com.j.joker.core.util.RedisUtil1;
import com.j.joker.core.util.RedisUtil3;
import com.j.joker.cache.CacheManager;
import com.j.joker.cache.cacheWritter.BaseCacheLoader;
import com.j.joker.cache.controller.BaseCacheController;
import com.j.joker.mapper.LandlordScoreSectionMapper;
import com.j.joker.model.LandlordScoreSection;
import com.j.joker.mapper.TFeedbackMapper;
import com.j.joker.mapper.TGiftPointMapper;
import com.j.joker.mapper.TActivityUserMapper;
import com.j.joker.mapper.TUserMapper;
import com.j.joker.model.TFeedback;
import com.j.joker.model.TGiftPoint;
import com.j.joker.model.TActivityUser;
import com.j.joker.model.TUser;
import com.j.joker.mapper.ImsTpOrdersMapper;
import com.j.joker.mapper.TConfigMapper;
import com.j.joker.mapper.TFreeGameResultMapper;
import com.j.joker.mapper.TFreeGameTotalMapper;
import com.j.joker.mapper.TGroupGameconfigMapper;
import com.j.joker.mapper.TVersionMapper;
import com.j.joker.model.ImsTpOrders;
import com.j.joker.model.TConfig;
import com.j.joker.model.TFreeGameTotal;
import com.j.joker.model.TGroupGameconfig;
import com.j.joker.model.TVersion;
import com.mybatisflex.core.mybatis.FlexConfiguration;
import com.mybatisflex.core.query.QueryWrapper;
import org.apache.ibatis.exceptions.TooManyResultsException;
import org.apache.ibatis.session.SqlSessionFactory;
import org.springframework.context.support.ClassPathXmlApplicationContext;
import org.springframework.context.support.PropertySourcesPlaceholderConfigurer;
import org.springframework.core.io.FileSystemResource;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.support.TransactionTemplate;

import static com.mybatisflex.core.query.QueryMethods.column;

/** Runs against the disposable, migrated MySQL database in backend/tests/smoke.sh. */
public class FlexDatabaseCheck {
    public static void main(String[] args) {
        var properties = new PropertySourcesPlaceholderConfigurer();
        properties.setLocation(new FileSystemResource(System.getenv("JOKER_CONFIG")));
        try (var context = new ClassPathXmlApplicationContext()) {
            context.addBeanFactoryPostProcessor(properties);
            context.setConfigLocation("classpath:applicationContext.xml");
            context.refresh();
            var factory = context.getBean(SqlSessionFactory.class);
            require(factory.getConfiguration() instanceof FlexConfiguration, "Flex session factory");
            var games = context.getBean(TGroupGameconfigMapper.class);
            var results = context.getBean(TFreeGameResultMapper.class);
            var filter = new TGroupGameconfig();
            filter.setGroupId(42);
            var tx = new TransactionTemplate(context.getBean(PlatformTransactionManager.class));
            checkRedisCommands();
            tx.executeWithoutResult(status -> {
                checkEntityMigration(context);
                checkScoreCache(context);
                checkGameConfig(games, filter);
                checkHallQueries(context);
                checkRankings(context.getBean(TFreeGameTotalMapper.class));
                checkOrders(context.getBean(ImsTpOrdersMapper.class));
                checkCompositeKey(context.getBean(TConfigMapper.class));
                checkTransientColumns(context.getBean(TVersionMapper.class));
                results.insertPlayerResult(3, 43, "42", "1", 0, "2020-01-01 00:00:00", 42);
                results.updatePlayerResult(3, "2", 43, "42");
                require(results.selectPlayerResult(3, 43, "42") == 2, "sharded XML update");
                status.setRollbackOnly();
            });
            require(games.selectCount(filter) == 0, "Flex transaction rollback");
            require(results.selectPlayerResult(3, 43, "42") == null, "XML transaction rollback");
        }
        System.out.println("Verified Redis commands, score caching, entity migrations, Flex CRUD, paging, XML and rollback.");
    }

    private static void checkRedisCommands() {
        for (RedisCommands redis : java.util.List.of(RedisUtil.getRu(), RedisUtil1.getRu(), RedisUtil3.getRu())) {
            String key = "ci:commands:" + redis.getClass().getSimpleName();
            try {
                require("OK".equals(redis.set(key, "text")), "Redis string write");
                require("text".equals(redis.get(key)), "Redis string read");
                require(redis.sadd(key, "member") == null, "Redis wrong-type fallback");
                redis.del(key);
                redis.zadd(key, 1, "first");
                redis.zadd(key, 2, "second");
                require(java.util.List.copyOf(redis.zrevrange(key, 0, -1))
                        .equals(java.util.List.of("second", "first")), "Redis ranking order");
                if (redis instanceof RedisUtil3 gameCache) {
                    require("OK".equals(gameCache.rename(key, key + ":moved")), "Redis game rename");
                    require(gameCache.rename(key, key + ":moved") == null, "Redis missing key rename");
                }
            } finally {
                redis.del(key, key + ":moved");
            }
        }
    }

    private static void checkScoreCache(ClassPathXmlApplicationContext context) {
        var beans = context.getBeanFactory();
        beans.registerSingleton("baseCacheLoader", beans.createBean(BaseCacheLoader.class));
        var controller = beans.createBean(BaseCacheController.class);
        var cache = CacheManager.getCache();
        try {
            require(controller.queryScoreSection(cache) == null, "empty score configuration");
            var config = new LandlordScoreSection();
            config.setSectionInfo("ci-scores");
            context.getBean(LandlordScoreSectionMapper.class).insert(config);
            require("ci-scores".equals(controller.queryScoreSection(cache)), "score configuration reload");
            require("ci-scores".equals(cache.get("SCORE_SECTION")), "score configuration cached");
        } finally {
            RedisUtil.getRu().del("SCORE_SECTION");
            CacheManager.releaseCache(cache);
        }
    }

    private static void checkEntityMigration(ClassPathXmlApplicationContext context) {
        var feedback = new TFeedback();
        feedback.setUserId(420L);
        feedback.setContent("CI feedback");
        var feedbackMapper = context.getBean(TFeedbackMapper.class);
        require(feedbackMapper.insert(feedback) == 1 && feedbackMapper.selectCount(feedback) == 1,
                "feedback insert and lookup");

        var gift = new TGiftPoint();
        gift.setUserId(420L);
        gift.setToUserId(421L);
        gift.setPoint(12);
        var gifts = context.getBean(TGiftPointMapper.class);
        require(gifts.insert(gift) == 1 && gifts.selectOne(gift).getPoint() == 12, "point gift history");

        var user = new TUser();
        user.setUserid(420L);
        context.getBean(TUserMapper.class).insertSelective(user);
        var player = new TActivityUser();
        player.setUserid(420L);
        player.setActivityId(420L);
        player.setStatus((short) 1);
        player.setBringChip(12);
        player.setPresentChip(8);
        var activities = context.getBean(TActivityUserMapper.class);
        activities.insertSelective(player);
        var current = activities.queryFreeGamePlayers(420L).getFirst();
        require(current.getOriCoins() == 12 && current.getNowCoins() == 8, "active player chips");
        require(activities.queryAllFreeGamePlayers(420L).size() == 1, "all activity players");
    }

    private static void checkGameConfig(TGroupGameconfigMapper games, TGroupGameconfig filter) {
        require(games.findById(null) == null && games.removeById(null) == 0, "absent primary key");
        var first = new TGroupGameconfig();
        first.setGroupId(filter.getGroupId());
        first.setGameType(5);
        first.setName("original");
        first.setConfig("");
        games.insertSelective(first);
        require(first.getId() != null, "generated id");
        require("".equals(first.getConfig()), "input preserved");
        var stored = games.selectOneById(first.getId());
        require(stored.getConfig() == null && stored.getCrateTime() != null, "insert defaults");
        var second = new TGroupGameconfig();
        second.setGroupId(filter.getGroupId());
        second.setId(first.getId() + 10);
        games.insert(second);
        require(games.selectOneById(second.getId()) != null, "explicit identity");
        require(games.selectCount(filter) == 2, "entity count");
        require(games.selectConfigCountByGameType("5", filter.getGroupId()) == 1, "XML reads Flex insert");
        try {
            games.selectOne(filter);
            throw new AssertionError("selectOne accepted multiple rows");
        } catch (TooManyResultsException expected) {
            // Existing services rely on a unique match.
        }
        var query = QueryWrapper.create().where(column(TGroupGameconfig::getGroupId).eq(filter.getGroupId()))
                .orderBy(column(TGroupGameconfig::getId).asc());
        require(games.paginate(1, 1, query).getRecords().getFirst().getId().equals(first.getId()), "first page");
        require(games.paginate(2, 1, query).getRecords().getFirst().getId().equals(second.getId()), "second page");

        var patch = new TGroupGameconfig();
        patch.setId(first.getId());
        patch.setName("");
        patch.setStatus(1);
        games.updateSelective(patch);
        stored = games.selectOneById(first.getId());
        require("original".equals(stored.getName()) && stored.getStatus() == 1, "selective update");
        patch.setGroupId(filter.getGroupId());
        games.update(patch, false);
        stored = games.selectOneById(first.getId());
        require("".equals(stored.getName()) && stored.getGameType() == null, "full update");
    }

    private static void checkHallQueries(ClassPathXmlApplicationContext context) {
        var db = new org.springframework.jdbc.core.JdbcTemplate(context.getBean("flexDataSource", javax.sql.DataSource.class));
        db.update("INSERT INTO t_user(userid,nick_name) VALUES (851,'A'),(852,'B'),(853,'C')");
        db.update("INSERT INTO t_free_game_singleresult(user_id,date,total) VALUES "
                + "(851,'2020-01-02',2),(851,'2020-01-03',3),(852,'2020-01-02',5),(853,'2020-01-02',6)");
        var results = context.getBean(com.j.joker.mapper.TFreeGameSingleresultMapper.class);
        String start = "2020-01-01", end = "2020-01-03";
        var top = results.querySingleResult(2L, start, end);
        require(top.size() == 2 && top.get(0).getUserId() == 853 && top.get(1).getUserId() == 851
                && top.get(1).getTotal() == 5 && top.get(1).getRank() == 2, "ordered aggregate and tie");
        require(results.queryGeRenSingleResult(852L, start, end).getRank() == 3, "personal rank");
        require(results.queryGeRenSingleResult2(852L, start, end).getRank() == 0, "unranked entry");
        db.update("INSERT INTO t_game_type(id) VALUES (851)");
        db.update("INSERT INTO t_game_config(id,level,content) VALUES (851,1,'first'),(852,1,'second')");
        db.update("INSERT INTO t_game_type_game(id,game_type_id,game_level,game_name,agent_id) VALUES "
                + "(850,851,999,'no config',851),(851,851,1,'matched',851),(852,851,1,'later',851)");
        db.update("INSERT INTO t_game_province(province_id,default_agent) VALUES (851,851)");
        db.update("INSERT INTO t_province_agent(province_id,agent_id) VALUES (851,851)");
        var options = context.getBean(com.j.joker.mapper.TGameTypeGameMapper.class).selectByAgent(851L);
        require(options.size() == 1 && "matched".equals(options.getFirst().getName())
                && "first".equals(options.getFirst().getContent()), "agent representative config");
        db.update("INSERT INTO t_sec_user(userId) VALUES (851)");
        var users = context.getBean(com.j.joker.mapper.TSecUserMapper.class);
        require(users.increaseSecondLayerSellCount(851L, 3L) == 1
                && users.selectOneById(851L).getSecondLayerSellCount() == 3, "nullable sales counter");
    }

    private static void checkRankings(TFreeGameTotalMapper rankings) {
        var row = new TFreeGameTotal();
        row.setUserId(42L);
        rankings.insertSelective(row);
        rankings.updateTotal(2, 0, 0, 2, row.getUserId());
        require(rankings.selectCount(row) == 1, "default counters omitted from entity filter");
        require(rankings.querytotal(row.getUserId()).getWin() == 2, "XML maps ranking counters");
    }

    private static void checkOrders(ImsTpOrdersMapper orders) {
        var order = new ImsTpOrders();
        order.setOrderNo("ci-flex");
        order.setOrderstatus(1);
        orders.insert(order);
        var patch = new ImsTpOrders();
        patch.setOrderstatus(2);
        var query = QueryWrapper.create().where(column(ImsTpOrders::getOrderNo).eq("ci-flex"));
        require(orders.updateSelectiveByQuery(patch, query) == 1, "update by order number");
        var filter = new ImsTpOrders();
        filter.setOrderNo("ci-flex");
        require(orders.selectOne(filter).getOrderstatus() == 2, "mapped order status");
    }

    private static void checkCompositeKey(TConfigMapper settings) {
        var row = new TConfig();
        row.setId(42L);
        row.setK("ci-flex");
        settings.insert(row);
        row.setV("updated");
        require(settings.updateSelective(row) == 1, "composite update");
        row.setK("different");
        require(settings.delete(row) == 0, "both key columns required");
        var found = settings.selectOneById(new Object[]{42L, "ci-flex"});
        require("updated".equals(found.getV()) && settings.delete(found) == 1, "composite lookup and delete");
    }

    private static void checkTransientColumns(TVersionMapper versions) {
        var row = new TVersion();
        row.setId(42L);
        row.setVersion("ci-flex");
        row.setCode("response-only");
        versions.insertSelective(row);
        require(versions.selectOne(row).getCode() == null, "transient property omitted from insert and filter");
    }

    private static void require(boolean condition, String message) {
        if (!condition) {
            throw new AssertionError(message);
        }
    }
}
