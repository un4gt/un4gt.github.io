Python PriorityQueue —— 优先队列
====================================


Python 默认实现
-------------------

Python 默认实现了一个优先级队列，但是它是一个最小堆。这意味着它总是返回最小的元素。

下面的是一个简单的例子：

.. code-block:: python

    from queue import PriorityQueue

    q3 = PriorityQueue()
    q3.put((20, 'code'))
    q3.put((100, 'eat'))
    q3.put((30, 'sleep'))

    print('\nq3\n')
    while not q3.empty():
        next_item = q3.get()
        print(next_item)

如果我们运行上面的代码，我们会得到：

.. code-block:: console
    
    q3

    (20, 'code')
    (30, 'sleep')
    (100, 'eat')


也就是说，不管我们插入的顺序如何，我们总是得到最小的元素。

假如，我们想按照最大的元素来获取，我们可以怎么实现呢？


方法一：通过负数来实现
-------------------------

该方法实现比较投机取巧，因为 Python 默认的优先队列是最小堆，所以我们可以通过将元素取负数来实现最大堆。

也就是说，在插入元素的时候，我们将元素的值取负数，这样最小的元素就变成了最大的元素。
而在取出元素的时候，我们再将元素的值取负数，这样就恢复了原来的值。

下面的是通过继承 ``PriorityQueue`` 来实现的：

.. code-block:: python
    :linenos:
    :emphasize-lines: 5, 6, 9, 10

    from queue import PriorityQueue

    class MaxPriorityQueueV1(PriorityQueue):
        def _put(self, item):
            item = (-item[0], item[1])
            super()._put(item)
            
        def _get(self):
            poped = super()._get()
            return (-poped[0], poped[1])

        
一个简单的示例代码：

.. code-block:: python

    q = MaxPriorityQueueV1()

    q.put((2, 'code'))
    q.put((1, 'eat'))
    q.put((3, 'sleep'))

    while not q.empty():
        next_item = q.get()
        print(next_item)

执行结果为：

.. code-block:: console

    (3, 'sleep')
    (2, 'code')
    (1, 'eat')



方法二：通过 ``heappush_max`` 和 ``_heappop_max`` 来实现
------------------------------------------------------------

如果查看 ``heapq`` 模块的源码会发现，它实际上是有 ``heappush`` 和 ``_heappop_max`` 这两个方法的，
而 ``heappush_max`` 并没有实现。

不过，先看一眼 ``heappush`` 的实现：

.. code-block:: python
    :linenos:

    def heappush(heap, item):
        """Push item onto heap, maintaining the heap invariant."""
        heap.append(item)
        _siftdown(heap, 0, len(heap)-1)


关键的函数是：``_siftdown`` ，同时 ``heapq`` 模块中实现了 ``_siftdown_max`` 函数。

可以仿照 ``heappush`` 实现 ``heappush_max`` ：

.. code-block:: python
    :linenos:
    :emphasize-lines: 4

    def heappush_max(heap, item):
    """Maxheap variant of heappush."""
        heap.append(item)
        _siftdown_max(heap, 0, len(heap)-1)


根据 ``PriorityQueue``，可以简单的实现 ``MaxPriorityQueueV2`` ：

.. code-block:: python
    :linenos:
    :emphasize-lines: 6, 21, 24

    from queue import Queue
    from heapq import _siftdown_max, _heappop_max

    def heappush_max(heap, item):
        heap.append(item)
        _siftdown_max(heap, 0, len(heap)-1)

    class MaxPriorityQueueV2(Queue):
        """Variant of Queue that retrieves open entries in priority order (higest first).

        Entries are typically tuples of the form:  (priority number, data).
        """

        def _init(self, maxsize):
            self.queue = []

        def _qsize(self):
            return len(self.queue)

        def _put(self, item):
            heappush_max(self.queue, item)

        def _get(self):
            return _heappop_max(self.queue)


一个简单的示例代码：

.. code-block:: python

    q2 = MaxPriorityQueueV2()

    q2.put((20, 'code'))
    q2.put((100, 'eat'))
    q2.put((30, 'sleep'))

    print('\nq2\n')
    while not q2.empty():
        next_item = q2.get()
        print(next_item)


执行结果为：

.. code-block:: console

    q2

    (100, 'eat')
    (30, 'sleep')
    (20, 'code')


总结
----------------

对于以上两个实现，暂时没去进行相关的 benchmark，所以不知道哪个更快，占用的内存更少。

下一篇，将对于这两个实现进行 benchmark。