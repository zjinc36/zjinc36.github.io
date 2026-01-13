# CQRS（命令查询责任分离）

CQRS（Command Query Responsibility Segregation，命令查询责任分离）是一种**架构设计模式/原则**，核心思想是将系统的**写操作（Command，命令）** 和**读操作（Query，查询）** 拆分为两个完全独立的模型，分别处理数据的修改与数据的查询，以此优化系统的复杂度、性能和扩展性。

它并非GoF经典设计模式，而是作用于系统架构层级的思想，常与DDD、事件溯源（Event Sourcing）、微服务等架构结合使用。

## 一、CQRS的核心思想：读写分离

### 1. 传统CRUD的问题

在传统的CRUD架构中，我们通常会用**同一个模型**处理数据的增删改查，比如一个`UserService`既包含`createUser`、`updateUser`（写），也包含`getUser`、`listUsers`（读）。
这种模式在简单系统中很高效，但在复杂业务场景下会暴露问题：
- 读写逻辑耦合，一个模型既要满足写操作的业务规则校验，又要满足读操作的多维度查询需求，导致模型臃肿；
- 读写性能无法单独优化，比如读操作需要复杂聚合、缓存，写操作需要事务、幂等性保障，二者优化方向冲突；
- 难以应对读写压力不均衡的场景（如读多写少的电商商品页、写多读少的交易系统）。

### 2. CQRS的解决方案：拆分读写模型

CQRS将系统明确划分为**命令侧**和**查询侧**两个独立部分：

| 维度           | 命令侧（Command）                           | 查询侧（Query）                                        |
| -------------- | ------------------------------------------- | ------------------------------------------------------ |
| **核心操作**   | 增、删、改，**改变系统状态**                | 查，**读取系统状态，不改变数据**                       |
| **返回结果**   | 无返回值或仅返回操作状态（如成功/失败、ID） | 返回查询结果（如DTO、视图模型）                        |
| **业务关注点** | 严格的业务规则校验、事务一致性、幂等性      | 查询效率、数据聚合、多维度展示                         |
| **数据模型**   | 面向业务领域的模型（如DDD的聚合根）         | 面向查询的扁平模型（如专为前端定制的VO）               |
| **数据源**     | 可直接操作主库                              | 可独立使用读库、缓存、数据仓库，甚至与命令侧数据源不同 |

**核心原则**：**命令不返回数据，查询不修改数据**。

## 二、CQRS的核心组件

一个典型的CQRS架构包含以下核心组件，我们结合代码场景来理解：

- **Command（命令）**
   - 封装写操作的请求参数，是一个不可变的数据载体
   - 包含参数校验逻辑，确保请求的合法性。
   - 示例：

```java
public class CreateDocumentCommand {
    private final String token;
    private final String title;
    private final String content;
    private final List<String> tags;

    // 私有构造+静态工厂方法，保证不可变性
    private CreateDocumentCommand(String token, String title, String content, List<String> tags) {
        this.token = token;
        this.title = title;
        this.content = content;
        this.tags = tags;
        this.validate();
    }

    public static CreateDocumentCommand create(String token, String title, String content, List<String> tags) {
        return new CreateDocumentCommand(token, title, content, tags);
    }

    // 参数校验
    private void validate() {
        if (token == null || token.isBlank()) {
            throw new IllegalArgumentException("token不能为空");
        }
        if (title == null || title.length() > 100) {
            throw new IllegalArgumentException("标题长度不能超过100");
        }
    }

    // 仅提供getter，无setter
    public String getToken() { return token; }
    public String getTitle() { return title; }
}
```

- **Command Handler（命令处理器）**
  - 负责接收并执行命令，是命令侧的核心逻辑载体。
  - 协调领域层（如聚合根、领域服务）完成业务操作，处理事务、异常等。
  - 示例：

