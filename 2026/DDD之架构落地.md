# DDD之架构落地

## 目录结构

```bash
# 目录结构
├── application ## 应用层：编排业务流程，不包含核心业务规则
                ## -> 应用服务（如OrderApplicationService）：调用领域层完成下单、支付等流程
                ## -> 命令 / 查询对象（如CreateOrderCommand）
├── domain  ## 领域层（核心）：封装业务规则、领域模型
            ## -> 聚合根（如Order）
            ## -> 领域对象（实体OrderItem、值对象Money）
            ## -> 领域服务（如InventoryDomainService）
            ## -> 领域事件（如OrderPaidEvent）
├── StartApp.java
├── infrastructure  ## 基础设施层：提供技术支撑，屏蔽外部依赖
                    ## -> 仓储实现（如OrderRepositoryImpl）
                    ## -> 数据库访问、消息队列、第三方接口调用等
                    ## -> 工具类、配置类
```

1. **抽象业务代码**：
   - 业务规则的抽象（比如订单状态、仓储接口）→ 写在**Domain层**；
   - 技术能力的抽象（比如缓存接口）→ 写在**Domain层**（供上层依赖），由Infrastructure层实现。

2. **具体业务代码**：
   - 核心业务逻辑（比如订单取消规则）→ 写在**Domain层**（实体/领域服务）；
   - 业务流程编排（比如取消订单+扣库存）→ 写在**Application层**；
   - 技术细节实现（比如数据库操作、第三方调用）→ 写在**Infrastructure层**。

3. **核心原则**：Domain 层只关心业务，不关心技术；Application 层只关心流程，不关心规则；Infrastructure 层只关心技术，不关心业务。
   - Domain 层只关心业务，不关心技术；
   - Application 层只关心流程，不关心规则；
   - Infrastructure 层只关心技术，不关心业务。

## 领域驱动设计核心元素

```
领域驱动设计（DDD）核心元素
├─ 领域层核心元素
│  ├─ 领域对象
│  │  ├─ 实体（Entity）—— 有唯一标识，承载自身业务行为，生命周期内状态可变
│  │  │  └─ 聚合根（Aggregate Root）—— 聚合的核心，维护聚合内数据一致性，作为外部访问聚合的唯一入口
│  │  └─ 值对象（Value Object）—— 无唯一标识，以属性值定义
│  └─ 领域服务（Domain Service）—— 独立分类，承载跨对象无状态业务逻辑
│  ├─ 领域事件（Domain Event）—— 领域内发生的重要业务事件，用于解耦
│  └─ 领域规则（Domain Rule）—— 业务约束（如订单金额不能为负），可嵌入对象或服务
├─ 聚合（Aggregate）—— 领域对象的组合单元，由聚合根+关联实体/值对象构成
├─ 仓储（Repository）—— 领域层与数据层的桥梁，负责聚合的持久化（只操作聚合根）
└─ 应用服务（Application Service）—— 编排领域逻辑，处理流程性需求（如接收请求、调用领域服务/仓储）
```

## 数据流动

```
外部世界
   │
   ▼
Application Service(事务、DTO、用例编排)
   │
   ├─► 调用聚合根的方法（单聚合内业务）
   │
   └─► 调用领域服务（跨聚合或纯算法）
           │
           └─► 领域服务内部再调用多个聚合根或值对象
```

## 先统一底层原则

所有能实现 “核心定义抽象端口、外层实现适配器” 的模式 / 手段，都能落地洋葱 / 六边形架构

无论用哪种模式，都必须遵守洋葱/六边形架构的核心：

1. **核心不依赖外层**：抽象端口定义在核心层；
2. **外层依赖核心**：适配器实现放在外层；
3. **接口隔离**：每个端口只对应一类外部依赖，不混杂。

## 常用落地模式（按外部依赖类型分类）

