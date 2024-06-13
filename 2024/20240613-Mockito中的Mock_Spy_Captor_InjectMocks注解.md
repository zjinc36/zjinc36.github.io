# Mockito 中的 @Mock, @Spy, @Captor 及 @InjectMocks 注解

## 启用 Mockito
开始之前，我们需要先使 Mockito 注解生效，有几种方法：

### MockitoJUnitRunner

方法一：在JUnit 上设置 MockitoJUnitRunner

```java
@ExtendWith(MockitoExtension.class)
public class MockitoAnnotationUnitTest {
    //...
}
```

### MockitoAnnotations.initMocks()

方法二：手动编码，调用 MockitoAnnotations.openMocks() 方法

```java
@Before
public void init() {
    MockitoAnnotations.openMocks(this);
}
```

### MockitoJUnit.rule()
最后, 我们可以使用 MockitoJUnit.rule():

```java
public class MockitoAnnotationsInitWithMockitoJUnitRuleUnitTest {

    @Rule
    public MockitoRule initRule = MockitoJUnit.rule();

    //...
}
```

注意，这需要将rule 设置为 public

## 四个注解

### @Mock 注解

> mock意思就是造一个假的模拟对象，不会去调用这个真正对象的方法，这个mock对象里的所有行为都是未定义的，属性也不会有值，需要你自己去定义它的行为。
> 
> 比如说，你可以mock一个假的size(), 使其返回100，但实际上并没有真的创建一个 size 为100的 Map

@Mock 是 Mockito 中用的最多的注解，我们用它来创建并注入mock对象，而不用手动调用 Mockito.mock 方法。

为了方便对比，下面这个例子中，我们先是手动mock一个ArrayList

```java
@Test
public void whenNotUseMockAnnotation_thenCorrect() {
    List mockList = Mockito.mock(ArrayList.class);

    mockList.add("one");
    Mockito.verify(mockList).add("one");
    assertEquals(0, mockList.size());

    Mockito.when(mockList.size()).thenReturn(100);
    assertEquals(100, mockList.size());
}
```

然后我们通过 @Mock 注解的方式完成相同的工作：

```java
@Mock
List<String> mockedList;

@Test
public void whenUseMockAnnotation_thenMockIsInjected() {
    mockedList.add("one");
    Mockito.verify(mockedList).add("one");
    assertEquals(0, mockedList.size());

    Mockito.when(mockedList.size()).thenReturn(100);
    assertEquals(100, mockedList.size());
}
```

### @Spy 注解

> 因为mock是模拟整个生成一个假对象，spy像是间谍潜伏在真实对象里去篡改行为。

spy与mock的区别是，mock代理了目标对象的全部方法，spy只是部分代理

下面我们学习如何使用 @Spy 注解spy一个现有的对象实例。

我们先不用注解的方式，演示如何创建一个 spy List。

```java
@Test
public void whenNotUseSpyAnnotation_thenCorrect() {
    List<String> spyList = Mockito.spy(new ArrayList<String>());

    spyList.add("one");
    spyList.add("two");

    Mockito.verify(spyList).add("one");
    Mockito.verify(spyList).add("two");

    assertEquals(2, spyList.size());

    Mockito.doReturn(100).when(spyList).size();
    assertEquals(100, spyList.size());
}
```
然后我们通过 @Spy 注解的方式完成相同的工作：


```java
@Spy
List<String> spiedList = new ArrayList<String>();

@Test
public void whenUseSpyAnnotation_thenSpyIsInjectedCorrectly() {
    spiedList.add("one");
    spiedList.add("two");

    Mockito.verify(spiedList).add("one");
    Mockito.verify(spiedList).add("two");

    assertEquals(2, spiedList.size());

    Mockito.doReturn(100).when(spiedList).size();
    assertEquals(100, spiedList.size());
}
```
本例中，我们：

- 调用真实的 spiedList.add() 方法，向 spiedList 中新增元素
- 使用Mockito.doReturn() 修饰后，spiedList.size() 会返回 100 而非 2

### @Captor 注解

接下来让我们看看如何使用 @Captor 注解创建 ArgumentCaptor 实例。

在下面的示例中，我们先不使用 @Captor 注解，手动创建一个 ArgumentCaptor：