```java
@Service
public class CreateDocumentCommandHandler {
    private final DocumentDomainService documentDomainService;
    private final UserRepository userRepository;

    @Autowired
    public CreateDocumentCommandHandler(DocumentDomainService documentDomainService, UserRepository userRepository) {
        this.documentDomainService = documentDomainService;
        this.userRepository = userRepository;
    }

    // 执行命令，返回操作状态
    public CommandResult handle(CreateDocumentCommand command) {
        // 1. 校验用户身份
        User user = userRepository.findByToken(command.getToken())
                .orElseThrow(() -> new UserNotFoundException("用户不存在"));
        // 2. 调用领域服务创建文档（核心业务逻辑）
        Document document = documentDomainService.createDocument(user, command.getTitle(), command.getContent(), command.getTags());
        // 3. 返回操作结果（仅状态，不返回文档详情）
        return CommandResult.success(document.getId());
    }
}
```

- **Query（查询）**
  - 封装查询操作的请求参数，如分页、筛选条件等。
  - 与Command类似，也是数据载体，但聚焦于查询条件。
  - 示例：

```java
public class ListDocumentQuery {
    private final Integer page;
    private final Integer size;
    private final String keyword;

    public ListDocumentQuery(Integer page, Integer size, String keyword) {
        this.page = page == null ? 1 : page;
        this.size = size == null ? 10 : size;
        this.keyword = keyword;
    }

    // getter
}
```

- **Query Handler（查询处理器）**
  - 负责执行查询，直接对接读数据源（如读库、缓存）。
  - 返回专为前端定制的视图模型（VO），无需经过复杂的领域模型转换。
  - 示例：

```java
@Service
public class ListDocumentQueryHandler {
    // 可直接注入读库的Mapper或专门的查询Repository
    private final DocumentQueryMapper documentQueryMapper;

    @Autowired
    public ListDocumentQueryHandler(DocumentQueryMapper documentQueryMapper) {
        this.documentQueryMapper = documentQueryMapper;
    }

    public PageResult<DocumentVO> handle(ListDocumentQuery query) {
        // 直接查询读库，返回扁平的VO对象
        Integer offset = (query.getPage() - 1) * query.getSize();
        List<DocumentVO> list = documentQueryMapper.listDocuments(offset, query.getSize(), query.getKeyword());
        Integer total = documentQueryMapper.countDocuments(query.getKeyword());
        return new PageResult<>(list, total, query.getPage(), query.getSize());
    }
}
```

- **Controller（接入层）**
    - 接收外部HTTP/RPC请求，分别封装为Command或Query，转发给对应的处理器。
    - 不包含业务逻辑，仅做请求适配。
    - 示例：

```java
@RestController
@RequestMapping("/documents")
public class DocumentController {
    private final CreateDocumentCommandHandler commandHandler;
    private final ListDocumentQueryHandler queryHandler;

    @Autowired
    public DocumentController(CreateDocumentCommandHandler commandHandler, ListDocumentQueryHandler queryHandler) {
        this.commandHandler = commandHandler;
        this.queryHandler = queryHandler;
    }

    // 命令侧接口：创建文档（写操作）
    @PostMapping
    public ResponseEntity<CommandResult> createDocument(@RequestHeader("Authorization") String token, @Valid @RequestBody CreateDocumentRequest request) {
        CreateDocumentCommand command = CreateDocumentCommand.create(token, request.getTitle(), request.getContent(), request.getTags());
        CommandResult result = commandHandler.handle(command);
        return ResponseEntity.ok(result);
    }

    // 查询侧接口：查询文档列表（读操作）
    @GetMapping
    public ResponseEntity<PageResult<DocumentVO>> listDocuments(@RequestParam(required = false) Integer page, @RequestParam(required = false) Integer size, @RequestParam(required = false) String keyword) {
        ListDocumentQuery query = new ListDocumentQuery(page, size, keyword);
        PageResult<DocumentVO> result = queryHandler.handle(query);
        return ResponseEntity.ok(result);
    }
}
```