## 洋葱/六边形架构落地模式列表
| 模式               | 核心用途                        | 典型外部依赖           | 核心层端口位置               | 适配器实现位置                             |
| ------------------ | ------------------------------- | ---------------------- | ---------------------------- | ------------------------------------------ |
| 1. 仓储模式        | 隔离核心与数据存储（持久化）    | MySQL、Redis、MongoDB  | `domain/repository`          | `infrastructure/repository`                |
| 2. 端口-适配器模式 | 通用外部系统对接                | 第三方API、OSS、短信   | `domain/service`             | `infrastructure/integration`               |
| 3. 门面模式        | 封装复杂外部系统的API           | 支付系统、ERP、CRM     | `domain/service`             | `infrastructure/integration`（门面类嵌套） |
| 4. 观察者/事件驱动 | 解耦同步主流程与异步操作        | 消息队列、通知、日志   | `domain/event`               | `infrastructure/listeners`                 |
| 5. 策略模式        | 同一类依赖的多实现动态切换      | 多存储、多支付、多登录 | `domain/service`（策略接口） | `infrastructure/integration`（策略实现）   |
| 6. 适配器模式      | 接口格式/协议不兼容时的格式转换 | 老系统、异构系统       | `domain/service`             | `infrastructure/integration`               |

### 仓储模式（Repository Pattern）
- **适用场景**：专门隔离**核心层与数据存储系统**的解耦（数据库、缓存、文件系统等），是洋葱/六边形架构中“数据持久化”场景的专属落地模式，也是DDD架构的核心战术模式。
- **核心思想**
  - 核心层（`domain`）定义**仓储接口（端口）**：只描述“业务语义”的CRUD操作，不涉及任何存储技术细节；
  - 基础设施层（`infrastructure`）实现**仓储适配器**：负责将领域模型转换为数据对象（DO/PO），并对接具体的存储技术（MySQL、Redis等）；
  - 核心层只依赖仓储接口，完全不感知底层存储介质（换数据库无需改核心逻辑）。
- 代码示例

```java
// 1. 核心层（domain/repository）：定义仓储端口（输出端口）
// 只关注业务语义，不涉及任何数据库操作
public interface FileRepository {
    // 业务语义方法：按用户ID+文件状态查询
    List<FileAggregate> findByUserIdAndStatus(Long userId, FileStatus status);
    // 保存/更新领域聚合
    FileAggregate save(FileAggregate fileAggregate);
    // 删除（按业务ID，非数据库主键）
    void deleteByFileId(String fileId);
}

// 2. 核心层（domain/model）：领域聚合（充血模型，包含业务逻辑）
public class FileAggregate {
    private String fileId; // 业务ID（核心层关注）
    private Long userId;
    private String fileName;
    private Long fileSize;
    private FileStatus status;

    // 业务逻辑：自我校验
    public void validate() {
        if (fileSize > 10 * 1024 * 1024) {
            throw new BusinessException("文件大小超过10MB");
        }
    }

    // getter/必要的setter（状态通过方法修改，而非直接set）
    public void markAsUploaded() {
        this.status = FileStatus.UPLOADED;
    }
}

// 3. 基础设施层（infrastructure/entity）：数据对象（DO，仅映射数据库表）
@TableName("t_file")
public class FileDO {
    @TableId(type = IdType.AUTO)
    private Long id; // 数据库主键（核心层不关心）
    private String fileId; // 业务ID
    private Long userId;
    private String fileName;
    private Long fileSize;
    private Integer status; // 状态码（核心层用枚举，这里用数字）

    // 仅getter/setter，无业务逻辑
}

// 4. 基础设施层（infrastructure/repository）：仓储适配器（实现端口）
@Repository
public class FileRepositoryImpl implements FileRepository {
    @Autowired
    private FileDOMapper fileDOMapper; // 对接MyBatis，仅在适配器中依赖

    @Override
    public List<FileAggregate> findByUserIdAndStatus(Long userId, FileStatus status) {
        // 适配器核心工作：1. 转换参数 2. 调用存储 3. 转换返回值
        // 1. 核心层枚举 → 数据库状态码
        Integer statusCode = status.getCode();
        // 2. 调用数据库（存储细节，核心层无感知）
        List<FileDO> fileDOList = fileDOMapper.selectByUserIdAndStatus(userId, statusCode);
        // 3. DO → 领域聚合（隔离核心层与数据库结构）
        return fileDOList.stream()
                .map(FileConverter::toAggregate)
                .collect(Collectors.toList());
    }

    @Override
    public FileAggregate save(FileAggregate fileAggregate) {
        // 1. 领域聚合 → DO
        FileDO fileDO = FileConverter.toDO(fileAggregate);
        // 2. 执行数据库操作（新增/更新）
        if (fileDO.getId() == null) {
            fileDOMapper.insert(fileDO);
        } else {
            fileDOMapper.updateById(fileDO);
        }
        // 3. 更新聚合的数据库主键（可选，核心层一般不关注）
        fileAggregate.setDbId(fileDO.getId());
        return fileAggregate;
    }

    @Override
    public void deleteByFileId(String fileId) {
        fileDOMapper.deleteByFileId(fileId);
    }
}

// 5. 应用层调用（只依赖仓储接口，不依赖实现）
@Service
public class FileApplicationService {
    @Autowired
    private FileRepository fileRepository; // 依赖抽象端口

    public List<FileVO> listUserFiles(Long userId) {
        // 调用仓储接口（核心层逻辑，无数据库细节）
        List<FileAggregate> files = fileRepository.findByUserIdAndStatus(userId, FileStatus.UPLOADED);
        // 转换为VO返回
        return files.stream()
                .map(FileConverter::toVO)
                .collect(Collectors.toList());
    }
}
```

