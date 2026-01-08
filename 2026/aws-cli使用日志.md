# AWS-CLI使用日志

## 安装

```bash
sudo snap install aws-cli --classic
```

## 配置

```bash
aws configure

## 然后依次输入
AWS Access Key ID [None]: AKIATO73B  # 你的Access Key ID
AWS Secret Access Key [None]: GM8r0NzvH9lGEc8  # 你的Secret Key
Default region name [None]: ap-southeast-1  # 对应你的S3区域（新加坡）
Default output format [None]: json  # 输出格式（可选：json/table/text）
```

## 常用命令说明

### 查看

```bash
# 1. 列出所有存储桶
aws s3 ls

# 2. 列出目标存储桶内的所有文件（含详细信息：大小、时间、文件名）
aws s3 ls s3://test-bucket/

# 3. 递归列出所有文件（含子目录）
aws s3 ls s3://test-bucket/ --recursive

# 4. 查看文件大小（人类可读格式，如MB/GB）
aws s3 ls s3://test-bucket/你的文件.txt --human-readable
```

### 上传 / 下载文件

```bash
# 1. 本地文件上传到S3
aws s3 cp /本地路径/文件.txt s3://test-bucket/目标路径/

# 2. S3文件下载到本地
aws s3 cp s3://test-bucket/文件.txt /本地保存路径/

# 3. 递归上传目录（比如把本地data目录全传到S3）
aws s3 cp /本地data目录/ s3://test-bucket/data/ --recursive

# 4. 递归下载S3目录到本地
aws s3 cp s3://test-bucket/data/ /本地保存目录/ --recursive
```

### 删除 / 移动 S3 文件

```bash
# 1. 删除S3单个文件
aws s3 rm s3://test-bucket/要删除的文件.txt

# 2. 递归删除S3目录（谨慎使用！）
aws s3 rm s3://test-bucket/要删除的目录/ --recursive

# 3. 移动/重命名S3文件
aws s3 mv s3://test-bucket/旧文件名.txt s3://test-bucket/新文件名.txt
```

### 查看存储桶大小（统计占用空间）

```bash
# 统计存储桶总大小（人类可读格式）
aws s3 ls s3://test-bucket/ --recursive --human-readable --summarize
```

### 同步本地目录和 S3（增量同步，非常实用）

```bash
# 本地目录同步到S3（只传新增/修改的文件）
aws s3 sync /本地目录/ s3://test-bucket/目标目录/

# S3同步到本地（把S3的更新同步到本地）
aws s3 sync s3://test-bucket/目标目录/ /本地目录/
```


## 操作日志

### 罗列文件

```bash
aws s3 ls s3://test-bucket/ --recursive
```

### 排序

```bash
aws s3 ls s3://test-bucket/ --recursive | sort -k1,2
```

### 统计数据

```bash
aws s3 ls s3://test-bucket/ --recursive | wc -l

aws s3api list-objects-v2 --bucket test-bucket --query 'length(Contents[])'
```