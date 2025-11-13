#!/bin/bash

# Cloudflare Pages 构建脚本 - 替代原来的 GitHub Actions
set -e  # 遇到错误立即退出

echo "🚀 开始构建 Sphinx 文档..."

# 安装 PDM
echo "📦 安装 PDM..."
curl -sSL https://pdm.fming.dev/install-pdm.py | python3 -

# 将 PDM 添加到 PATH（根据 PDM 的安装位置可能需要调整）
export PATH="$HOME/.local/bin:$PATH"

# 验证 PDM 安装
if ! command -v pdm &> /dev/null; then
    echo "❌ PDM 安装失败"
    exit 1
fi

echo "✅ PDM 安装成功"

# 安装项目依赖
echo "📚 安装项目依赖..."
pdm install -G doc

if [ $? -ne 0 ]; then
    echo "❌ 依赖安装失败"
    exit 1
fi

echo "✅ 依赖安装成功"

# 构建文档
echo "🔨 构建 HTML 文档..."
pdm run docs

if [ $? -ne 0 ]; then
    echo "❌ 文档构建失败"
    exit 1
fi

echo "✅ 文档构建成功"

# 检查构建输出
if [ ! -d "docs/_build/html" ]; then
    echo "❌ 构建输出目录不存在: docs/_build/html"
    exit 1
fi

echo "📁 构建输出位于: docs/_build/html"
echo "✅ 构建完成！"