#   Java中的Lambda表达式(匿名内部类)
description: Java中的Lambda表达式(匿名内部类)
date: 2018-04-09 21:01:09
categories:
- Java
tags:
- Java
---
#   演变过程

##  调用外部类
1.  外部类
```JAVA
Java中的Lambda表达式ckage com.zjinc36.lambda;

public class ListenSong implements Runnable {
	@Override
	public void run() {
		for (int i = 0; i < 20; i++) {
			System.out.println("一边听歌");
		}
	}
}
```

2.  调用类
```JAVA
package com.zjinc36.lambda;

public class LambdaDemo {

	public void run() {
		new Thread(new ListenSong()).start();
	}

}
```

3.	测试
```JAVA
package com.zjinc36.lambda;

import static org.junit.Assert.*;

import org.junit.Test;

public class LambdaDemoTest {

	@Test
	public void test() {
		LambdaDemo lambdaDemo = new LambdaDemo();
		lambdaDemo.run();
	}

}
```

##  内部类
由于上述的类只使用一次,因此可以将外部类放在内部类内,如下

```JAVA
package com.zjinc36.lambda;

public class LambdaDemo {
	public class ListenSong implements Runnable {
		@Override
		public void run() {
			for (int i = 0; i < 20; i++) {
				System.out.println("一边听歌");
			}
		}
	}

	public void run() {
		new Thread(new ListenSong()).start();
	}
}
```

##  局部内部类
我们还可以将外部类放在内部类的某一方法内,这里我们放到run方法内,如下
```JAVA
package com.zjinc36.lambda;

public class LambdaDemo {
	public void run() {
		class ListenSong implements Runnable {
			@Override
			public void run() {
				for (int i = 0; i < 20; i++) {
					System.out.println("一边听歌");
				}
			}
		}

		new Thread(new ListenSong()).start();
	}
}
```

##  匿名内部类
继续简化,由于我们只是用一次类,那么就没有必要创建类**(也就是说不需要类的名字)**,故可以如下

```JAVA
package com.zjinc36.lambda;

public class LambdaDemo {
	public void run() {
		new Thread(new Runnable() {
			@Override
			public void run() {
				for (int i = 0; i < 20; i++) {
					System.out.println("一边听歌");
				}
			}
		}).start();
	}
}
```

#   jdk8进一步简化内部类(Lambda)
##  简化
对于比较简单的逻辑,我们只需要关注传什么参数,实现什么东西就可以了,所以可以如下进一步简化(当然,这里要注意JDK的版本)
```JAVA
package com.zjinc36.lambda;

public class LambdaDemo {
	public void run() {
		new Thread(()-> {
			for (int i = 0; i < 20; i++) {
				System.out.println("一边听歌");
			}
		}).start();
	}
}
```

##  为什么能像上述那样进行简化
1.  其实,我们并不能在代码的任何地方任性的写Lambda表达式,事实上,能够使用Lambda的依据是必须有相应的函数接口,这一点也跟Java是强类型语言吻合
2.  也就是说,实际上Lambda的类型就是对应函数接口的类型
3.  更具体来说,只有上下文提供的信息足够编译器推导出参数表的类型才不需要显示指明

#   Lambda的使用
##  Lambda表达式中传入参数
从外部类到jdk8简化lambda已经推到完了,接下去,说明需要传入参数该怎么写(与上述推到代码无关,直接写Lambda表达式)
```JAVA
package com.zjinc36.lambda;

import java.util.Arrays;
import java.util.Collections;
import java.util.List;

public class LambdaDemo2 {
	public void run() {
		List<String> list = Arrays.asList("i", "love", "you");

		Collections.sort(list, (s1, s2) -> {
			if (s1 == null) {
				return -1;
			}
			if (s2 == null) {
				return 1;
			}
			return s1.length() - s2.length();
		});
	}
}
```

#   其他合法的写法
##  省略花括号
1.  代码
```JAVA
package com.zjinc36.lambda;

public class LambdaDemo3 {
	public void run() {
		// 代码内容只有一行,可以省略花括号,并将所有内容写到同一行
		Runnable run = () -> System.out.println("Hello world");

		new Thread(run).start();
	}
}
```
2.  测试
```JAVA
package com.zjinc36.lambda;

import static org.junit.Assert.*;

import org.junit.Test;

public class LambdaDemo3Test {

	@Test
	public void test() {
		LambdaDemo3 lambdaDemo2 = new LambdaDemo3();
		lambdaDemo2.run();
	}

}
```

注意,多行代码不能省略花括号
```JAVA
Runnable multiLine = () -> {// 3 代码块
    System.out.print("Hello");
    System.out.println(" Hoolee");
};
```

##  一个参数一行代码
```JAVA

ActionListener listener = event -> System.out.println("button clicked");

```

##  有返回值
```JAVA
BinaryOperator<Long> add = (Long x, Long y) -> x + y;// 4

BinaryOperator<Long> addImplicit = (x, y) -> x + y;// 5 类型推断
```

#   自定义函数接口
##  简单的使用
1.  自定义函数接口
自定义函数接口很容易，只需要编写一个只有一个抽象方法的接口即可
```JAVA
// 自定义函数接口
@FunctionalInterface
public interface ConsumerInterface<T>{
    void accept(T t);
}
```
其中,`@FunctionalInterface`是可选的，但加上该标注编译器会帮你检查接口是否符合函数接口规范(就像加入@Override标注会检查是否重载了函数一样)

2. 使用
```JAVA
ConsumerInterface<String> consumer = str -> System.out.println(str);
```

##	还可以这样使用
```JAVA
class MyStream<T>{
	private List<T> list;
    ...
	public void myForEach(ConsumerInterface<T> consumer){// 1
		for(T t : list){
			consumer.accept(t);
		}
	}
}

MyStream<String> stream = new MyStream<String>();
stream.myForEach(str -> System.out.println(str));// 使用自定义函数接口书写Lambda表达式
```

#   参考
[关于Java Lambda表达式看这一篇就够了](https://objcoding.com/2019/03/04/lambda/#%E4%BD%BF%E7%94%A8collect%E7%94%9F%E6%88%90collection)
[多线程\_推导lambda\_简化教程](https://www.bilibili.com/video/BV1ct411n7oG?p=203)

