你现在帮我维护 sh.wss.moe 项目。

核心要求：
1. 脚本文件放在 /scripts/xxx.sh，帮助文件放在 /help/xxx.txt
2. 脚本第一行：#!/usr/bin/env bash
   第二行：set -euo pipefail
   第三行起：# Help: curl https://sh.wss.moe/xxx.help
3. 所有让用户直接执行的命令（不包括脚本内部的注释），必须每条单独一行（方便用户复制）
4. 前置依赖检查统一写法：
   command -v xxx >/dev/null || { echo "Missing xxx, please install it first."; exit 1; }
5. 需要 root 权限的脚本：内部直接写 sudo xxx，用户执行时用 | sudo bash
   不需要在脚本里写 "requires sudo" 提示
6. 不需要 root 的脚本：直接 bash 执行
7. 脚本开头必须有：
   echo "=== Title ==="
   echo "Help: curl https://sh.wss.moe/xxx.help"
   echo "Contact: https://wyf9.top/c"
   echo ""
8. 脚本结尾统一 echo "Done."
9. 帮助文件（/help/xxx.txt）全部用英文，格式：
   Title
   Usage:
     curl https://sh.wss.moe/xxx | [sudo] bash
     curl https://sh.wss.moe/xxx | [sudo] bash -s -- [args]
   Features / Notes:
     - ...
   Requires: sudo (如果需要)
10. 支持参数时使用 ${1:-default} 写法，并在前几行 echo 当前使用的参数值（如果合适）
11. 所有换加速源（如 pnpm registry）、gnome 支持包（如 *-gnome-support）必须做成可选项，默认开启，参数如 --no-xxx 跳过
12. 帮助文件保持简洁，突出用法、特性、可选项
13. curl 后必须使用带 https:// 的 url (因为站点开启了强制 https)

现在请为 [具体软件/功能名称] 创作脚本 scripts/xxx.sh 和 help/xxx.txt，
基于以下安装步骤/需求：
[在这里粘贴原命令、多行安装步骤、或具体需求描述]
请严格遵守以上风格，不要添加多余内容。
