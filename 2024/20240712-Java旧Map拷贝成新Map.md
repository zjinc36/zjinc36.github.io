# Java旧Map拷贝成新Map

## 浅拷贝

对于浅拷贝

- 修改：如果你修改了 originalMap 中的一个键或值对象的状态（`假设这个对象是可变的`），那么 shallowCopy 中的相应键或值也会被修改，因为它们实际上是同一个对象。
- 新增或删除：如果你在 originalMap 或 shallowCopy 中添加或删除键值对，它们不会影响到另一个 HashMap，因为它们是不同的对象。
  - `删除新的 HashMap 中的键值对不会影响到旧的HashMap`。这是因为新的 HashMap 是一个新的对象，它和旧的 HashMap 是两个不同的对象，它们在内存中的地址是不同的。虽然新的 HashMap 中的键和值与旧的 HashMap 中的键和值是相同的对象，`它们指向的是同一个地址，但是这只是它们的引用关系，不会影响到它们在各自 HashMap 中的存在`。所以，当你在新的 HashMap 中删除一个键值对时，它只会从新的 HashMap 中删除，不会影响到旧的 HashMap

### 使用HashMap构造器

HashMap的参数化构造函数HashMap(Map<?extends K, ?extends V> m) 提供了一个快速的方法来浅拷贝整个Map：

```java
HashMap<String, Employee> shallowCopy = new HashMap<String, Employee>(originalMap);
```

### 使用Map.put()

HashMap可以通过迭代每个item，并在另一个Map上调用put()方法来轻松地进行浅拷贝

```java
HashMap<String, Employee> shallowCopy = new HashMap<String, Employee>();
Set<Entry<String, Employee>> entries = originalMap.entrySet();
for (Map.Entry<String, Employee> mapEntry : entries) {
    shallowCopy.put(mapEntry.getKey(), mapEntry.getValue());
}
```

### 使用Map.putAll()

我们可以使用putAll()方法，而不是遍历所有的条目，该方法是浅拷贝所有的映射关系。

```java
HashMap<String, Employee> shallowCopy = new HashMap<>();
shallowCopy.putAll(originalMap);    
```

我们应该注意到，put()和putAll()如果有一个匹配的键，就会替换这些值。

同样，如果我们看一下HashMap的构造函数、clone()和putAll()的实现，我们会发现它们都使用相同的内部方法来拷贝条目----`putMapEntries()`，可以看一下文章最后的附录中的源码。

### 使用Java 8 Stream API

```java
HashMap<String, Object> shallowCopy = originalMap.entrySet().stream().collect(Collectors.toMap(Map.Entry::getKey, Map.Entry::getValue, (a, b) -> a, HashMap::new));
```

- originalMap.entrySet().stream() 将 authHeader 这个Map的所有键值对转换为一个Stream。
- 然后，Collectors.toMap(Map.Entry::getKey, Map.Entry::getValue, (a, b) -> a, HashMap::new) 是一个收集器（Collector），它会将Stream中的元素收集到一个新的Map中。
- Map.Entry::getKey 和 Map.Entry::getValue 是两个函数，它们分别用于从Stream中的每个元素（这里的元素是Map的键值对）提取出键和值。
(a, b) -> a 是一个合并函数，它用于处理键冲突的情况。当新的Map中已经存在一个键，而Stream中又出现了一个相同的键时，这个函数会被调用。它接收两个参数：已经在Map中的值（a）和新出现的值（b）。这个函数的返- 回值将被放入新的Map中。在这个例子中，当键冲突时，我们选择保留已经在Map中的值。
- HashMap::new 是一个提供者函数，它用于创建新的Map。
- 所以，这段代码的作用是创建一个 originalMap 的浅拷贝。新的Map和原来的Map有相同的键值对，但它们是不同的对象。

### Google Guava

使用Guava Map，我们可以很容易地创建不可变的Map，以及排序和双向Map（BiMap）。要对这些Map中的任何一个做一个不可变的浅拷贝，可以使用copyOf方法。

