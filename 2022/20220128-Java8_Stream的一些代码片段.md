#	Java8_Stream的一些代码片段

----

#   对一个List做分组操作

```java

// 之前
@Test
public void groupListBeforeJava8() {
    Map<String, List<Employee>> result = new HashMap<>();
    for (Employee e : employees) {
        String city = e.getCity();
        List<Employee> empsInCity = result.get(city);
        if (empsInCity == null) {
            empsInCity = new ArrayList<>();
            result.put(city, empsInCity);
        }
        empsInCity.add(e);
    }
    System.out.println(result);
    assertEquals(result.get("London").size(), 2);
}

// 使用stream
@Test
public void groupingByTest() {
    Map<String, List<Employee>> employeesByCity = employees.stream().collect(Collectors.groupingBy(Employee::getCity));
    System.out.println(employeesByCity);
    assertEquals(employeesByCity.get("London").size(), 2);
}
```

##  统计每个分组的count

```java
/**
 * 使用java8 stream groupingBy操作,按城市分组list统计count
 */
@Test
public void groupingByCountTest() {
    Map<String, Long> employeesByCity =
            employees.stream().collect(Collectors.groupingBy(Employee::getCity, Collectors.counting()));
    System.out.println(employeesByCity);
    assertEquals(employeesByCity.get("London").longValue(), 2L);
}
```

##  统计分组平均值

```java
/**
 * 使用java8 stream groupingBy操作,按城市分组list并计算分组销售平均值
 */
@Test
public void groupingByAverageTest() {
    Map<String, Double> employeesByCity =
            employees.stream().collect(Collectors.groupingBy(Employee::getCity, Collectors.averagingInt(Employee::getSales)));
    System.out.println(employeesByCity);
    assertEquals(employeesByCity.get("London").intValue(), 175);
}
```

##  统计分组总值

```java
/**
 * 使用java8 stream groupingBy操作,按城市分组list并计算分组销售总值
 */
@Test
public void groupingBySumTest() {
    Map<String, Long> employeesByCity =
            employees.stream().collect(Collectors.groupingBy(Employee::getCity, Collectors.summingLong(Employee::getSales)));

    //对Map按照分组销售总值逆序排序
    Map<String, Long> finalMap = new LinkedHashMap<>();
    employeesByCity.entrySet().stream()
            .sorted(Map.Entry.<String, Long>comparingByValue()
                    .reversed()).forEachOrdered(e -> finalMap.put(e.getKey(), e.getValue()));

    System.out.println(finalMap);
    assertEquals(finalMap.get("London").longValue(), 350);
}
```

##  Join分组List

```java
/**
 * 通过type分组list，通过join操作连接分组list
 */
@Test
public void groupingByConvertResultTest(){
    List<BlogPost> blogPostList = Lists.newArrayList();
    blogPostList.add(new BlogPost("post1", "zhuoli", 1, 30));
    blogPostList.add(new BlogPost("post2", "zhuoli", 1, 40));
    blogPostList.add(new BlogPost("post3", "zhuoli", 2, 15));
    blogPostList.add(new BlogPost("post4", "zhuoli", 3, 33));
    blogPostList.add(new BlogPost("post5", "Alice", 1, 99));
    blogPostList.add(new BlogPost("post6", "Michael", 3, 65));

    Map<Integer, String> postsPerType = blogPostList
            .stream()
            .collect(
                Collectors.groupingBy(
                    BlogPost::getType,
                    Collectors.mapping(
                        BlogPost::getTitle, Collectors.joining(", ", "Post titles: [", "]"))
                    )
                );
    System.out.println(postsPerType);
}
```

##  转换分组结果List -> List

```java
/**
 * 使用java8 stream groupingBy操作,按城市分组list,将List转化为name的List
 */
@Test
public void groupingByCityMapList(){
    Map<String, List<String>> namesByCity = employees
        .stream()
        .collect(
            Collectors.groupingBy(
                Employee::getCity, Collectors.mapping(Employee::getName, Collectors.toList())
            )
        );
    System.out.println(namesByCity);
    assertThat(namesByCity.get("London"), contains("Alice", "Bob"));
}
```

##  转换分组结果List -> Set

```java
/**
 * 使用java8 stream groupingBy操作,按城市分组list,将List转化为name的Set
 */
@Test
public void groupingByCityMapListToSet(){
    Map<String, Set<String>> namesByCity = employees
        .stream()
        .collect(Collectors.groupingBy(Employee::getCity, Collectors.mapping(Employee::getName, Collectors.toSet())));
    System.out.println(namesByCity);
    assertThat(namesByCity.get("London"), containsInAnyOrder("Alice", "Bob"));
}
```

##  使用对象分组List

```java
/**
 * 使用java8 stream groupingBy操作,通过Object对象的成员分组List
 */
@Test
public void groupingByObjectTest(){
    List<BlogPost> blogPostList = Lists.newArrayList();
    blogPostList.add(new BlogPost("post1", "zhuoli", 1, 30));
    blogPostList.add(new BlogPost("post2", "zhuoli", 1, 40));
    blogPostList.add(new BlogPost("post3", "zhuoli", 2, 15));
    blogPostList.add(new BlogPost("post4", "zhuoli", 3, 33));
    blogPostList.add(new BlogPost("post5", "Alice", 1, 99));
    blogPostList.add(new BlogPost("post6", "Michael", 3, 65));

    Map<Tuple, List<BlogPost>> postsPerTypeAndAuthor = blogPostList.stream()
            .collect(Collectors.groupingBy(post -> new Tuple(post.getAuthor(), post.getType())));

    System.out.println(postsPerTypeAndAuthor);
}
```

##  使用两个成员分组List

```java
/**
 * 通过author和type分组list
 */
@Test
public void groupingByMultiItemTest(){
    List<BlogPost> blogPostList = Lists.newArrayList();
    blogPostList.add(new BlogPost("post1", "zhuoli", 1, 30));
    blogPostList.add(new BlogPost("post2", "zhuoli", 1, 40));
    blogPostList.add(new BlogPost("post3", "zhuoli", 2, 15));
    blogPostList.add(new BlogPost("post4", "zhuoli", 3, 33));
    blogPostList.add(new BlogPost("post5", "Alice", 1, 99));
    blogPostList.add(new BlogPost("post6", "Michael", 3, 65));

    Map<String, Map<Integer, List<BlogPost>>> map = blogPostList.stream()
            .collect(Collectors.groupingBy(BlogPost::getAuthor, Collectors.groupingBy(BlogPost::getType)));
    System.out.println(map);
}
```
