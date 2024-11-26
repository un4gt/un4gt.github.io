:giscus-on:

解决使用Rust与Sqlite3交互时出现 LNK1181 错误
============================================

在 windows 环境下，使用 `rusqlite`_ 在 rust 中进行交互时，可能会发生  **LNK1181** 错误,
这是因为环境变量或者当前目录缺乏 **sqlite3.lib** 文件导致的。

解决方式之——手动编译 **sqlite3.lib**
------------------------------------

1. 在 `SQLite Download Page`_ 中分别下载以下3个文件
   
   * sqlite-amalgamation-xxxx.zip
   * sqlite-dll-win-x64-xxxx.zip （如果是 x86, 请下载sqlite-dll-win-x86-xxxxx.zip）
   * sqlite-tools-win-x64-xxxxx.zip
2. 将以上三个压缩包解压至一个目录内，并打开 **Developer Command Prompt for VS xxxx**，并运行以下命令：
   
   .. tabs::

    .. group-tab:: windows x86

        .. code-block:: text

            lib /DEF:sqlite3.def /OUT:sqlite3.lib /MACHINE:x86

    .. group-tab:: windows x64

        .. code-block:: text

            lib /DEF:sqlite3.def /OUT:sqlite3.lib /MACHINE:x64

3. 最终创建一个名为 **SQLITE3_LIB_DIR** 的环境变量，并将其值设置为上一步生成 **sqlite3.lib** 所在的目录即可。


解决方式之——安装 `rusqlite`_ 时添加 features 为 **bundled**
-------------------------------------------------------------

只需在你的项目 **Cargo.toml** 文件加入该 features 即可

.. code-block:: toml

    [dependencies]
    rusqlite = { version = "0.32.0", features = ["bundled"] }


.. _rusqlite: https://crates.io/crates/rusqlite
.. _SQLite Download Page: https://www.sqlite.org/download.html