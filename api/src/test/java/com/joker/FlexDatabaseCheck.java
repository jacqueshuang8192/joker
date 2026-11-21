package com.joker;

import com.hbi.mapper.ImsTpOrdersMapper;
import com.hbi.mapper.TConfigMapper;
import com.hbi.mapper.TFreeGameResultMapper;
import com.hbi.mapper.TFreeGameTotalMapper;
import com.hbi.mapper.TGroupGameconfigMapper;
import com.hbi.mapper.TVersionMapper;
import com.hbi.model.ImsTpOrders;
import com.hbi.model.TConfig;
import com.hbi.model.TFreeGameTotal;
import com.hbi.model.TGroupGameconfig;
import com.hbi.model.TVersion;
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

/** Runs against the disposable, migrated MySQL database in tools/smoke.sh. */
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
            tx.executeWithoutResult(status -> {
                checkGameConfig(games, filter);
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
        System.out.println("Verified MyBatis-Flex CRUD, key mapping, paging, XML and transaction rollback.");
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
