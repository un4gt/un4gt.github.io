API Testing | API 接口测试
============================


1. 测试应该放在哪里
----------------------------

Rust  提供了以下三种选择：

.. list-table::

   * - 测试类型
     - 描述
     - 代码访问级别
   * - 嵌入式测试模块
     - 测试单个函数或模块的行为，通常在同一文件中。
     - 私有
   * - 集成测试
     - 测试多个模块或整个应用程序的交互，通常在 `tests` 目录中。
     - 公有
   * - 文档测试
     - 在文档注释中编写示例代码，并验证其正确性。
     - 公有


2. 沿用书中的测试
----------------------------

在 `tests/health_check.rs` 中，书中提供了一个 `spawn_app` 函数用于启动一个测试服务器，并返回其地址。

.. code-block:: rust
    :linenos:

    fn spawn_app() -> String {
        let listener = TcpListener::bind("127.0.0.1:0").expect("Can't spawn tcp listener");
        let port = listener.local_addr().unwrap().port();
        let server = zero2prod::run(listener).expect("Can't start zero2prod");

        let _ = tokio::spawn(server);

        format!("http://127.0.0.1:{}", port)
    }


随后，创建一个具体的测试案例

.. code-block:: rust
    :linenos:

    #[tokio::test]
    async fn health_check_works() {
        let addr = spawn_app();

        let client = reqwest::Client::new();

        let response = client
            .get(format!("{}/health_check", &addr))
            .send()
            .await
            .expect("Can't send request");

        assert!(response.status().is_success());
        assert_eq!(Some(0), response.content_length());
    }

这些测试的大概步骤是：

#. 使用 `spawn_app` 函数启动一个测试服务器。
#. 使用 `reqwest` 创建一个 HTTP 客户端。
#. 发送请求并验证响应。

但是弊端也很明显，需要每次执行一个测试，需要创建服务器实列和客户端实列，如果测试数量较多，可能会导致测试执行时间过长。

3. 改进测试
----------------------------

Flask 提供了用于测试应用程序的工具，可以配合 `pytest` 使用。下面的是一个具体的示例：

.. code-block:: python
    :linenos:

    import pytest
    from flask import Flask

    app = Flask(__name__)

    @app.route('/health_check')
    def health_check():
        return '', 200

    @pytest.fixture
    def client():
        with app.test_client() as client:
            yield client

    def test_health_check(client):
        response = client.get('/health_check')
        assert response.status_code == 200
        assert response.data == b''

不确定是否是版本原因还是其他，  原书作者并没有使用到 actix-web 框架本身提供的测试功能。
