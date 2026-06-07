# sh.wss.moe - 一键安装脚本合集

给新 Linux 系统（主要是 Ubuntu 24.04+ / Debian-based）快速部署常用工具的脚本集合。

## 使用方式

```bash
# 推荐写法（大多数需要 root 权限的脚本）
sudo bash <(curl -fsSL sh.wss.moe/firefox)

# 不需要 root 的脚本
bash <(curl -fsSL sh.wss.moe/ps1)

# 或者换一种执行方式?
curl -fsSL sh.wss.moe/uv | bash -s

# 查看帮助（任意一种写法都行）
curl sh.wss.moe/firefox.help
curl sh.wss.moe/help/firefox
curl sh.wss.moe/help/firefox.txt
```
