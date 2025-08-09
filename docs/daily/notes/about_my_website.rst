:giscus-on:

我是如何搭建该个人网站的
===============================

最初的个人网站是由 `Rspress`_ 进行构建并部署在 Github Pages 上的。不过写作时，发现不太适应它的导航以及导航栏模块。因此准备使用其他的站点生成工具。

好巧不巧，因在给某个项目编写文档是，了解到 `Sphinx`_，于是决定尝试使用它来重构我的个人网站。

对于个人网站，我最看重以下两个点：

* 更偏向如何写作，UI 设计不是重点
* 与 Github Actions 集成
* 易于配置导航

`Astro`_ 它有很多精美的主题，但是之前尝试移植，发现其成本不低，同时我不是很擅长于前端开发，所以最终还是选择 Sphinx。

.. _Rspress: https://rspress.rs
.. _Sphinx: https://www.sphinx-doc.org/
.. _Astro: https://astro.build/

入门 Sphinx
--------------------

我熟悉并掌握 Sphinx 的基本用法，能够快速上手并，参考的资料如下：

- `Sphinx`_ 官方文档
- `reStructuredText`_ 文档
- `Sphinx + Read the Docs 从懵逼到入门`_ 


.. _reStructuredText: https://sublime-and-sphinx-guide.readthedocs.io/en/latest/index.html
.. _Sphinx + Read the Docs 从懵逼到入门: https://zhuanlan.zhihu.com/p/264647009

经过相关设置后，我实现了最基础的功能，不过当前步骤文档只能在本地生成并查看。如果，想要部署到 Github Pages 上，还需要额外配置 Github Actions。

Github Actions 集成
-----------------------

在文档 `Appendix: Deploying a Sphinx project online <https://www.sphinx-doc.org/en/master/tutorial/deploying.html>`_ 中，介绍了如何将 Sphinx 项目部署到线上环境，包括使用 Github Actions 进行自动化部署的配置示例。


在此基础上，我们需要进行一些改进。首先，构建 sphinx 文档需要 python 环境，而管理 python 环境中的依赖，当前选择的是 `PDM`_ 。

.. _PDM: https://pdm-project.org/en/latest/

使用 Pdm 官方提供的 actions 来配置 python 和 本身：

.. code-block:: yaml

   build:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    - name: Setup PDM
      uses: pdm-project/setup-pdm@v4
    - name: Install dependencies
      run: pdm install -G doc

不需要手动配置 Python 环境，PDM 会自动处理。

同时，我们需要在 pyproject.toml 中配置 Sphinx 相关的构建命令，以便在 CI/CD 流水线中调用。

.. code-block:: toml

    [tool.pdm.scripts]
    autobuild = {shell = 'sphinx-autobuild docs/ docs/_build/html --watch-step 3000'}
    docs = {shell = "cd docs && make html -e"}  # build sphinx docs

将其添加到 github actions 的工作流中：

.. code-block:: yaml

   - name: Make html
      run: pdm run docs
    - name: Upload artifact
      uses: actions/upload-pages-artifact@v3
      id: deployment
      with:
        path: docs/_build/html


最终的工作流配置如下所示：

.. code-block:: yaml

    name: "Sphinx: Render docs"

    on: push

    permissions:
    contents: read
    pages: write
    id-token: write

    jobs:
        build:
            runs-on: ubuntu-latest
            steps:
            - uses: actions/checkout@v4
            - name: Setup PDM
            uses: pdm-project/setup-pdm@v4
            - name: Install dependencies
            run: pdm install -G doc
            - name: Make html
            run: pdm run docs
            - name: Upload artifact
            uses: actions/upload-pages-artifact@v3
            id: deployment
            with:
                path: docs/_build/html


    deploy:
        environment:
            name: github-pages
            url: ${{ steps.deployment.outputs.page_url }}
        needs: build
        runs-on: ubuntu-latest
        name: Deploy
        steps:
        - name: Deploy to GitHub Pages
            id: deployment
            uses: actions/deploy-pages@v4


编写 Sphinx 扩展
------------------

Sphinx 所使用的 reStructuredText 标准中，无法实现与 HTML Del 元素相同的功能。这个也算是我第一次编写的 Sphinx 扩展了。

该插件已经发布到 `Pypi`_ 上了，并且源码托管在 GitHub 上，请查看： `sphinxcontrib-del-marker`_

.. _sphinxcontrib-del-marker: https://github.com/sphinx-contrib/sphinxcontrib-del-marker
.. _Pypi: https://pypi.org/project/sphinxcontrib-del-marker/


该插件使用自定义指令功能，实现了类似 HTML 中 Del 元素的功能。使用方法如下：

在 conf.py 中注册该插件：

.. code-block:: python

    extensions = [
        "sphinxcontrib.del_marker",
        ...
    ]


在 rst 文件中使用：

.. code-block:: rst

    .. del:: lorem lorem lorem


该插件的实现方式，较为简单，通过自定义指令将需要删除的内容包裹起来即可（因 html 中自带 del 标签）。

.. code-block:: python

    class DelNode(nodes.General, nodes.Element):
        pass


    def visit_del_node(self, node):
        self.body.append(self.starttag(node, 'del'))


    def depart_del_node(self, node):
        self.body.append('</del>')


    class DelMarkerDirective(Directive):
        # this enables content in the directive
        has_content = True

        def run(self):
            paragraph_node = nodes.paragraph()

            self.state.nested_parse(self.content, self.content_offset, paragraph_node)
            del_node_instance = DelNode()
            del_node_instance += paragraph_node.children
            return [del_node_instance]


