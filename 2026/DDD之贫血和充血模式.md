# DDD之贫血和充血模式

这是 DDD 领域中最基础也最关键的概念 —— 两者的本质差异在于**业务逻辑的存放位置**，直接决定了代码是否符合 “面向对象” 和 DDD 的设计思想

## 核心定义
- **贫血模式**：对象只有属性（数据），没有行为（业务逻辑），业务逻辑全部放在独立的“服务类”中（如`FileService`），对象只是“数据容器”；
- **充血模式**：对象既有属性（数据），也有对应的行为（业务逻辑），业务逻辑内聚在领域对象中（如`FileAggregate`），服务类仅负责流程编排，不包含核心规则。

### 贫血模型

贫血模型（Anemic Domain Model），只包含数据，不包含业务逻辑的类。由于数据与操作分离，破坏了面向对象的封装特性，是一种典型的面向过程的编程风格。

举个例子来讲
- User、UserDAO作为数据访问层
- UserBO、UserService作为业务逻辑层
- UserVO、UserController作为接口层；

其中UserBO只作为纯粹的数据结构，没有业务处理，业务逻辑集中在Service中。像UserBO这样的纯数据结构的就可以称之为贫血模型，同样的还有User和UserVO，这样的设计破坏了Java面向对象设计的封装特性，属于面向过程的编程风格。

### 充血模型

充血模型（Rich Domain Model），将数据和业务放在一个类里面。这种充血模型满足面向对象的封装特性，是典型的面向对象编程风格。

DDD核心是为了根据业务对系统的服务进行拆分。领域驱动设计的核心还是基于对业务的理解，不能一味追求这样的概念。对于充血模型的开发的MVC架构，其核心区别在于Service层：包含Domain类和Service类。Domain对于BO而言，添加了一定的业务逻辑，降低Service中的业务逻辑量。

## 核心区别对比
| 对比维度         | 贫血模式（Anemic Domain Model）                        | 充血模式（Rich Domain Model）                                            |
| :--------------- | :----------------------------------------------------- | :----------------------------------------------------------------------- |
| **核心特征**     | 数据与行为分离：对象=数据，服务=逻辑                   | 数据与行为内聚：对象=数据+行为，服务=流程编排                            |
| **领域对象角色** | 纯POJO/DO，仅存储数据（如`FileDO`）                    | 领域模型（Aggregate/Entity），包含业务规则（如`FileAggregate`）          |
| **业务逻辑位置** | 全部在Service层（如`FileService`的`validateFile`方法） | 大部分在领域对象中（如`FileAggregate.validate()`），跨对象逻辑在领域服务 |
| **设计思想**     | 面向过程/数据驱动                                      | 面向对象/领域驱动                                                        |
| **典型场景**     | 简单CRUD系统、快速开发的小项目                         | 复杂业务系统、DDD架构的核心域                                            |

## 代码示例（以“文件上传校验”为例）

### 1. 贫血模式实现
```java
// 1. 贫血的领域对象（只有属性，无行为）
public class FileDO {
    private Long id;
    private String fileName;
    private Long fileSize; // 单位：字节
    private String fileType;
    // 只有getter/setter，无任何业务逻辑
    // ... getter/setter
}

// 2. 业务逻辑全部放在Service中（面向过程）
@Service
public class FileService {
    // 最大文件大小：10MB
    private static final Long MAX_SIZE = 10 * 1024 * 1024L;
    // 允许的文件类型
    private static final List<String> ALLOW_TYPES = Arrays.asList("jpg", "png", "pdf");

    // 所有校验逻辑都在Service中
    public void validateFile(FileDO fileDO) {
        // 校验文件大小
        if (fileDO.getFileSize() > MAX_SIZE) {
            throw new BusinessException("文件大小超过10MB");
        }
        // 校验文件类型
        String suffix = fileDO.getFileType().toLowerCase();
        if (!ALLOW_TYPES.contains(suffix)) {
            throw new BusinessException("不支持的文件类型");
        }
        // 校验文件名非空
        if (fileDO.getFileName() == null || fileDO.getFileName().trim().isEmpty()) {
            throw new BusinessException("文件名不能为空");
        }
    }

    // 上传文件（流程+逻辑都在Service）
    public void uploadFile(FileDO fileDO) {
        // 1. 校验（逻辑在Service）
        validateFile(fileDO);
        // 2. 保存（调用DAO）
        fileDAO.insert(fileDO);
    }
}
```