### 端口-适配器模式（Port-Adapter Pattern）

- **适用场景**：对接所有外部系统的“通用模式”（第三方API、消息队列、缓存、支付系统等），是六边形架构的“原生落地模式”；
- **核心思想**：核心层定义「端口（抽象接口）」，基础设施层实现「适配器」，适配器负责适配外部系统的协议/格式；
- **代码示例（对接阿里云OSS）**：

```java
// 1. 核心层（domain/service）：定义输出端口（核心调用外部的接口）
public interface OssPort {
    // 只定义业务语义，不涉及任何阿里云API
    String uploadFile(InputStream inputStream, String fileName, FileType fileType);
    void deleteFile(String fileUrl);
}

// 2. 基础设施层（infrastructure/integration）：实现适配器
@Service
public class AliOssAdapter implements OssPort {
    // 依赖阿里云OSS的SDK（仅在适配器中引入）
    @Autowired
    private OSSClient ossClient;
    @Value("${oss.bucket}")
    private String bucketName;

    @Override
    public String uploadFile(InputStream inputStream, String fileName, FileType fileType) {
        // 适配阿里云OSS的具体逻辑（核心层无需感知）
        String objectKey = fileType.getCode() + "/" + fileName;
        ossClient.putObject(bucketName, objectKey, inputStream);
        return "https://" + bucketName + ".oss-cn-hangzhou.aliyuncs.com/" + objectKey;
    }

    @Override
    public void deleteFile(String fileUrl) {
        // 解析URL获取objectKey，调用阿里云删除接口
        String objectKey = parseObjectKey(fileUrl);
        ossClient.deleteObject(bucketName, objectKey);
    }
}

// 3. 应用层调用（只依赖端口，不依赖适配器）
@Service
public class FileApplicationService {
    @Autowired
    private OssPort ossPort; // 依赖抽象端口，而非具体适配器

    public FileVO upload(FileUploadDTO dto) {
        FileAggregate file = FileConverter.toAggregate(dto);
        file.validate();
        // 调用端口，无需关心是阿里云/腾讯云OSS
        String fileUrl = ossPort.uploadFile(dto.getInputStream(), file.getFileName(), file.getFileType());
        file.setFileUrl(fileUrl);
        fileRepository.save(file);
        return FileConverter.toVO(file);
    }
}
```

### 门面模式（Facade Pattern）

- **适用场景**：对接复杂的外部系统（如支付系统、ERP系统），外部系统提供的API多且杂，需要封装简化；
- **核心思想**：适配器中通过“门面类”封装外部系统的复杂API，对外暴露简洁的接口（适配核心层的端口）；
- **代码示例（对接微信支付）**：

