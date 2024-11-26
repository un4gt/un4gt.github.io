:giscus-on:

Python 中管道模式——通过重载运算符实现
=======================================

前几天，在网上突然看到了一篇文章，`Python 中管道模式的实际示例`_ , 将的是通过 Python 的 ``reduce`` 和 ``lambda`` 来实现管道模式。这里我也想分享一下我自己的实现方式。

.. _Python 中管道模式的实际示例: https://pybit.es/articles/a-practical-example-of-the-pipeline-pattern-in-python/

上面的文章中，作者通过 ``reduce`` 和 ``lambda`` 来实现管道模式。这里我通过重载运算符来实现，
但是，核心功能还是参考了上面的文章（具体的函数执行）。


引言
------
熟悉 Linux 的朋友应该对管道模式不陌生，它是一种将多个命令连接在一起的方式，将一个命令的输出作为另一个命令的输入。

也就是说，它可以将多个命令组合在一起，形成一个管道。这样，我们就可以将数据从一个函数传递到另一个函数，从而实现数据的处理。

Python 中的 ``pathlib`` 模块就是一个很好的例子，它通过重载运算符 ``/``，将多个路径以很直观的方式连接在一起。

.. code-block:: python

    from pathlib import Path

    p = Path('/usr') / 'bin' / 'python3'
    ...


具体实现
------------

Python  中的 ``|`` 符，对应的是魔术方法 ``__or__``。我们可以通过重载这个方法，来实现管道模式。


.. code-block:: python
    :linenos:
    :emphasize-lines: 1, 2, 3, 10, 11

    def compose(*functions: Callable) -> Any:
        """Composes functions into a single function"""
        return reduce(lambda f, g: lambda x: g(f(x)), functions, lambda x: x)
        
    class PipeLine:
    
        funcs = []
        
        def __or__(self, value: Any) -> Any:
            self.funcs.append(value)
            return self
        
        def __call__(self, *args: Any, **kwargs: Any) -> Any:
            return compose(*self.funcs)(*args, **kwargs)


函数 ``compose`` 是一个辅助函数（来自上面的文章，这里不做过度的解读），它将多个函数组合成一个函数，而 ``PipeLine`` 类则是管道模式的具体实现。

- 第七行， 创建一个名为 ``funcs`` 的类属性，用来存储所有的函数。
- 第八行， 重载 ``|`` 运算符，将函数添加到 ``funcs`` 中。第10行，返回 ``self``，这样就可以实现多个函数的连接。
- 第14行， 重载 ``__call__`` 方法，调用 ``compose`` 函数并执行。

下面是一个简单的示例代码：

.. code-block:: python

    def add_one(x: int) -> int:
        return x + 1

    def multiply_by_two(x: int) -> int:
        return x * 2

    def power_of_two(x: int) -> int:
        return x ** 2


    def add_zero(x: str) -> str:
        return x + "0"

    p = PipeLine()

    r = p | add_one | multiply_by_two | power_of_two | str | add_zero

    print(r(2))


上面的代码中，所有被调用的函数都是一个参数，如果某个函数是多个参数，我们可以通过 ``functools.partial`` 来进行调用。

先定义一个多参数的函数：

.. code-block:: python

    def calc_x_y(x: str, y: int) -> int:
        return int(x) + y

    ...

    r = p | add_one | multiply_by_two | power_of_two | str | add_zero | partial(calc_x_y, y=10)


改进
-------

前面的实现中，我们必须手动创建一个 ``PipeLine`` 实例，这样会显得有些繁琐。那有没有什么改进的地方呢？

假如我们希望可以通过以下的方式来实现调用：

.. code-block:: python

    r = PipeLine | add_one | multiply_by_two | power_of_two | str | add_zero | partial(calc_x_y, y=10)


但是这样会有个问题，因为当前的 ``PipeLine`` 代表的是一个类型，而不是一个类示例，我们执行的话，会得到以下输出：

.. code-block:: console

    Traceback (most recent call last):
    File "E:\python_override_operators\demo.py", line 48, in <module>
        r = PipeLine | add_one | multiply_by_two | power_of_two | str | add_zero | partial(calc_x_y, y=10)
            ~~~~~~~~~^~~~~~~~~
    TypeError: unsupported operand type(s) for |: 'type' and 'function'


那有没有方法可以让上面的代码正常运行呢？ 这时候就可以借助 ``metaclass`` 来实现。

首先创建一个名为 ``MetaPipeLine`` 的元类，它继承于 ``type``，并重载 ``__or__`` 方法：

.. code-block:: python
    :linenos:
    :emphasize-lines: 1, 3, 4, 6

    class PipeLineMeta(type):
    
        def __or__(cls, p: Callable) ->'PipeLine':
            return cls() | p

    class PipeLine(metaclass=PipeLineMeta):
    
        funcs = []
        
        
        def __or__(self, value: Any) -> Any:
            self.funcs.append(value)
            return self
        
        def __call__(self, *args: Any, **kwargs: Any) -> Any:
            return compose(*self.funcs)(*args, **kwargs)




通过将 ``PipeLine`` 类的元类设置为 ``PipeLineMeta``，就可以通过 ``PipeLine | func1 | func2 | ...`` 的方式来调用。
