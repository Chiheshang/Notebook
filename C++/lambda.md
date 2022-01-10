

## Lambda

#### 语法：

##### [capture\](parameters) mutable ->return-type{statement}

1. [capture]：捕捉列表。捕捉列表总是出现在Lambda函数的开始处。实际上，[]是Lambda引出符。编译器根据该引出符判断接下来的代码是否是Lambda函数。捕捉列表能够捕捉上下文中的变量以供Lambda函数使用;

2. (parameters)：参数列表。与普通函数的参数列表一致。如果不需要参数传递，则可以连同括号“()”一起省略;

3. mutable：mutable修饰符。默认情况下，Lambda函数总是一个const函数，mutable可以取消其常量性。在使用该修饰符时，参数列表不可省略（即使参数为空）;

4. ->return-type：返回类型。用追踪返回类型形式声明函数的返回类型。我们可以在不需要返回值的时候也可以连同符号”->”一起省略。此外，在返回类型明确的情况下，也可以省略该部分，让编译器对返回类型进行推导;

5. {statement}：函数体。内容与普通函数一样，不过除了可以使用参数之外，还可以使用所有捕获的变量。

**捕捉列表有以下几种形式：**

1. [var]表示值传递方式捕捉变量var；
2. [=]表示值传递方式捕捉所有父作用域的变量（包括this）；
3. [&var]表示引用传递捕捉变量var；
4. [&]表示引用传递方式捕捉所有父作用域的变量（包括this）；
5. [this]表示值传递方式捕捉当前的this指针。
