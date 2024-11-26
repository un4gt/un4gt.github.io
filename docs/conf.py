project = "un4gt的编程随记"
copyright = "2024, un4gt"
author = "un4gt"

# -- General configuration ---------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#general-configuration

extensions = [
    "sphinxcontrib_del_marker",
    "sphinx_tabs.tabs",
    "sphinxcontrib_analytics_hub",
    "sphinx_design",
    "sphinxcontrib_giscus",
]

templates_path = ["_templates"]
exclude_patterns = ["_build", "Thumbs.db", ".DS_Store"]

language = "zh_CN"

# -- Options for HTML output -------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#options-for-html-output

html_theme = "sphinxawesome_theme"
html_permalinks_icon = "<span>#</span>"

html_static_path = ["_static"]
html_title = "un4gt的编程随记"
html_short_title = "un4gt的编程随记"

html_show_sourcelink = False

analytics_with = "baidu"
analytics_id = "37c9f06a6b652cc479be7a02e861ad8f"

html_favicon = "avatar.ico"

pygments_style = "sphinx"

# analytics_enabled = False

data_repo = "un4gt/un4gt.github.io"
data_repo_id = "R_kgDOLqJB9g"
data_category = "Announcements"
data_category_id = "DIC_kwDOLqJB9s4CjTar"