```java
Map<String, Employee> map = ImmutableMap.<String, Employee>builder()
  .put("emp1",emp1)
  .put("emp2",emp2)
  .build();
Map<String, Employee> shallowCopy = ImmutableMap.copyOf(map);
    
assertThat(shallowCopy).isSameAs(map);
```

## 深拷贝

序列化的方式可以实现对象的深拷贝，但是`对象必须是实现了Serializable接口`才可以。

`Map本身没有实现Serializable这个接口`，不能实现深拷贝，但是`HashMap实现了Serializable`，可以进行深拷贝。

### Apache Commons

现在，Java没有任何内置的深度拷贝实现。因此，为了进行深拷贝，我们可以覆盖clone()方法或者使用`序列化-反序列化`技术。

Apache Commons的SerializationUtils有一个clone()方法来创建一个深度拷贝。为此，任何要包含在深度拷贝中的类`必须实现Serializable接口`。

```java
public class Employee implements Serializable {
    // implementation details
}

HashMap<String, Employee> deepCopy = SerializationUtils.clone(originalMap);
```

### 自己实现

```java
/**
 * 使用对象的序列化进而实现深拷贝
 * @param obj
 * @param <T>
 * @return
 */
private <T extends Serializable> T clone(T obj) {
    T cloneObj = null;
    try {
        ByteOutputStream bos = new ByteOutputStream();
        ObjectOutputStream oos = new ObjectOutputStream(bos);
        oos.writeObject(obj);
        oos.close();
        ByteArrayInputStream bis = new ByteArrayInputStream(bos.toByteArray());
        ObjectInputStream ois = new ObjectInputStream(bis);
        cloneObj = (T) ois.readObject();
        ois.close();
    } catch (Exception e) {
        e.printStackTrace();
    }
    return cloneObj;
}
```

# 附录

## .putAll源码

```java
	public void putAll(Map<? extends K, ? extends V> m) {
        putMapEntries(m, true); // 调用了putMapEntries方法
    }
	
	final void putMapEntries(Map<? extends K, ? extends V> m, boolean evict) {
        int s = m.size();
        if (s > 0) {
            if (table == null) { // pre-size
                float ft = ((float)s / loadFactor) + 1.0F;
                int t = ((ft < (float)MAXIMUM_CAPACITY) ?
                         (int)ft : MAXIMUM_CAPACITY);
                if (t > threshold)
                    threshold = tableSizeFor(t);
            }
            else if (s > threshold)
                resize();
            for (Map.Entry<? extends K, ? extends V> e : m.entrySet()) {
                K key = e.getKey();
                V value = e.getValue();
                putVal(hash(key), key, value, false, evict); // 循环调用了value，但value中的引用对象指针并没有改变。
                // 扩展：map.put("key","value")的put()也是调用了putVal()方法
            }
        }
    }
```

## .clone源码

```java
	@Override
    public Object clone() {
        HashMap<K,V> result;
        try {
            result = (HashMap<K,V>)super.clone();
        } catch (CloneNotSupportedException e) {
            // this shouldn't happen, since we are Cloneable
            throw new InternalError(e);
        }
        result.reinitialize(); // 清空map
        result.putMapEntries(this, false);  // 可见，和putAll调用了同一个接口，
        return result;
    }
	
	
	    final void putMapEntries(Map<? extends K, ? extends V> m, boolean evict) {
        int s = m.size();
        if (s > 0) {
            if (table == null) { // pre-size
                float ft = ((float)s / loadFactor) + 1.0F;
                int t = ((ft < (float)MAXIMUM_CAPACITY) ?
                         (int)ft : MAXIMUM_CAPACITY);
                if (t > threshold)
                    threshold = tableSizeFor(t);
            }
            else if (s > threshold)
                resize();
            for (Map.Entry<? extends K, ? extends V> e : m.entrySet()) {
                K key = e.getKey();
                V value = e.getValue();
                putVal(hash(key), key, value, false, evict); // 同上，循环调用了“value”，value中的引用对象指针并没有改变
            }
        }
    }

```