## 三、CQRS的优势与适用场景

### 1. 核心优势
- **职责清晰，降低复杂度**：读写逻辑完全分离，命令侧专注业务规则，查询侧专注查询效率，避免模型臃肿。
- **独立优化，提升性能**：命令侧可优化事务、幂等性；查询侧可自由使用缓存、读库、分库分表，甚至构建专门的查询索引，应对高并发读请求。
- **灵活扩展**：读写侧可独立扩容，比如读侧加机器、加缓存，不影响写侧；新增查询需求时，只需扩展查询侧，无需修改命令侧的核心业务逻辑。
- **适配复杂业务**：在DDD架构中，命令侧可完美对接领域模型，查询侧可脱离领域模型，直接返回前端需要的数据结构，减少领域模型到视图模型的转换成本。

### 2. 适用场景
- **读写压力不均衡**的系统：如电商商品详情页（读多写少）、金融交易系统（写多读少）。
- **业务逻辑复杂**的系统：写操作有严格的业务规则校验，读操作有多样化的查询需求（如多维度筛选、聚合统计）。
- **需要与事件溯源（Event Sourcing）结合**的系统：事件溯源只记录事件（命令执行记录），不存储当前状态，查询侧需要通过重放事件生成查询模型，CQRS的读写分离天然适配这种场景。

### 3. 注意事项（CQRS不是银弹）
- **增加系统复杂度**：相比CRUD，CQRS需要维护两套模型（命令侧+查询侧），开发和维护成本更高。
- **不适合简单系统**：如果系统业务逻辑简单，读写需求一致，使用CQRS会“过度设计”。
- **可能存在数据一致性问题**：若读写侧使用不同数据源（如写主库、读从库），会存在主从同步延迟，需要根据业务场景选择最终一致性方案。

## 四、CQRS与相关技术的关系

1. **与命令模式的关系**
    - 命令模式是**代码级设计模式**，核心是“封装请求为对象”，解耦请求发起者和处理者；
    - CQRS是**架构级模式**，核心是“读写分离”；
    - 命令模式是CQRS命令侧的常用落地手段（即Command+CommandHandler的实现），但二者并非同一概念。
2. **与DDD的关系**
    - CQRS与DDD高度契合：`命令侧对应DDD的领域层和应用层`，通过聚合根、领域服务保证业务规则；`查询侧可脱离DDD模型`，直接面向UI构建查询模型。
    - DDD的应用服务可作为Command Handler的实现载体，协调领域层完成命令执行。
3. **与事件溯源（Event Sourcing）的关系**
    - 事件溯源是一种数据存储方式，只记录系统中发生的事件（如“创建文档”“更新文档标题”），不存储数据的当前状态；
    - CQRS的命令侧负责记录事件，查询侧负责通过重放事件生成当前状态的查询模型；
    - 二者结合可实现完整的事件驱动架构，支持数据回溯、审计等高级需求。

## 五、CQRS + DDD 项目目录结构

*（Java/Spring Boot 技术栈）*

这个目录结构严格遵循 **DDD分层思想** 和 **CQRS读写分离原则**，兼顾了代码规范性、职责清晰性和可扩展性，可直接基于此搭建项目。

