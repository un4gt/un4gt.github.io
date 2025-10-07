使用 `RsProxy <https://rsproxy.cn/>`_ 在 Windows 上设置镜像
##############################################################

每次更新 rust toolchains 时，不管有没有开加速器，相关的下载很慢。幸好找到了网站 `RsProxy <https://rsproxy.cn/>`_ 
提供了一个免费且稳定的国内镜像。

网站只提供了 linux 或 macos 的设置方法，于是稍微查找相关文档，掌握了如何在 windows 上实现类似 linux 的
`.bashrc` 这种效果。

我使用的微软商店中自带的 ``Terminal Preview`` 。


通过 cmd 配置
========================

首先打开 ``Terminal Preview`` 的配置文件：

.. code-block:: json

    {
        "commandline": "%SystemRoot%\\System32\\cmd.exe",
        "guid": "{0caa0dad-35be-5f56-a8ff-afceeeaa6101}",
        "hidden": false,
        "name": "\u547d\u4ee4\u63d0\u793a\u7b26"
    },


可以看到 commandline 对应的可执行文件为 ``%SystemRoot%\\System32\\cmd.exe``, 我们可以通过  ``/k``
参数指定一个 ``.bat`` 文件, 相当于每次打开 commandline 时，执行文件中的内容。

.. code-block:: bat

    set RUSTUP_DIST_SERVER="https://rsproxy.cn"
    set RUSTUP_UPDATE_ROOT="https://rsproxy.cn/rustup"


将以上的内容写入到任意文件后，修改 ``Terminal Preview`` 的配置：

.. code-block:: json

    {
        "commandline": "%SystemRoot%\\System32\\cmd.exe /k C:\\Users\\MT308\\init_cmd.bat",
        "guid": "{0caa0dad-35be-5f56-a8ff-afceeeaa6101}",
        "hidden": false,
        "name": "\u547d\u4ee4\u63d0\u793a\u7b26"
    },


这样就配置成功了。


通过 powershell 配置
===============================

powershell 上的配置比 commandline 更为简单一些。

在 powershell 中，执行以下命令：

.. code-block:: powershell

    notepad $PROFILE


这里的 ``$PROFILE`` 相当于 linux 中的 ``.bashrc`` 。

成功打开后，合适的位置添加以下代码：

.. code-block:: powershell

    $env:RUSTUP_DIST_SERVER="https://rsproxy.cn"
    $env:RUSTUP_UPDATE_ROOT="https://rsproxy.cn/rustup"

    