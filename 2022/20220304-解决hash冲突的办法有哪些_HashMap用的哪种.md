# 解决hash冲突的办法有哪些? HashMap用的哪种?

-----

解决Hash冲突方法有:开放定址法、再哈希法、链地址法(拉链法)、建立公共溢出区。

`HashMap中采用的是链地址法`。

## 开放定址法

?>  就是一个哈希函数,冲突了就再一次hash

+   也称为再散列法
+   `基本思想就是，如果p=H(key)出现冲突时，则以p为基础，再次 hash`，p1=H(p) ，如果p1再次出现冲突，则以p1为基础，以此类推，直到找到一个不冲突的哈希地址pi。
+   因此开放定址法所需要的hash表的长度要大于等于所需要存放的元素，而且因为存在再次 hash，所以只能在删除的节点上做标记，而不能真正删除节点。

## 再哈希法(双重散列，多重散列)

+   提供多个不同的hash函数， 当R1=H1(key1)发生冲突时，再计 算R2=H2(key1)，直到没有冲突为止。
+   这样做虽然`不易产生堆集，但增加了计算的时间`。

## 链地址法(拉链法)

+   将哈希值相同的元素构成一个同义词的单链表,并将单链表的头指针存放在哈希表的第i个单元中，查找、插入和删除主要在同义词链表中进行。链表法适用于经常进行插入和删除的情况。

## 建立公共溢出区

+   将哈希表分为公共表和溢出表，当溢出发生时，将所有溢出数据统一放到溢出区。

