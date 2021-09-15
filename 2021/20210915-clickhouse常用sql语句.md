# clickhouse常用sql语句

----

# 建表

```sql
CREATE TABLE 库名.表名 (
    `id`  Int64 COMMENT 'id',
    `deviceTs`  Int64 COMMENT '时间戳',
    `setTime`  DATETIME COMMENT '时间',
    `factoryName`  String COMMENT '工厂名',
    `devType`  String COMMENT '设备类型',
    `devId`  String COMMENT '设备ID',
    `sysSta`  Float64 COMMENT '看门狗',
    `heartbeatChangeOrNot`  Float64 COMMENT '是否有心跳',
    `withSpeedOrNot`  Float64 COMMENT '是否有转速',
    `deviceState`  Float64 COMMENT '设备状态',
    `runningTime`  Int64 COMMENT '今日运行时常',
    `tag0`  Float64 COMMENT '定长落纱',
    `data1` String COMMENT '预留'
) ENGINE = MergeTree()
PARTITION BY toYYYYMMDD(setTime)
ORDER BY (
    deviceTs,
    factoryName,
    devId
 );
```


# 清空表
```sql
truncate TABLE 表名
```


# 查看和删除某个分区

```sql
-- 查看分区
SELECT
    database,
    table,
    partition,
    partition_id,
    name,
    path
FROM
    system.parts
WHERE
    table = '表名'

-- 删除分区
ALTER TABLE `库名`.表名 DROP PARTITION '分区名';
```


# 更新某字段注释

```sql
ALTER TABLE `库名`.表名 MODIFY COLUMN 字段 类型 COMMENT '注释'
```