```java
@Test
public void whenUseCaptorAnnotation_thenTheSame() {
    List mockList = Mockito.mock(List.class);
    ArgumentCaptor<String> arg = ArgumentCaptor.forClass(String.class);

    mockList.add("one");
    Mockito.verify(mockList).add(arg.capture());

    assertEquals("one", arg.getValue());
}
```
现在，让我们使用 @Captor 注解来创建 ArgumentCaptor：

```java
@Mock
List mockedList;

@Captor 
ArgumentCaptor argCaptor;

@Test
public void whenUseCaptorAnnotation_thenTheSam() {
    mockedList.add("one");
    Mockito.verify(mockedList).add(argCaptor.capture());

    assertEquals("one", argCaptor.getValue());
}
```

### @InjectMocks 注解

现在我们来讨论如何使用 @InjectMocks 注解将mock字段自动注入到被测试对象中。

@InjectMocks 一般是你要测的类，他会把要测类的mock属性自动注入进去。@Mock 则是你要造假模拟的类。

如果是在springboot中，可以简单理解为@Autowired在单元测试中的平替。

在下面的示例中，我们将使用 @InjectMocks 把mock的 wordMap 注入到 MyDictionary dic 中：

```java
@Mock
Map<String, String> wordMap;

@InjectMocks
MyDictionary dic = new MyDictionary();

@Test
public void whenUseInjectMocksAnnotation_thenCorrect() {
    Mockito.when(wordMap.get("aWord")).thenReturn("aMeaning");

    assertEquals("aMeaning", dic.getMeaning("aWord"));
}
```

下面是 MyDictionary 类:

```java
public class MyDictionary {
    Map<String, String> wordMap;

    public MyDictionary() {
        wordMap = new HashMap<String, String>();
    }
    public void add(final String word, final String meaning) {
        wordMap.put(word, meaning);
    }
    public String getMeaning(final String word) {
        return wordMap.get(word);
    }
}
```

## 一个springboot中使用Mockito的例子

```java
// 需要在单元测试之前添加一些初始化的内容
@Slf4j
public class CustomSpringRunner implements BeforeAllCallback {
	@Override
	public void beforeAll(ExtensionContext extensionContext) throws Exception {
		init();
	}

    private static void init() {
        // ...
    }
}
```

```java
// 单元测试
@ExtendWith({SpringExtension.class, CustomSpringRunner.class})
@SpringBootTest(classes = Bootstrap.class, webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@AutoConfigureMockMvc
public class UserServiceBaseTest {
    @Spy
    @InjectMocks
    private UserServiceFacade userService;

    @Mock
    @Qualifier("enterpriseUserRepositoryMongo")
    private IEnterpriseUserRepository enterpriseUserRepositoryMockBean;
    @Mock
    private IUserRepository userRepositoryMockBean;


    private AutoCloseable closeable;

    @BeforeEach
    public void setup() {
        closeable = MockitoAnnotations.openMocks(this);
    }

    @AfterEach
    public void releaseMocks() throws Exception {
        closeable.close();
    }

    @Test
    public void checkTest() {
        String username = "liubei";
        String userid = "111";

        User user = new User();
        user.setId("222");
        // 被测试函数userService.check()中
        // 调用userService当前类的find函数，以下代码是模拟调用find函数,有返回值
        doReturn(user).when(userService).find(any());
        // 调用userService当前类的add函数，以下代码是模拟调用add函数，无返回值
        doNothing().when(userService).add(any(), any(), any());

        assertThrows(RuntimeException.class, () -> userService.check(username, userid));
    }

    @Test
    public void updateTest() {
        String enterpriseId = "111";
        List<String> emails = new ArrayList<>();
        String groupId = "111";

        when(userRepositoryMockBean.add(enterpriseId, emails, groupId)).thenReturn(new User());
        when(enterpriseUserRepositoryMockBean.add(enterpriseId, emails, groupId)).thenReturn(1L);

        userService.update(enterpriseId, emails, groupId);

        verify(enterpriseUserRepositoryMockBean, times(1)).add(enterpriseId, emails, groupId);
    }
}
```

## 将Mock注入Spy中

与前面测试类似，我们可能想在spy中注入一个mock：

```java
@Mock
Map<String, String> wordMap;

@Spy
MyDictionary spyDic = new MyDictionary();
```

然而，Mockito 并`不支持将mock注入spy`，因此下面的测试会出现异常：

