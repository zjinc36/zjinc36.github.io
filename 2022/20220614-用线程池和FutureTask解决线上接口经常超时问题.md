# 用线程池和FutureTask解决线上接口经常超时问题

----

之前红包权益领取查询的接口超时了，因为有用户订购的权益有点多。

# 解决方案

用线程池+ FutureTask将1个查询拆分成多个小查询
+	选择FutureTask是因为它具有仅执行1次run()方法的特性(即使有多次调用也只执行1次)，避免了重复查询的可能。
+	而且多任务异步执行也能提高接口响应速度。

# 为什么FutureTask仅执行一次

```java
/**
 * 执行结果(全局变量), 有2种情况:
 * 1. 顺利完成返回的结果
 * 2. 执行run()代码块过程中抛出的异常 
 */
private Object outcome; 

//正在执行run()的线程, 内存可被其他线程可见
private volatile Thread runner;

public void run() {
    
    /**
     * FutureTask的run()仅执行一次的原因：
     * 1. state != NEW表示任务正在被执行或已经完成, 直接return
     * 2. 若state==NEW, 则尝试CAS将当前线程 设置为执行run()的线程,如果失败,说明已经有其他线程 先行一步执行了run(),则当前线程return退出
     */
    if (state != NEW ||!UNSAFE.compareAndSwapObject(this, runnerOffset,null, Thread.currentThread()))
        return;
    try {
    
        //持有Callable的实例,后续会执行该实例的call()方法
        Callable<V> c = callable;
        if (c != null && state == NEW) {
    
            V result;
            boolean ran;
            try {
    
                result = c.call();
                ran = true;
            }catch (Throwable ex) {
    
                result = null;
                ran = false;
                //执行中抛的异常会放入outcome中保存
                setException(ex);
            }
            if (ran)
                //若无异常, 顺利完成的执行结果会放入outcome保存
                set(result);
        }
    }finally {
    
        // help GC 
        runner = null;
        int s = state;
        if (s >= INTERRUPTING)
            handlePossibleCancellationInterrupt(s);
    }
}
```

# 线程池+FutureTask执行多任务计算

```java
public class Test {
    //线程池最好作为全局变量, 若作为局部变量记得用完后shutdown()
    ThreadFactory namedThreadFactory = new ThreadFactoryBuilder(）.setNameFormat("thread-start-runner-%d").build();
    ExecutorService taskExe = new ThreadPoolExecutor(10, 20, 800L, TimeUnit.MILLISECONDS, new LinkedBlockingQueue<Runnable>(100), namedThreadFactory);

    int count = 0;

    @Test
    public void test(String[] args) {

        //任务列表，公众号：Java精选
        List<FutureTask<Integer>> taskList = new ArrayList<FutureTask<Integer>>();
        for (int i = 0; i < 100; i++) {
            //创建100个任务放入【任务列表】
            FutureTask<Integer> futureTask = new FutureTask<Integer>(new Callable<Integer>() {
                @Override
                public Integer call() throws Exception {
                    return 1;
                }
            });
            //执行的结果装回原来的FutureTask中,后续直接遍历集合taskList来获取结果即可
            taskList.add(futureTask);
            taskExe.submit(futureTask);
        }
        //获取结果
        try {
            for (FutureTask<Integer> futureTask : taskList) {
                count += futureTask.get();
            }
        } catch (InterruptedException e) {
            logger.error("线程执行被中断", e);
        } catch (ExecutionException e) {
            logger.error("线程执行出现异常", e);
        }
        //关闭线程池
        taskExe.shutdown();
        //打印: 100
        System.out.println(count);
    }
}
```

Callable接口能让我们拿到线程的执行结果，所以让它作为FutureTask构造函数`FutureTask(Callable<V> callable)`的入参。

FutureTask执行的结果会放入它的私有变量outcome中，其他线程直接调用futureTask.get()去读取该变量即可。

# 子线程出的异常抛不出的情况

submit(Runnable task)提交任务的方式 ，是存在“隐患”的：

FutureTask内部的run()代码块会把异常给吞进去，通过setException(Throwable t)把异常赋给了对象outcome，我们在调用FutureTask.get()获取结果的时候返回的就是这个对象

如果你的代码没有调用FutureTask.get()，它不会把异常吐出来，有可能子线程就莫名的停止了。

```java
public Future<?> submit(Runnable task) {
 if (task == null) throw new NullPointerException();
 //创建一个异步执行的任务FutureTask, 【隐患】也在它的run()代码块里
 RunnableFuture<Void> ftask = newTaskFor(task, null);
 execute(ftask);
 return ftask;
}
```

子线程创建之后会执行的是FutureTask内部的run()代码块，run()内部会有try-catch来截获抛出的异常，将其赋值给对象outcome

上面的例子没有这个问题，因为调用了FutureTask.get()，有异常会从这里拿出来。

