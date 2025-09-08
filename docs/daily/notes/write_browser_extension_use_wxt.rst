使用 `WXT <https://wxt.dev/>`_ 来构建一个浏览器扩展
###########################################################

如今，编写浏览器的方式可以分为以下几种：

* 使用 `扩展 - Firefox <https://developer.mozilla.org/en-US/docs/Mozilla/Add-ons/WebExtensions/Your_first_WebExtension>`_ 或者 `扩展 - Chrome <https://developer.chrome.com/docs/extensions/get-started?hl=zh-cn>`_ 专有的方式去编写
* 借助 `Tampermonkey <https://www.tampermonkey.net/>`_ 等工具

方式一，需要对不同的浏览器进行适配；方法二，需要在客户浏览器上安装 Tampermonkey 扩展。

之前给 Chrome 浏览器编写的一个插件： `un4gt/markdown-tools: <https://github.com/un4gt/markdown-tools>`_ ，在某次看 `ZutJoe/KoalaHackerNews: Koala hacker news <https://github.com/ZutJoe/KoalaHackerNews>`_ 时，
发现有款名为 WXT 的一个项目，可以实现编写一次代码，同时适配 chromium/firefox 系的浏览器。

这款新的框架，还有一个很吸引人的功能，扩展页面可以直接使用 React/Vue/solid 等框架去开发，同时提供了一个热更新的功能。

于是花了些时间完成了迁移，在 chrome/edge/firefox 上都可以正常使用。

不过还未上架到扩展商店，页面显示还在审核。

附上链接：`un4gt/copy-url-as: Browser extension . Copy page link or image source as md or rst format <https://github.com/un4gt/copy-url-as>`_

迁移过程
*****************

老版本的扩展的主要功能如下：

* 在网页或者网页图片右键菜单上注册一些列菜单项
* 根据菜单项触发不同的函数
* 最终通过 ``chrome.scripting.executeScript`` 访问 ``navigator.clipboard`` 并写入 markdown 格式的网页链接文本

下面按步骤看一下每一项功能的原先实现和新的实现


注册菜单项
===============

Before:

.. code-block:: javascript

    function createMdToolsContextMenu() {
        // 创建父右键菜单
        let parent = chrome.contextMenus.create(MdToolsParentContextMenu);

        chrome.contextMenus.create({
            ...CopyPageLinkAsMdUrlFormat,
            parentId: parent
        });
        chrome.contextMenus.create({
            ...CopyImageLinkAsMdUrlFormat,
            parentId: parent
        });
    }


After:

.. code-block:: typescript

    /**
    * create parent contextMenu and return id
    * @returns {string | number} The pareny contextmenu id
    */
    function createCopyUrlAsContextMenu() {
        let parent = browser.contextMenus.create(CopyUrlAsParentContextMenu);

        childContextMenus.forEach((childContextMenu) => {
            browser.contextMenus.create({
                parentId: parent,
                ...childContextMenu
            })
        })

        return parent;
    }

如果对比很容易发现，主要的变动为 ``chrome`` -> ``browseer``, wxt 做了一个类似与 polyfill 的事情，在 dev 或者 build 时，
根据目标浏览器生成不同的代码。

监听菜单项按下事件
=======================

Before:

.. code-block:: javascript

    chrome.contextMenus.onClicked.addListener(genericOnClick);

    ...

    function genericOnClick(info, tab) {
        if (!tab || !tab.id) return;
        console.log(info);
        switch (info.menuItemId) {
            case CopyPageLinkAsMdUrlFormat.id:
                ...
                break;
            case CopyImageLinkAsMdUrlFormat.id:
                ...
                break;
        }
    }


After:

.. code-block:: typescript

    browser.contextMenus.onClicked.addListener((info, tab) => {
        if (info.parentMenuItemId !== parent || !tab || !tab.id) return;

        switch (info.menuItemId) {
            case CopyPageLinkAsMdFormat.id:
                return copyPageLinkAs(tab, 'MD');
            case CopyPageLinkAsRstFormat.id:
                return copyPageLinkAs(tab, 'RST');
            case CopyImageLinkAsMdFormat.id:
                return copyImageLinkAs(info, tab.id, 'MD');
            case CopyImageLinkAsRstFormat.id:
                return copyImageLinkAs(info, tab.id, 'RST');
        }
    })

跟上一个功能一样，只有 API 的变动，其他核心逻辑还是一样的。


执行脚本，并访问 ``Clipboard API``
=======================================

Before:

.. code-block:: javascript

    chrome.scripting.executeScript({
                target: {tabId: tab.id},
                func: copyPageLinkAsMdUrlFormat,
            }).then(r => {
                console.debug(r)
            })

After:

.. code-block:: typescript

    function copyPageLinkAs(tab: Browser.tabs.Tab, format: 'MD' | 'RST') {
        const pageLink = format === 'MD' ? `[${tab.title}](${tab.url})` : '`' + `${tab.title} <${tab.url}>` + '`_';
        browser.scripting.executeScript({
            target: { tabId: tab.id || 0 },
            func: (pageLinkInner) => {
                navigator.clipboard.writeText(pageLinkInner);
            },
            args: [pageLink]
        })
    }

之所以使用 ``browser.scripting.executeScript`` 去实现向系统剪切板写入，因为在 backgroud.js 环境中， ``navigator.clipboard`` 结果是 ``undefined``, 
该 API 只能在 ``scripting.executeScript`` 时能够正常使用。


扩展的 icon 处理
********************

chrome/edge 和 firefox 要求扩展图表提供多个不同的尺寸，确定号一个 icon 之后，使用网页工具生成了不同尺寸的 icon, 
不过总有那么一个尺寸，工具不支持或者需要注册并付费再能下载。幸好，WXT 官方提供了一个工具 `@wxt-dev/auto-icons <https://www.npmjs.com/package/@wxt-dev/auto-icons>`_ ，
只需提供一个正常尺寸（如 128x128）, 该工具自动生成目标浏览器所需要的所有尺寸的图表。

安装并使用很简单，首先使用 pnpm 进行安装

.. code-block:: bash

    pnpm add @wxt-dev/auto-icons


然后再 ``wxt.config.ts`` 中启用：

.. code-block:: typescript
    :emphasize-lines: 2

    export default defineConfig({
        modules: ['@wxt-dev/module-solid', '@wxt-dev/auto-icons'],
        manifest: {
            permissions: [
            'storage', 'scripting', 'activeTab', 'contextMenus', 'clipboardWrite'],
        }
    });


最终效果
************************

可以再任意在线网页中点击右键菜单进行唤醒：

.. image:: https://tumuer.me/copy-as-url-preview
    :alt: copy-as-url 效果演示


同样，在图片上右键菜单也是同样的效果。