```java
@Test 
public void whenUseInjectMocksAnnotation_thenCorrect() { 
    Mockito.when(wordMap.get("aWord")).thenReturn("aMeaning"); 

    assertEquals("aMeaning", spyDic.getMeaning("aWord")); 
}
```

如果我们想在 spy 中使用 mock，`可以通过构造函数手动注入 mock`：

```java
MyDictionary(Map<String, String> wordMap) {
    this.wordMap = wordMap;
}
```
现在需要我们手动创建spy，而不使用注释：

```java
@Mock
Map<String, String> wordMap; 

MyDictionary spyDic;

@BeforeEach
public void init() {
    MockitoAnnotations.openMocks(this);
    spyDic = Mockito.spy(new MyDictionary(wordMap));
}
```
现在测试将通过。

## 使用注解时遇到空指针

通常，当我们使用 @Mock 或 @Spy 注解时，可能会遇到 NullPointerException 异常：

```java
public class MockitoAnnotationsUninitializedUnitTest {

    @Mock
    List<String> mockedList;

    @Test(expected = NullPointerException.class)
    public void whenMockitoAnnotationsUninitialized_thenNPEThrown() {
        Mockito.when(mockedList.size()).thenReturn(1);
    }
}
```
大多数情况下，是因为我们没有启用 Mockito 注解

## @Mock和@Spy的区别

@Mock和@Spy都是Mockito库提供的注解，它们用于在单元测试中创建mock对象，但是它们的功能有所不同。

- @Mock：这个注解用于创建一个mock对象。Mockito会为这个对象生成一个代理，这个代理会跟踪所有对这个对象的调用，但是它不会执行任何实际的代码。这意味着，如果你没有为一个方法提供stub（即预设的行为），那么这个方法会返回默认值（例如null、0或false）。
- @Spy：这个注解用于创建一个spy对象。Spy对象是一个真实的对象，但是它被Mockito包装了一层，以便跟踪对它的调用。这意味着，如果你没有为一个方法提供stub，那么这个方法会执行实际的代码，并返回实际的结果。

总的来说，如果你需要模拟一个对象，且不关心它的内部实现，那么你应该使用@Mock。如果你需要模拟一个对象，但是你希望保留它的一些实际行为，那么你应该使用@Spy。

## @Mock和@MockBean区别

@Mock和@MockBean都是用于创建mock对象的注解，但它们在Spring Boot测试中的使用场景和功能有所不同。

@Mock：这是Mockito库提供的注解，用于在单元测试中创建一个mock对象。这个注解创建的mock对象不会被Spring的应用上下文管理。你可以在任何JUnit测试中使用这个注解，无论是否使用Spring。

@MockBean：这是Spring Boot Test提供的注解，用于在Spring的应用上下文中创建或替换一个mock对象。这个注解创建的mock对象会被Spring的应用上下文管理，并且可以被注入到其他的bean中。你只能在使用Spring Boot Test的测试中使用这个注解。

总的来说，如果你只是在做单元测试，且不需要Spring的应用上下文，那么你应该使用@Mock。如果你在做集成测试，或者你需要将mock对象注入到Spring的bean中，那么你应该使用@MockBean

## doReturn().when()和when().thenReturn()区别

doReturn().when()和when().thenReturn()都是Mockito框架中用于模拟对象行为的方法，但它们在某些情况下的行为是不同的。

1. doReturn().when()：这种方式首先调用了doReturn()方法，然后再调用了when()方法。这种方式不会真正调用被模拟对象的方法，而只是设置了当方法被调用时应该返回的值。这种方式在模拟void方法或者在模拟方法抛出异常时特别有用。

```java
doReturn(user).when(userService).findUser(any());
```

2. when().thenReturn()：这种方式首先调用了when()方法，然后再调用了thenReturn()方法。这种方式在调用when()方法时会真正调用被模拟对象的方法。如果被模拟的方法有副作用（例如修改了某个字段的值或者抛出了异常），那么这些副作用会在调用when()方法时发生。

```java
when(userService.findUser(any())).thenReturn(user);
```

总的来说，如果被模拟的方法没有副作用，或者你希望模拟的方法在设置模拟行为时执行其副作用，那么可以使用when().thenReturn()。如果你不希望被模拟的方法在设置模拟行为时执行其副作用，或者需要模拟void方法，那么应该使用doReturn().when()。


# 参考

- [Mockito 中的 @Mock, @Spy, @Captor 及 @InjectMocks 注解](https://baeldung-cn.com/mockito-annotations)
