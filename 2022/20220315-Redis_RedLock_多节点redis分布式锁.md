# Redis_RedLock_多节点redis分布式锁

-----

## RedLock介绍

Redlock是一种算法，Redlock 也就是Redis Distributed Lock,可用实现多节点Redis的分布式锁。

RedLock官方推荐，Redisson完成了对Redlock算法封装。

此种方式具有以下特性:
+   互斥访问:即永远只有一个client能拿到锁
+   避免死锁:最终client都可能拿到锁，不会出现死锁的情况，即使锁定资源的服务崩溃或者分区，仍然能释放锁。
+   容错性:只要大部分Redis节点存活(一半以上)，就可以正常提供服务

## Redlock 算法

### 获得锁

算法很易懂，起 5 个 master 节点，分布在不同的机房尽量保证可用性。为了获得锁，client 会进行如下操作：

1.  得到当前的时间，微妙单位
2.  尝试顺序地在 5 个实例上申请锁，当然需要使用相同的 key 和 random value，这里一个 client 需要合理设置与 master 节点沟通的 timeout 大小，避免长时间和一个 fail 了的节点浪费时间
3.  当 client 在大于等于 3 个 master 上成功申请到锁的时候，且它会计算申请锁消耗了多少时间，这部分消耗的时间采用获得锁的当下时间减去第一步获得的时间戳得到，如果锁的持续时长（lock validity time）比流逝的时间多的话，那么锁就真正获取到了。
4.  如果锁申请到了，那么锁真正的 lock validity time 应该是 `origin（lock validity time） - 申请锁期间流逝的时间`
5.  如果 client 申请锁失败了，那么它就会在少部分申请成功锁的 master 节点上执行释放锁的操作，重置状态

### 失败重试

+   如果一个 client 申请锁失败了，那么它需要稍等一会在重试避免多个 client 同时申请锁的情况，最好的情况是一个 client 需要几乎同时向 5 个 master 发起锁申请。
+   另外就是如果 client 申请锁失败了它需要尽快在它曾经申请到锁的 master 上执行 unlock 操作，便于其他 client 获得这把锁，避免这些锁过期造成的时间浪费
    *   当然如果这时候网络分区使得 client 无法联系上这些 master，那么这种浪费就是不得不付出的代价了。

### 放锁

放锁操作很简单，就是依次释放所有节点上的锁就行了
