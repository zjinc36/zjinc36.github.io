# Zookeeper选举机制

---

# 选票格式
(myid, ZXID) => (自己机器的id, 事务id)

# 半数选举机制
+   机器1启动，选自己，选票为1,它发出去的报文没有任何响应，所以它的选举状态一直是LOOKING状态

+   机器2启动，选自己，选票为(2, 0)
    *   机器1告诉2自己怎么投的，2告诉1自己怎么投的
    *   机器1比较(1, 0)，(2, 0)中，先确定都是zxid为0表示同一轮投票，后确定1 < 2，所以重新投票给2
    *   而机器2比较(1, 0)，(2, 0)中，先确定都是zxid为0表示同一轮投票，后确定自己不需要重新投票
    *   所以，此时只有1投票，没有超过半数

+   机器3启动，选自己，选票为(3, 1)
    *   互相告知自己的选票
    *   机器1比较(2, 1)，(2, 1)，(3, 1)中，先确定都是zxid为1表示同一轮投票，后确定2 < 3，所以重新投票给3
    *   机器2比较(2, 1)，(2, 1)，(3, 1)中，先确定都是zxid为1表示同一轮投票，后确定2 < 3，所以重新投票给3
    *   而机器3比较(2, 1)，(2, 1)，(3, 1)中，先确定都是zxid为1表示同一轮投票，后确定自己不需要重新投票
    *   此时机器1和机器2投票了，超过半数，所以机器3当选leader

+   4启动，已有leader3

+   5启动，已有leader3
