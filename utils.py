from pathlib import Path

import aiofiles
import httpx
from aiofiles.base import AiofilesContextManager
from aiofiles.os import makedirs, remove, link
from aiofiles.ospath import exists
from aiofiles.threadpool.text import AsyncTextIOWrapper
from bilibili_api import HEADERS

client = httpx.AsyncClient(headers=HEADERS)


async def download_content(url: str, path: Path) -> None:
    async with client.stream("GET", url) as resp, aopen(path, "wb") as f:
        async for chunk in resp.aiter_bytes(40960):
            if not chunk:
                return
            await f.write(chunk)


async def acopy(source: Path, target: Path) -> None:
    async with aiofiles.open(source, 'rb') as source_file:
        async with aiofiles.open(target, 'wb') as destination_file:
            while True:
                chunk = await source_file.read(8192)  # 读取8KB的数据块
                if not chunk:
                    break
                await destination_file.write(chunk)


async def ahlink(source: Path, target: Path) -> None:
    try:
        await link(source, target)
    except OSError as e:
        print(f"Error creating hard link: {e}")


async def aexists(path: Path) -> bool:
    return await exists(path)


async def amakedirs(path: Path, exist_ok=False) -> None:
    await makedirs(path, exist_ok=exist_ok)


def aopen(
        path: Path, mode: str = "r", **kwargs
) -> AiofilesContextManager[None, None, AsyncTextIOWrapper]:
    return aiofiles.open(path, mode, **kwargs)


async def aremove(path: Path) -> None:
    await remove(path)