```java
// 1. 核心层：定义支付端口(domain/service/PaymentPort.java)
public interface PaymentPort {
    PaymentResult pay(OrderAggregate order, PayType payType);
}

// 2. 基础设施层：适配器 + 门面封装(infrastructure/integration/WxPayAdapter.java)
@Service
public class WxPayAdapter implements PaymentPort {
    // 门面类：封装微信支付的复杂API
    private WxPayFacade wxPayFacade = new WxPayFacade();

    @Override
    public PaymentResult pay(OrderAggregate order, PayType payType) {
        // 1. 领域模型转换为微信支付所需参数（适配）
        WxPayRequest request = new WxPayRequest();
        request.setOutTradeNo(order.getOrderNo());
        request.setTotalFee(order.getAmount().getCent()); // 转换金额单位
        request.setBody(order.getProductName());
        request.setTradeType(payType.getCode());

        // 2. 调用门面类（封装了签名、调接口、验签等复杂逻辑）
        WxPayResponse response = wxPayFacade.unifiedOrder(request);

        // 3. 转换为核心层的PaymentResult
        return PaymentResult.builder()
                .success(response.isSuccess())
                .tradeNo(response.getTransactionId())
                .build();
    }

    // 门面类：封装微信支付的所有复杂逻辑
    private class WxPayFacade {
        public WxPayResponse unifiedOrder(WxPayRequest request) {
            // 1. 生成签名
            String sign = generateSign(request);
            request.setSign(sign);
            // 2. 调用微信支付统一下单API
            String result = HttpUtil.post("https://api.mch.weixin.qq.com/pay/unifiedorder", request);
            // 3. 验签、解析响应
            return parseAndVerifyResponse(result);
        }

        // 其他私有方法：生成签名、验签、解析响应等
    }
}
```

### 观察者模式（Observer Pattern）/ 事件驱动模式

- **适用场景**：核心逻辑执行后需要触发异步操作（如文件上传后发通知、订单支付后扣库存），解耦“主流程”和“异步流程”；
- **核心思想**：核心层发布「领域事件」，基础设施层实现「事件监听器（适配器）」，监听器对接外部系统（如短信、MQ）；
- **代码示例（文件上传后发送短信通知）**：

```java
// 1. 核心层（domain/event）：定义领域事件(domain/event/FileUploadedEvent.java)
public class FileUploadCompletedEvent {
    private FileAggregate file;
    private UserAggregate user;

    // 构造器、getter
    public FileUploadCompletedEvent(FileAggregate file, UserAggregate user) {
        this.file = file;
        this.user = user;
    }
}

// 2. 核心层（application/service）：发布事件（只依赖事件抽象，不依赖监听器）
@Service
public class FileApplicationService {
    @Autowired
    private ApplicationEventPublisher eventPublisher;

    public FileVO upload(FileUploadDTO dto) {
        // 省略文件上传核心逻辑...
        FileAggregate file = fileRepository.save(file);
        UserAggregate user = userRepository.findById(dto.getUserId());

        // 发布领域事件（核心层不关心谁监听）
        eventPublisher.publishEvent(new FileUploadCompletedEvent(file, user));
        return FileConverter.toVO(file);
    }
}

// 3. 基础设施层（infrastructure/listeners）：实现事件监听器（适配器）
@Component
public class SmsNotifyListener implements ApplicationListener<FileUploadCompletedEvent> {
    @Autowired
    private SmsPort smsPort; // 依赖短信端口

    @Override
    public void onApplicationEvent(FileUploadCompletedEvent event) {
        FileAggregate file = event.getFile();
        UserAggregate user = event.getUser();
        // 调用短信端口发送通知（对接外部短信系统）
        smsPort.sendSms(user.getPhone(), "文件上传成功：" + file.getFileName());
    }
}
```

### 策略模式（Strategy Pattern）
- **适用场景**：同一类外部依赖有多种实现（如文件存储支持OSS/本地/MinIO、支付支持微信/支付宝），需要动态切换；
- **核心思想**：核心层定义「策略接口（端口）」，基础设施层实现不同「策略类（适配器）」，应用层按需选择策略；
- **代码示例（多文件存储策略）**：

