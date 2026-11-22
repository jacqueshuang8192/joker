package com.j.joker.core.mapper;

import com.mybatisflex.annotation.KeyType;
import com.mybatisflex.core.BaseMapper;
import com.mybatisflex.core.query.QueryWrapper;
import com.mybatisflex.core.table.TableInfo;
import com.mybatisflex.core.table.TableInfoFactory;
import java.io.Serializable;
import java.util.List;
import org.apache.ibatis.exceptions.TooManyResultsException;
import org.apache.ibatis.reflection.MetaObject;
import org.apache.ibatis.reflection.SystemMetaObject;
import org.springframework.beans.BeanUtils;

/** Shared entity filters and selective-write semantics used by the game services. */
public interface EntityMapper<T> extends BaseMapper<T> {
    private QueryWrapper matching(T entity) {
        return entity == null ? QueryWrapper.create() : QueryWrapper.create(entity);
    }

    default List<T> select(T entity) {
        return selectListByQuery(matching(entity));
    }

    default T selectOne(T entity) {
        List<T> rows = selectListByQuery(matching(entity).limit(2));
        if (rows.size() > 1) {
            throw new TooManyResultsException("Expected at most one " + rows.getFirst().getClass().getSimpleName());
        }
        return rows.isEmpty() ? null : rows.getFirst();
    }

    default T findById(Serializable id) {
        return id == null ? null : selectOneById(id);
    }

    default int removeById(Serializable id) {
        return id == null ? 0 : deleteById(id);
    }

    default int selectCount(T entity) {
        return Math.toIntExact(selectCountByQuery(matching(entity)));
    }

    @Override
    default int insert(T entity) {
        return insertEntity(entity, false);
    }

    @Override
    default int insertSelective(T entity) {
        return insertEntity(entity, true);
    }

    private int insertEntity(T entity, boolean selective) {
        TableInfo table = TableInfoFactory.ofEntityClass(entity.getClass());
        T row = selective ? selectiveRow(entity, table) : entity;
        MetaObject values = SystemMetaObject.forObject(row);
        for (var key : table.getPrimaryKeyList()) {
            if (key.getKeyType() == KeyType.Auto && values.getValue(key.getProperty()) != null) {
                return insertWithPk(row, selective);
            }
        }
        int count = insert(row, selective);
        if (row != entity) {
            MetaObject original = SystemMetaObject.forObject(entity);
            for (var key : table.getPrimaryKeyList()) {
                if (key.getKeyType() == KeyType.Auto) {
                    original.setValue(key.getProperty(), values.getValue(key.getProperty()));
                }
            }
        }
        return count;
    }

    default int updateSelective(T entity) {
        return update(selectiveRow(entity, TableInfoFactory.ofEntityClass(entity.getClass())), true);
    }

    default int updateSelectiveByQuery(T entity, QueryWrapper query) {
        return updateByQuery(selectiveRow(entity, TableInfoFactory.ofEntityClass(entity.getClass())), true, query);
    }

    // Existing callers use empty strings, as well as nulls, to omit columns on selective writes.
    private T selectiveRow(T entity, TableInfo table) {
        MetaObject values = SystemMetaObject.forObject(entity);
        var properties = table.getPropertyColumnMapping().keySet();
        if (properties.stream().noneMatch(property -> "".equals(values.getValue(property)))) {
            return entity;
        }
        @SuppressWarnings("unchecked")
        T row = (T) BeanUtils.instantiateClass(entity.getClass());
        MetaObject copy = SystemMetaObject.forObject(row);
        for (String property : properties) {
            Object value = values.getValue(property);
            copy.setValue(property, "".equals(value) ? null : value);
        }
        return row;
    }
}
