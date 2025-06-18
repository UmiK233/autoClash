# autoClash4Linux
## 在Linux上自动配置Clash(CLI)

### 注意事项

**请将config.yaml换成自己可用的,默认为空文件**

**默认clash二进制执行文件对应架构为amd64, 如有需要请下载其他版本并重命名为clash替换该文件**

**本项目还提供arm64架构的clash**

### 使用方法

将本仓库克隆到本地后执行source autoclash.sh

会在~/.bashrc下添加proxy_on与proxy_off两个函数,在终端下执行即可