```java
// 1. 核心层：定义存储策略端口（策略接口，domain/service/FileStorageStrategy.java）
public interface FileStorageStrategy {
    String store(InputStream inputStream, String fileName);
}

// 2. 基础设施层：实现不同策略（适配器）
// 2.1 OSS 存储策略(infrastructure/integration/OssStorageStrategy.java)
@Service("ossStorageStrategy")
public class OssStorageStrategy implements FileStorageStrategy {
    @Autowired
    private OssPort ossPort;

    @Override
    public String store(InputStream inputStream, String fileName) {
        return ossPort.uploadFile(inputStream, fileName, FileType.OTHER);
    }
}

// 2.2 本地存储策略(infrastructure/integration/LocalStorageStrategy.java)
@Service("localStorageStrategy")
public class LocalStorageStrategy implements FileStorageStrategy {
    @Value("${file.local.path}")
    private String localPath;

    @Override
    public String store(InputStream inputStream, String fileName) {
        // 本地文件存储逻辑
        String filePath = localPath + "/" + fileName;
        FileUtil.writeFromStream(inputStream, new File(filePath));
        return "file://" + filePath;
    }
}

// 3. 应用层：动态选择策略(application/api/impl/FileAppServiceImpl.java)
@Service
public class FileApplicationService {
    @Autowired
    private Map<String, FileStorageStrategy> storageStrategyMap;

    public FileVO upload(FileUploadDTO dto) {
        FileAggregate file = FileConverter.toAggregate(dto);
        file.validate();

        // 根据文件类型选择存储策略（核心层逻辑）
        FileStorageStrategy strategy;
        if (file.getFileType() == FileType.VIDEO) {
            strategy = storageStrategyMap.get("ossStorageStrategy");
        } else {
            strategy = storageStrategyMap.get("localStorageStrategy");
        }

        // 调用策略（不关心具体实现）
        String fileUrl = strategy.store(dto.getInputStream(), file.getFileName());
        file.setFileUrl(fileUrl);
        fileRepository.save(file);
        return FileConverter.toVO(file);
    }
}
```

### 适配器模式（Adapter Pattern）

- **适用场景**：外部系统的接口格式与核心层端口不兼容（如老系统API返回XML，核心层需要JSON；第三方接口参数名不一致）；
- **核心思想**：在适配器中做“格式转换”，让不兼容的接口适配核心层的端口定义；
- **代码示例（适配老系统XML接口）**：

```java
// 1. 核心层：定义用户查询端口（期望JSON/POJO，domain/service/UserQueryPort.java）
public interface UserQueryPort {
    UserAggregate findByPhone(String phone);
}

// 2. 基础设施层：适配器（适配老系统XML接口，infrastructure/integration/OldSystemUserAdapter.java）
@Service
public class OldSystemUserAdapter implements UserQueryPort {
    @Autowired
    private OldSystemClient oldSystemClient; // 老系统客户端，返回XML

    @Override
    public UserAggregate findByPhone(String phone) {
        // 1. 调用老系统XML接口
        String xmlResponse = oldSystemClient.getUserByPhone(phone);
        // 2. 适配：XML转换为核心层的UserAggregate
        UserXmlModel xmlModel = XmlUtil.parse(xmlResponse, UserXmlModel.class);
        return UserConverter.toAggregate(xmlModel);
    }
}
```

## 总结

1. **仓储模式是“数据存储专属”**：是洋葱/六边形架构中解决“持久化”的核心模式，其他模式解决“非存储类外部依赖”；
2. **所有模式遵循同一原则**：核心层定义抽象端口（接口），基础设施层实现适配器，核心不依赖外层，外层依赖核心；
3. **模式可组合使用**：比如“仓储模式+策略模式”实现多数据源切换（MySQL/Redis仓储策略），“端口-适配器+门面模式”对接复杂支付系统；
4. **仓储模式是DDD标配**：只要用DDD+洋葱/六边形架构，必然会用仓储模式解决数据存储解耦，其他模式按需选择。