### 整体目录结构
```
src/main/java/com/yourcompany/yourproject/
├── YourProjectApplication.java          // 项目启动类
├── config/                               // 全局配置（跨层）
│   ├── WebConfig.java                    // Web相关配置（拦截器、转换器）
│   ├── SecurityConfig.java               // 权限安全配置
│   ├── MybatisConfig.java                // ORM框架配置（若使用）
│   └── RedisConfig.java                  // 缓存配置（查询侧用）
├── infrastructure/                       // 基础设施层（技术支撑）
│   ├── web/                              // Web接入层（Controller）
│   │   ├── command/                      // 命令侧Controller（写操作）
│   │   │   ├── DocumentCommandController.java
│   │   │   └── UserCommandController.java
│   │   ├── query/                        // 查询侧Controller（读操作）
│   │   │   ├── DocumentQueryController.java
│   │   │   └── UserQueryController.java
│   │   └── common/                       // 公共Web组件
│   │       ├── GlobalExceptionHandler.java // 全局异常处理器
│   │       └── ResponseAdvice.java       // 统一响应封装
│   ├── persistence/                     // 持久化层（Repository实现）
│   │   ├── command/                      // 命令侧持久化（写库）
│   │   │   ├── DocumentCommandRepositoryImpl.java
│   │   │   └── UserCommandRepositoryImpl.java
│   │   ├── query/                        // 查询侧持久化（读库/缓存）
│   │   │   ├── DocumentQueryRepositoryImpl.java
│   │   │   └── UserQueryRepositoryImpl.java
│   │   └── po/                           // 数据库实体（DO）
│   │       ├── DocumentDO.java
│   │       └── UserDO.java
│   ├── security/                         // 安全相关基础设施
│   │   ├── TokenParser.java              // Token解析工具
│   │   └── PermissionChecker.java        // 权限校验工具
│   └── cache/                            // 缓存工具（查询侧用）
│       └── RedisCacheManager.java
├── application/                          // 应用层（CQRS核心逻辑载体）
│   ├── command/                          // 命令侧（写操作）
│   │   ├── handler/                      // 命令处理器（核心业务编排）
│   │   │   ├── CreateDocumentCommandHandler.java
│   │   │   ├── UpdateDocumentCommandHandler.java
│   │   │   └── DeleteDocumentCommandHandler.java
│   │   ├── model/                        // 命令模型（不可变数据载体）
│   │   │   ├── CreateDocumentCommand.java
│   │   │   ├── UpdateDocumentCommand.java
│   │   │   └── DeleteDocumentCommand.java
│   │   ├── dto/                          // 命令侧入参DTO（接收前端请求）
│   │   │   ├── CreateDocumentRequest.java
│   │   │   └── UpdateDocumentRequest.java
│   │   └── result/                       // 命令侧返回结果
│   │       ├── CommandResult.java        // 通用命令结果（成功/失败/ID）
│   │       └── CommandError.java         // 命令错误信息
│   ├── query/                            // 查询侧（读操作）
│   │   ├── handler/                      // 查询处理器（查询逻辑）
│   │   │   ├── ListDocumentQueryHandler.java
│   │   │   └── GetDocumentDetailQueryHandler.java
│   │   ├── model/                        // 查询模型（查询条件载体）
│   │   │   ├── ListDocumentQuery.java
│   │   │   └── GetDocumentDetailQuery.java
│   │   ├── dto/                          // 查询侧入参DTO（分页/筛选条件）
│   │   │   ├── DocumentPageQuery.java
│   │   │   └── DocumentDetailQuery.java
│   │   └── vo/                           // 查询侧返回VO（前端视图模型）
│   │       ├── DocumentVO.java
│   │       └── DocumentPageVO.java
│   └── common/                           // 应用层公共组件
│       ├── PageResult.java               // 通用分页结果
│       └── BusinessException.java        // 自定义业务异常
├── domain/                               // 领域层（核心业务规则）
│   ├── model/                            // 领域模型（聚合根/实体/值对象）
│   │   ├── document/
│   │   │   ├── Document.java             // 文档聚合根
│   │   │   ├── DocumentTitle.java        // 标题值对象（限长、格式校验）
│   │   │   └── DocumentStatus.java       // 状态枚举
│   │   └── user/
│   │       ├── User.java                 // 用户聚合根
│   │       └── UserId.java               // 用户ID值对象
│   ├── service/                          // 领域服务（跨聚合业务规则）
│   │   ├── DocumentDomainService.java    // 文档领域服务
│   │   └── UserDomainService.java        // 用户领域服务
│   ├── repository/                       // 仓储接口（领域层定义，基础设施层实现）
│   │   ├── command/                      // 命令侧仓储接口（写）
│   │   │   ├── DocumentCommandRepository.java
│   │   │   └── UserCommandRepository.java
│   │   └── query/                        // 查询侧仓储接口（读）
│   │       ├── DocumentQueryRepository.java
│   │       └── UserQueryRepository.java
│   └── event/                            // 领域事件（可选，事件驱动用）
│       ├── DocumentCreatedEvent.java
│       └── DocumentUpdatedEvent.java
└── util/                                 // 通用工具类（跨层）
    ├── DateUtils.java
    ├── JsonUtils.java
    └── ValidationUtils.java

src/main/resources/
├── application.yml                       // 全局配置文件
├── mapper/                               // MyBatis映射文件（若使用）
│   ├── command/                          // 命令侧Mapper.xml（写库）
│   └── query/                            // 查询侧Mapper.xml（读库）
└── sql/                                  // 初始化SQL脚本
    ├── schema_master.sql                 // 主库（命令侧）表结构
    └── schema_slave.sql                  // 从库（查询侧）表结构
```

