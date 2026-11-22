package com.j.joker;

import java.util.Set;

import org.apache.ibatis.session.SqlSessionFactory;
import org.springframework.boot.sql.init.dependency.AbstractBeansOfTypeDependsOnDatabaseInitializationDetector;

/** Order the XML-defined MyBatis session factory after Spring Boot's database migrations. */
public class MyBatisDatabaseInitializationDetector extends AbstractBeansOfTypeDependsOnDatabaseInitializationDetector {
    @Override
    protected Set<Class<?>> getDependsOnDatabaseInitializationBeanTypes() {
        return Set.of(SqlSessionFactory.class);
    }
}
