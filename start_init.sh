branch=$BILI_SYNC_VERSION
git clean -dffx
git fetch --depth 1 origin $BILI_SYNC_VERSION
git reset --hard origin/$BILI_SYNC_VERSION
git submodule update --init --recursive
# 安装依赖
poetry install --only main --no-root
# 修复权限
#chown -R nt:nt /$WORKDIR