其大概步骤为：

# 1. 创建自定义节点
# 2. 实现访问器
# 3. 创建指令类

最后，将指令类注册到 Sphinx 中：

.. code-block:: python

    def setup(app: Sphinx) -> ExtensionMetadata:
        app.add_node(DelNode, html=(visit_del_node, depart_del_node))
        app.add_directive("del", DelMarkerDirective)

        return {
            'version': __version__,
            'parallel_read_safe': True,
            'parallel_write_safe': True,
        }

最终呈现的效果如下：

.. image:: https://tumuer.me/website_preview.png
    :alt: Website Preview



使用 Sphinx 扩展实现评论系统
-----------------------------------

评论系统是通过插件 `sphinxcontrib-giscus`_ 来实现。

.. _sphinxcontrib-giscus: https://github.com/un4gt/sphinxcontrib-giscus


准确的来说，该扩展只负责基于相关配置，将 `giscus`_ 评论系统的 javascript 代码嵌入到文档中。

.. _giscus: https://giscus.app/

首先，通过 PDM 或者 Uv 之类的工具进行安装：

.. code-block:: shell

    pdm add sphinxcontrib-giscus



然后在 `giscus`_ 中启用相关的设置，并将相关的配置保存在 `conf.py` 中：

.. code-block:: python

    data_repo = "****"
    data_repo_id = "****"
    data_category = "****"
    data_category_id = "****"


上面的只是必选项，其余的配置项可使用默认配置。同时，使用指令 `:giscus-on:` 开启评论功能。

只需在页面上方插入该指令即可：

.. image:: https://tumuer.me/giscus_on_directive.png
    :alt: Giscus On Directive



最终呈现的效果如下：

.. image:: https://tumuer.me/20250809173527510.png
    :alt: Giscus Comments


集成 Google Analytics 或 百度统计
------------------------------------

为了这个功能，编写了插件 `sphinxcontrib-analytics-hub`_ 。

.. _sphinxcontrib-analytics-hub: https://github.com/un4gt/sphinxcontrib-analytics-hub


启用之前，需要去 `Google Analytics`_ 或 `百度统计`_ 中创建相关的统计项目，并获取相应的配置。

.. _Google Analytics: https://analytics.google.com/
.. _百度统计: https://tongji.baidu.com/

其次，在 `conf.py` 中按需启用相关配置：

.. code-block:: python

    analytics_with = "baidu"
    analytics_id = "******"

上面的示例是开启百度统计，如果想切换成 Google Analytics，只需要将 `analytics_with` 改为 `google`, 并更新 `analytics_id` 即可。


热更新
-----------------

sphinx 本身不提供类似其他工具的热更新或者内置服务器功能，所以文档进行变动时，需要手动进行构建，并使用一些 http 服务进行预览。

比如，下面是我基于 PDM 脚本，写的两个命令：

.. code-block:: toml

    docs = {shell = "cd docs && make html -e"}  # build sphinx docs
    docs_p = {shell = 'python -m http.server -d docs/_build/html'}

`docs` 命令负责构建，`docs_p` 命令负责预览。

直到我在 github 上搜到一个项目 `sphinx-autobuild`_, 让这个过程变得更加简单了。

.. _sphinx-autobuild: https://github.com/sphinx-doc/sphinx-autobuild

只需将上面的命令换成：

.. code-block:: toml

    ...
    autobuild = {shell = 'sphinx-autobuild docs/ docs/_build/html --watch-step 3000'}

* `docs/` 是源文件目录
* `docs/_build/html` 是构建输出目录
* `--watch-step` 是文件变动检测间隔，单位是毫秒

.. note::

    `--watch-step` 这个功能还在 PR 阶段，尚未合并到主干中。如果你想使用该功能，请用以下命令进行安装：

    .. code-block:: shell

        pip install git+https://github.com/un4gt/sphinx-autobuild.git@main


存放静态资源
-----------------

担心存放过多的图片或者视频等静态资源，导致 github 账号被封禁，所以我将这些资源放到 `Cloudflare R2` 中。在写作时可以使用 `PicGo`_ 
等工具，上传图片并获取图片链接后嵌入到文档即可。

以下是我参考的一些文章：

* `PicGo`_ 使用教程
* `Cloudflare R2对象存储搭建高速免费图床完全指南`_
* `picgo-plugin-cloudflare-r2`_
* `R2 结合 PicGo 搭建图床 <https://7walks.xyz/posts/create-a-website-using-hugo-n-cloudflare-pages/>`_

.. _PicGo: https://picgo.github.io/PicGo-Doc/
.. _Cloudflare R2对象存储搭建高速免费图床完全指南: https://zhuanlan.zhihu.com/p/24080167302
.. _picgo-plugin-cloudflare-r2: https://github.com/JYbill/picgo-plugin-cloudflare-r2


总结
--------

从最基础简陋的个人网站到现在，过程有些小挫折，但是最后实现下来，还是有点小成就感的。

不过，让我重新选择，我可能会选择 `Mkdocs <https://www.mkdocs.org/>`_ 来搭建，因为它基于 markdown 格式，同时插件生态更丰富。

