在 C 语言中生成随机数
##############################


需要的头文件
*****************

只需引入 ``stdlib.h`` 和 ``time.h``

.. code-block:: c

    #include <stdlib.h>
    #include <time.h>



生成 ``[0, n-1]`` 范围的随机数
***********************************

不同于其他语言，比如 Python, 生成随机数，只需提供一个范围

.. code-block:: python

    import random

    random.randint(12, 99)
    random.randint(0, 23)



需要在 c 中生成 ``0~99`` 以内的数字，按照公式 ``rand() % n`` ，也就是：

.. code-block:: c

    rand() % 100;

    // 生成 0 ~ 23
    rand() % 24



生成 ``[a, b]`` 范围的随机数
*************************************

跟 Javascript 的随机数生成有一点相似，照样只需一个公式 ``rand() % (b - a + 1) + 1``

.. code-block:: c

    // 示例：生成 10-20 的随机数
    int num = rand() % 11 + 10;  // 11 = 20-10+1


猜数字游戏
************************

模仿 rust 教程中的猜数字游戏，用 C 写一遍：

.. code-block:: c

    #include <stdio.h>
    #include <stdlib.h>
    #include <time.h>

    int main()
    {
        srand(time(NULL));
        int range_1_100 = rand() % 100 + 1;
        int user_guess;
        for (;;)
        {
            printf("请输入你的数字：");
            scanf("%d", &user_guess);

            if (range_1_100 == user_guess)
            {
                printf("猜对了!\n");
                break;
            }
            else if (range_1_100 < user_guess)
            {
                printf("猜大了\n");
            }
            else
            {
                printf("猜小了\n");
            }
        }

        return 0;
    }


算是用 C 编写了一些代码，并使用 cMake 等工具进行编译并运行，总体感觉可还行。

语法可以接受，唯一想吐糟的地方是，如果有个包管理或者项目管理工具更好，对编写 cMake 感到厌烦了。

（也可能是我还未接触到指针等难的部分）