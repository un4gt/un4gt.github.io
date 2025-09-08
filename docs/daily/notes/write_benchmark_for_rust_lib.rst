使用 ``criterion`` 库 进行 benchmark 
###########################################

刚开始学 python 时，很喜欢使用自带的 `timeit  <https://docs.python.org/3/library/timeit.html>`_ 库测量自己写的代码的执行时间。

虽然学了不少语言，但是没怎么关注过其他语言 benchmark 库。

今天在学习使用 `nom <https://crates.io/crates/nom>`_ 时，突然想到对比一下两种不同实现的 csv 解析器的代码实现，于是有了这篇文章。

csv 解析器实现
*******************

所用的 CSV 数据可以从 `sample-csv-files <https://github.com/datablist/sample-csv-files>`_ 下载。



实现 1
===================

.. code-block:: rust

    // csv.rs
    pub fn parse_csv(input: &str) -> IResult<&str, Vec<Vec<&str>>> {
        separated_list0(line_ending, parse_line)(input)
    }

    fn parse_line(line: &str) -> IResult<&str, Vec<&str>> {
        separated_list1(char(','), parse_filed)(line)
    }
    //  解析 "Alice Blic" 这样的双引号的字段
    fn parse_quoted_files(inut: &str) -> IResult<&str, &str> {
        delimited(char('"'), take_until("\""), char('"'))(inut)
    }

    // 解析正常字段
    fn parse_normal_filed(input: &str) -> IResult<&str, &str> {
        recognize(is_not(",\r\n"))(input)
    }

    fn parse_filed(input: &str) -> IResult<&str, &str> {
        alt((parse_quoted_files, parse_normal_filed))(input)
    }


实现 2
===================

.. code-block:: rust

    // csv2.rs
    pub fn parse_csv(input: &str) -> IResult<&str, Vec<Vec<&str>>> {
        // terminated => combinator
        // line_ending => parser
        // opt => combinator
        separated_list0(terminated(line_ending, opt(line_ending)), parse_line)(input)
    }

    // parse_line => parser
    fn parse_line(input: &str) -> IResult<&str, Vec<&str>> {
        // separated_list0 => a combinator
        // accepts 2 parser
        separated_list0(char(','), is_not(",\r\n"))(input)
    }


编写 benchmark
********************

引入 `criterion <https://bheisler.github.io/criterion.rs/book/criterion_rs.html>`_

.. code-block:: bash

    cargo add --dev criterion


在 **Cargo.toml** 中指定有关属性：

.. code-block:: toml

    [[bench]]
    name = "my_benchmark"
    harness = false


项目根目录下创建 **benches** 目录，并创建文件 **my_benchmark.rs**

.. code-block:: plaintext

    ├─benches
    │      my_benchmark.rs


编写 benchmark 函数

.. code-block:: rust

    fn benchmark_both_parsers(c: &mut Criterion) {
        let content = fs::read_to_string("customers-100000.csv").unwrap();

        let mut group = c.benchmark_group("CSV Parser Comparison");

        group.bench_function("parse_csv", |b| {
            b.iter(|| {
                let result = parse_csv(black_box(&content));
                black_box(result);
            })
        });

        group.bench_function("parse_csv2", |b| {
            b.iter(|| {
                let result = parse_csv2(black_box(&content));
                black_box(result);
            })
        });

        group.finish();
    }

    criterion_group!(benches, benchmark_both_parsers);
    criterion_main!(benches);


最后在命令行运行 ``cargo bench`` 即可。结果在命令行中也有输出，不过 criterion 默认生成的 HTML 报告信息量更大且美观。

打开 ``target/criterion/report/index.html`` ：

.. image:: https://tumuer.me/cargo_bench_criterion_html_resport.png
    :alt: cargo bench criterion html report