### 2. 充血模式实现
```java
// 1. 充血的领域对象（数据+行为内聚）
public class FileAggregate {
    private Long id;
    private String fileName;
    private Long fileSize;
    private String fileType;

    // 业务规则作为对象的常量（内聚在对象中）
    private static final Long MAX_SIZE = 10 * 1024 * 1024L;
    private static final List<String> ALLOW_TYPES = Arrays.asList("jpg", "png", "pdf");

    // 核心业务逻辑：自我校验（对象自己知道如何验证合法性）
    public void validate() {
        validateFileName();
        validateFileSize();
        validateFileType();
    }

    // 细分的校验逻辑（封装细节）
    private void validateFileName() {
        if (fileName == null || fileName.trim().isEmpty()) {
            throw new BusinessException("文件名不能为空");
        }
    }

    private void validateFileSize() {
        if (fileSize > MAX_SIZE) {
            throw new BusinessException("文件大小超过10MB");
        }
    }

    private void validateFileType() {
        String suffix = fileType.toLowerCase();
        if (!ALLOW_TYPES.contains(suffix)) {
            throw new BusinessException("不支持的文件类型");
        }
    }

    // 核心业务行为：上传（对象自己知道如何完成上传前的逻辑）
    public void prepareUpload() {
        this.validate(); // 上传前先自我校验
        this.setUploadStatus(UploadStatus.PREPARED); // 状态流转也由对象自己管理
    }

    // getter/setter（仅暴露必要的属性，状态流转通过方法而非直接set）
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    // ... 其他getter，状态类属性不提供setter，通过方法修改
}

// 2. 应用服务仅负责流程编排（无核心业务逻辑）
@Service
public class FileApplicationService {
    @Autowired
    private FileRepository fileRepository;

    public void uploadFile(FileUploadDTO dto) {
        // 1. DTO转换为领域对象
        FileAggregate file = FileConverter.toAggregate(dto);
        // 2. 调用领域对象的行为（逻辑在对象内）
        file.prepareUpload();
        // 3. 调用仓储保存（仅流程，无逻辑）
        fileRepository.save(file);
    }
}
```

## 为什么贫血模式比充血模式流行

- 那么充血模型对于贫血模型好在哪里呢？对于贫血模型而言，由于**数据和业务的分离，数据在脱离业务的情况下可以被任务程序修改，数据操作将不受限制等**。
- 为什么贫血模型这么盛行？一是对于大部分业务而言都比较简单，基本上都是围绕SQL的CRUD操作，仅仅通过贫血模型设计就可以完成业务。而是充血模型的设计难度较大。
- 两者设计思路的区别？
    - 前者通常是在拿到需求后，先根据数据库表建立Modle，然后Servcie、Controller等进行代码填充，其中一个很重要的核心就是SQL，对于这个需求而言，大部分业务都是围绕这简单亦或复杂的SQL来完成的，当这个模块需要其它功能的时候，往往都是在基础上添加SQL来实现的。这样就会导致其中有很大一部分代码产生冗余，随着业务的深入，将会有大量类似的SQL出现在系统中。在这个过程中，基本上就忽略了DDD开发模式，失去了很多代码复用的机会。 
    - 基于充血模型的DDD开发模式下，首先需要根据业务，定义领域模型所包含的数据和方法，相当于设计可复用的业务中间层。对于之后的新功能的开发，都将基于这些已经定义好的领域模型来开发。
    - 两者很大的区别就在于后者会花费更多的时间在领域模型设计上。

## 小结
基于充血模型的 DDD 开发模式跟基于贫血模型的传统开发模式相比，主要区别在 Service层。在基于充血模型的开发模式下，我们将部分原来在 Service 类中的业务逻辑移动到了一个充血的 Domain 领域模型中，让 Service 类的实现依赖这个 Domain 类。 在基于充血模型的 DDD 开发模式下，Service 类并不会完全移除，而是负责一些不适合放在 Domain 类中的功能。比如，负责与 Repository 层打交道、跨领域模型的业务聚合功能、幂等事务等非功能性的工作

## 参考
- [代码设计-贫血模型和充血模型](https://juejin.cn/post/7034390958460370958)