### 各目录核心职责说明

#### 1. 基础设施层 `infrastructure`
- `web/command` & `web/query`：严格分离读写接口，命令侧Controller只处理增删改，查询侧只处理查询，避免接口混杂。
- `persistence/command` & `persistence/query`：读写仓储实现分离，可对接不同数据源（如命令侧连主库，查询侧连从库/缓存）。
- `persistence/po`：数据库实体，仅与数据库表对应，不包含任何业务逻辑。

#### 2. 应用层 `application`
- `command/handler`：命令处理器，是写操作的核心逻辑载体，**依赖领域层服务和命令侧仓储**，负责业务流程编排（如校验→调用领域服务→持久化）。
- `command/model`：命令对象，**不可变设计**（私有构造+静态工厂+仅getter），内置参数校验，确保请求数据合法。
- `query/handler`：查询处理器，专注查询效率，可直接调用查询侧仓储或缓存，返回扁平VO，无需经过领域模型转换。
- `query/vo`：视图对象，完全贴合前端需求，避免返回冗余字段。

#### 3. 领域层 `domain`
- `model`：领域核心，包含聚合根、实体、值对象，封装核心业务规则（如`Document`的标题长度校验、状态流转规则）。
- `service`：领域服务，处理跨聚合的业务逻辑（如“分享文档需要同时校验文档权限和用户关系”）。
- `repository`：仓储接口，**由领域层定义标准**，基础设施层实现具体技术细节，保证领域层不依赖外部技术。
- `event`：领域事件，用于事件驱动场景（如文档创建后发送事件，通知其他模块更新统计数据）。

### 关键设计原则（落地时需遵守）

1. 严格读写分离：命令侧不做查询，查询侧不修改数据；命令侧返回操作状态（成功/失败/ID），查询侧返回视图数据。
2. 领域层纯净：领域层**不依赖任何外部包**（如Spring、MyBatis），只定义业务规则，确保业务逻辑不被技术细节污染。
3. 依赖方向正确：遵循“上层依赖下层，内层依赖外层”，即 `infrastructure → application → domain`，反向依赖通过接口实现。
4. DTO/VO/DO 隔离：DTO（前端入参）→ Command/Query → 领域模型/DO → VO（前端出参），层级转换清晰，避免对象混用。

## 六、总结

CQRS的本质是**通过读写分离，让系统的两个核心职责（修改状态、读取状态）各自专注、独立优化**。它不是一个必须使用的架构，但在复杂业务场景下，能有效解决传统CRUD架构的痛点。

使用CQRS的关键是**权衡场景**：简单系统优先CRUD，复杂、高并发、读写差异化大的系统可考虑CQRS。