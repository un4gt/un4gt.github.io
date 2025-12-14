#!/bin/bash

# Cloudflare Pages 构建脚本 - 替代原来的 GitHub Actions
set -euo pipefail  # 遇到错误立即退出

echo "🚀 开始构建 Sphinx 文档..."

# 安装 uv
echo "📦 安装 uv..."
curl -LsSf https://astral.sh/uv/install.sh | sh

# 将 uv 添加到 PATH（uv 默认安装到 $HOME/.local/bin）
export PATH="$HOME/.local/bin:$PATH"

# 验证 uv 安装
if ! command -v uv &> /dev/null; then
    echo "❌ uv 安装失败"
    exit 1
fi

echo "✅ uv 安装成功"

# 安装项目依赖
echo "📚 安装项目依赖..."
uv sync --frozen --no-dev

if [ $? -ne 0 ]; then
    echo "❌ 依赖安装失败"
    exit 1
fi

echo "✅ 依赖安装成功"

# 构建文档
echo "🔨 构建 HTML 文档..."
uv run --no-sync --no-dev sphinx-build -M html docs docs/_build

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
