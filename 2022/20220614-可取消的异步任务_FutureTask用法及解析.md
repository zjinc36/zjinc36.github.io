# 可取消的异步任务_FutureTask用法及解析

----

# FutureTask的用法

>	在Java中，一般是通过继承Thread类或者实现Runnable接口来创建多线程， Runnable接口不能返回结果，如果要获取子线程的执行结果，一般都是在子线程执行结束之后，通过Handler将结果返回到调用线程，jdk1.5之后，Java提供了Callable接口来封装子任务，Callable接口可以获取返回结果。

与FutureTask相关的类或接口，有Runnable，Callable，Future，直接从Callable开始。

## Callable接口

下面可以看一下Callable接口的定义：

```java
public interface Callable<V> {
    /**
     * Computes a result, or throws an exception if unable to do so.
     *
     * @return computed result
     * @throws Exception if unable to compute a result
     */
    V call() throws Exception;
}
```

Callable接口很简单，是一个泛型接口，就是定义了一个call()方法，与Runnable的run()方法相比，这个有返回值，泛型V就是要返回的结果类型，可以返回子任务的执行结果。

## Future接口

Future接口表示异步计算的结果，通过Future接口提供的方法，可以很方便的查询异步计算任务是否执行完成，获取异步计算的结果，取消未执行的异步任务，或者中断异步任务的执行，接口定义如下：

```java
public interface Future<V> {

    boolean cancel(boolean mayInterruptIfRunning);

    boolean isCancelled();

    boolean isDone();

    V get() throws InterruptedException, ExecutionException;

    V get(long timeout, TimeUnit unit)
            throws InterruptedException, ExecutionException, TimeoutException;
}
```

+	cancel(boolean mayInterruptIfRunning)：取消子任务的执行，如果这个子任务已经执行结束，或者已经被取消，或者不能被取消，这个方法就会执行失败并返回false；如果子任务还没有开始执行，那么子任务会被取消，不会再被执行；如果子任务已经开始执行了，但是还没有执行结束，根据mayInterruptIfRunning的值，如果mayInterruptIfRunning = true，那么会中断执行任务的线程，然后返回true，如果参数为false，会返回true，不会中断执行任务的线程。这个方法在FutureTask的实现中有很多值得关注的地方，后面再细说。
+	需要注意，这个方法执行结束，返回结果之后，再调用isDone()会返回true。
+	isCancelled()，判断任务是否被取消，如果任务执行结束（正常执行结束和发生异常结束，都算执行结束）前被取消，也就是调用了cancel()方法，并且cancel()返回true，则该方法返回true，否则返回false.
+	isDone():判断任务是否执行结束，正常执行结束，或者发生异常结束，或者被取消，都属于结束，该方法都会返回true.
+	V get():获取结果，如果这个计算任务还没有执行结束，该调用线程会进入阻塞状态。如果计算任务已经被取消，调用get()会抛出CancellationException，如果计算过程中抛出异常，该方法会抛出ExecutionException，如果当前线程在阻塞等待的时候被中断了，该方法会抛出InterruptedException。
+	V get(long timeout, TimeUnit unit)：带超时限制的get()，等待超时之后，该方法会抛出TimeoutException。

## FutureTask

FutureTask可以像Runnable一下，封装异步任务，然后提交给Thread或线程池执行，然后获取任务执行结果。原因在于FutureTask实现了RunnableFuture接口，RunnableFuture是什么呢，其实就是Runnable和Callable的结合，它继承自Runnable和Callable。继承关系如下：

```java
public class FutureTask<V> implements RunnableFuture<V> {

public interface RunnableFuture<V> extends Runnable, Future<V> {
```

## FutureTask使用

### FutureTask + Thread

上面介绍过，FutureTask有Runnable接口和Callable接口的特征，可以被Thread执行。

```java
//step1:封装一个计算任务，实现Callable接口   
class Task implements Callable<Boolean> {

    @Override
    public Boolean call() throws Exception {
        try {
            for (int i = 0; i < 10; i++) {
                Log.d(TAG, "task......." + Thread.currentThread().getName() + "...i = " + i);
                //模拟耗时操作
                Thread.sleep(100);
            }
        } catch (InterruptedException e) {
            Log.e(TAG, " is interrupted when calculating, will stop...");
            return false; // 注意这里如果不return的话，线程还会继续执行，所以任务超时后在这里处理结果然后返回
        }
        return true;
    }
}

//step2:创建计算任务，作为参数，传入FutureTask
Task task = new Task();
FutureTask futureTask = new FutureTask(task);
//step3:将FutureTask提交给Thread执行
Thread thread1 = new Thread(futureTask);
thread1.setName("task thread 1");
thread1.start();

//step4:获取执行结果，由于get()方法可能会阻塞当前调用线程，如果子任务执行时间不确定，最好在子线程中获取执行结果
try {
    // boolean result = (boolean) futureTask.get();
    boolean result = (boolean) futureTask.get(5, TimeUnit.SECONDS);
    Log.d(TAG, "result:" + result);
} catch (InterruptedException e) {
    Log.e(TAG, "守护线程阻塞被打断...");
    e.printStackTrace();
} catch (ExecutionException e) {
    Log.e(TAG, "执行任务时出错...");
    e.printStackTrace();
} catch (TimeoutException e) {
    Log.e(TAG, "执行超时...");
    futureTask.cancel(true);
    e.printStackTrace();
} catch (CancellationException e) {
    //如果线程已经cancel了，再执行get操作会抛出这个异常
    Log.e(TAG, "future已经cancel了...");
    e.printStackTrace();
}
```

### Future + ExecutorService

```java
//step1 ......
//step2:创建计算任务
Task task = new Task();
//step3:创建线程池，将Callable类型的task提交给线程池执行，通过Future获取子任务的执行结果
ExecutorService executorService = Executors.newCachedThreadPool();
final Future<Boolean> future = executorService.submit(task);
//step4：通过future获取执行结果
boolean result = (boolean) future.get();
```

### FutureTask + ExecutorService

```java
//step1 ......
//step2 ......
//step3:将FutureTask提交给线程池执行
ExecutorService executorService = Executors.newCachedThreadPool();
executorService.execute(futureTask);
//step4 ......
```

# 开发中我遇到的问题

FutureTask使用还是比较简单的，FutureTask与Runnable，最大的区别有两个，一个是可以获取执行结果，另一个是可以取消，使用方法可以参考以上步骤，不过我在项目中使用FutureTask出现了以下两个问题：

+	有的情况下，使用 futuretask.cancel(true)方法并不能真正的结束子任务执行。
+	FutureTask的get(long timeout, TimeUnit unit)方法，是等待timeout时间后，获取子线程的执行结果，但是如果子任务执行结束了，但是超时时间还没有到，这个方法也会返回结果。

# 结合FutureTask的源码分析问题

## 成员变量

下面，结合FutureTask的源码，分析一下以上两个问题。在此之前，先看一下FutureTask内部比较值得关注的几个成员变量。

### private volatile int state

state用来标识当前任务的运行状态。FutureTask的所有方法都是围绕这个状态进行的，需要注意，这个值用volatile（易变的）来标记，如果有多个子线程在执行FutureTask，那么它们看到的都会是同一个state，有如下几个值：

```java
 private volatile int state;
 private static final int NEW          = 0;
 private static final int COMPLETING   = 1;
 private static final int NORMAL       = 2;
 private static final int EXCEPTIONAL  = 3;
 private static final int CANCELLED    = 4;
 private static final int INTERRUPTING = 5;
 private static final int INTERRUPTED  = 6;
```

+	NEW：表示这是一个新的任务，或者还没有执行完的任务，是初始状态。
+	COMPLETING：表示任务执行结束（正常执行结束，或者发生异常结束），但是还没有将结果保存到outcome中。是一个中间状态。
+	NORMAL：表示任务正常执行结束，并且已经把执行结果保存到outcome字段中。是一个最终状态。
+	EXCEPTIONAL：表示任务发生异常结束，异常信息已经保存到outcome中，这是一个最终状态。
+	CANCELLED：任务在新建之后，执行结束之前被取消了，但是不要求中断正在执行的线程，也就是调用了cancel(false)，任务就是CANCELLED状态，这时任务状态变化是NEW -> CANCELLED。
+	INTERRUPTING：任务在新建之后，执行结束之前被取消了，并要求中断线程的执行，也就是调用了cancel(true)，这时任务状态就是INTERRUPTING。这是一个中间状态。
+	INTERRUPTED：调用cancel(true)取消异步任务，会调用interrupt()中断线程的执行，然后状态会从INTERRUPTING变到INTERRUPTED。

状态变化有如下4种情况：

+	NEW -> COMPLETING -> NORMAL ---- 正常执行结束的流程
+	NEW -> COMPLETING -> EXCEPTIONAL ---- 执行过程中出现异常的流程
+	NEW -> CANCELLED ---- 被取消，即调用了cancel(false)
+	NEW -> INTERRUPTING -> INTERRUPTED ---- 被中断，即调用了cancel(true)

### private Callable<V> callable

一个Callable类型的变量，封装了计算任务，可获取计算结果。从上面的用法中可以看到，FutureTask的构造函数中，我们传入的就是实现了Callable的接口的计算任务。

### private Object outcome

Object类型的变量outcome，用来保存计算任务的返回结果，或者执行过程中抛出的异常。

### private volatile Thread runner

指向当前在运行Callable任务的线程，runner在FutureTask中的赋值变化很值得关注，后面源码会详细介绍这个。

### private volatile WaitNode waiters

WaitNode是FutureTask的内部类，表示一个阻塞队列，如果任务还没有执行结束，那么调用get()获取结果的线程会阻塞，在这个阻塞队列中排队等待。

## 成员函数

下面从构造函数说起，看一下FutureTask的源码。

### 构造函数

+	构造函数1

```java
public FutureTask(Callable<V> callable) {
    if (callable == null)
        throw new NullPointerException();
    this.callable = callable;
    this.state = NEW;       // ensure visibility of callable
}
```

FutureTask的第一个构造函数，参数是Callable类型的变量。将传入的参数赋值给this.callable，然后设置state状态为NEW，表示这是新任务。

+	构造函数2

```java
public FutureTask(Runnable runnable, V result) {
    this.callable = Executors.callable(runnable, result);
    this.state = NEW;       // ensure visibility of callable
}
```

FutureTask还有一个构造函数，接收Runnable类型的参数，通过Executors.callable(runnable, result)将传入的Runnable和result转换成Callable类型。使用该构造方法，可以定制返回结果。

+	构造函数3

```java
public static <T> Callable<T> callable(Runnable task, T result) {
    if (task == null)
        throw new NullPointerException();
    return new RunnableAdapter<T>(task, result);
}
```

可以看一下Executors.callable(runnable, result)方法，这里通过适配器模式进行适配，创建一个RunnableAdapter适配器。

```java
private static final class RunnableAdapter<T> implements Callable<T> {
    private final Runnable task;
    private final T result;
    RunnableAdapter(Runnable task, T result) {
        this.task = task;
        this.result = result;
    }
    public T call() {
        task.run();
        return result;
    }
}
```

RunnableAdapter是Executors的内部类，实现也比较简单，实现了适配对象Callable接口，在call()方法中执行Runnable的run()，然后返回result。


### 任务被执行:run()

FutureTask封装了计算任务，无论是提交给Thread执行，或者线程池执行，调用的都是FutureTask的run()。

```java
public void run() {
    //1.判断状态是否是NEW，不是NEW，说明任务已经被其他线程执行，甚至执行结束，或者被取消了，直接返回
    //2.调用CAS方法，判断RUNNER为null的话，就将当前线程保存到RUNNER中，设置RUNNER失败，就直接返回
    if (state != NEW ||
            !U.compareAndSwapObject(this, RUNNER, null, Thread.currentThread()))
        return;
    try {
        Callable<V> c = callable;
        if (c != null && state == NEW) {
            V result;
            boolean ran;
            try {
                //3.执行Callable任务，结果保存到result中
                result = c.call();
                ran = true;
            } catch (Throwable ex) {
                //3.1 如果执行任务过程中发生异常，将调用setException()设置异常
                result = null;
                ran = false;
                setException(ex);
            }
            //3.2 任务正常执行结束调用set(result)保存结果
            if (ran)
                set(result);
        }
    } finally {
        // runner must be non-null until state is settled to
        // prevent concurrent calls to run()
        //4. 任务执行结束，runner设置为null，表示当前没有线程在执行这个任务了
        runner = null;
        // state must be re-read after nulling runner to prevent
        // leaked interrupts
        //5. 读取状态，判断是否在执行的过程中，被中断了，如果被中断，处理中断
        int s = state;
        if (s >= INTERRUPTING)
            handlePossibleCancellationInterrupt(s);
    }
}
```

1. 	首先，判断state的值是不是NEW，如果不是NEW，说明线程已经被执行了，可能已经执行结束，或者被取消了，直接返回。
2. 	这里其实是调用了Unsafe的CAS方法，读取并设置runner的值，将当前线程保存到runner中，表示当前正在执行任务的线程。可以看到，这里设置的其实是RUNNER，和前面介绍的Thread类型的runner变量不一样的，那为什么还说设置的是runner的值？RUNNER在FutureTask中定义如下：

```java
private static final long RUNNER;
//RUNNER是一个long类型的变量，指向runner字段的偏移地址，相当于指针
RUNNER = U.objectFieldOffset
        (FutureTask.class.getDeclaredField("runner"));
```

关于Unsafe的CAS方法，简单介绍一下，它提供了一种对runner进行原子操作的方法，原子操作，意味着，这个操作不会被打断。runner被volatile字段修饰，只能保证，当多个子线程在执行FutureTask的时候，它们读取到的runner的值是同一个，但是不能保证原子操作，所以很容易读到脏数据（举个例子：线程A准备对runner进行读和写操作，读取到runner的值为null，这是，cpu切换执行线程B，线程B读取到runner的值也是null，然后又切换到线程A执行，线程A对runner赋值thread-A，此时runner的值已经不再是null，线程B读取到的runner=null就是脏数据），用Unsafe的CAS方法，来对runner进行读写，就能保证原子操作。多个线程访问run()方法时，会在这里同步。

3.	读取callable变量，执行call()，并获取执行结果。
如果执行call()的过程中发生异常，就调用setException()设置异常，setException()定义如下：

```java
protected void setException(Throwable t) {
    if (U.compareAndSwapInt(this, STATE, NEW, COMPLETING)) {
        outcome = t;
        U.putOrderedInt(this, STATE, EXCEPTIONAL); // final state
        finishCompletion();
    }
}
//a. 调用Unsafe的CAS方法，state从NEW --> COMPLETING，这里的STATE和上面的RUNNER定义类似，指向state字段的偏移地址。
//b. 将异常信息保存到outcome字段，state变成EXCEPTIONAL。
//c. 调用finishCompletion()。
//NEW --> COMPLETING --> EXCEPTIONAL。
```

如果任务正常执行结束，就调用set(result)保存结果，定义如下：

```java
protected void set(V v) {
    if (U.compareAndSwapInt(this, STATE, NEW, COMPLETING)) {
        outcome = v;
        U.putOrderedInt(this, STATE, NORMAL); // final state
        finishCompletion();
    }
}
//a. 和setException()类似，state从NEW --> COMPLETING。
//b. 将正常执行的结果result保存到outcome，state变成NORMAL。
//c. 调用finishCompletion()。NEW --> COMPLETING --> NORMAL。
```

如果状态是INTERRUPTING，表示正在被中断，这时就让出线程的执行权，给其他线程来执行。

### 获取任务的执行结果:get()

一般情况下，执行任务的线程和获取结果的线程不会是同一个，当我们在主线程或者其他线程中，获取计算任务的结果时，就会调用get方法，如果这时计算任务还没有执行完成，调用get()的线程就会阻塞等待。get()实现如下：

```java
public V get() throws InterruptedException, ExecutionException {
    int s = state;
    if (s <= COMPLETING)
        s = awaitDone(false, 0L);
    return report(s);
}
```

1.	读取任务的执行状态 state ，如果 state <= COMPLETING，说明线程还没有执行完（run()中可以看到，只有任务执行结束，或者发生异常的时候，state才会被设置成COMPLETING）。
2.	调用awaitDone(false, 0L)，进入阻塞状态。看一下awaitDone(false, 0L)的实现：

```java
private int awaitDone(boolean timed, long nanos)
        throws InterruptedException {
    long startTime = 0L;    // Special value 0L means not yet parked
    WaitNode q = null;
    boolean queued = false;
    for (;;) {
        //1. 读取状态
        //1.1 如果s > COMPLETING，表示任务已经执行结束，或者发生异常结束了，就不会阻塞，直接返回
        int s = state;
        if (s > COMPLETING) {
            if (q != null)
                q.thread = null;
            return s;
        }
        //1.2 如果s == COMPLETING，表示任务结束(正常/异常)，但是结果还没有保存到outcome字段，当前线程让出执行权，给其他线程先执行
        else if (s == COMPLETING)
            // We may have already promised (via isDone) that we are done
            // so never return empty-handed or throw InterruptedException
            Thread.yield();
        //2. 如果调用get()的线程被中断了，就从等待的线程栈中移除这个等待节点，然后抛出中断异常
        else if (Thread.interrupted()) {
            removeWaiter(q);
            throw new InterruptedException();
        }
        //3. 如果等待节点q=null,就创建一个等待节点
        else if (q == null) {
            if (timed && nanos <= 0L)
                return s;
            q = new WaitNode();
        }
        //4. 如果这个等待节点还没有加入等待队列，就加入队列头
        else if (!queued)
            queued = U.compareAndSwapObject(this, WAITERS,
                    q.next = waiters, q);
        //5. 如果设置了超时等待时间
        else if (timed) {
            //5.1 设置startTime,用于计算超时时间，如果超时时间到了，就等待队列中移除当前节点
            final long parkNanos;
            if (startTime == 0L) { // first time
                startTime = System.nanoTime();
                if (startTime == 0L)
                    startTime = 1L;
                parkNanos = nanos;
            } else {
                long elapsed = System.nanoTime() - startTime;
                if (elapsed >= nanos) {
                    removeWaiter(q);
                    return state;
                }
                parkNanos = nanos - elapsed;
            }
            // nanoTime may be slow; recheck before parking
            //5.2 如果超时时间还没有到，而且任务还没有结束，就阻塞特定时间
            if (state < COMPLETING)
                LockSupport.parkNanos(this, parkNanos);
        }
        //6. 阻塞，等待唤醒
        else
            LockSupport.park(this);
    }
}
```

这里主要有几个步骤：

+	a. 读取state，如果s > COMPLETING，表示任务已经执行结束，或者发生异常结束了，此时，调用get()的线程就不会阻塞；如果s == COMPLETING，表示任务结束(正常/异常)，但是结果还没有保存到outcome字段，当前线程让出执行权，给其他线程先执行。
+	b. 判断Thread.interrupted()，如果调用get()的线程被中断了，就从等待的线程栈(其实就是一个WaitNode节点队列或者说是栈)中移除这个等待节点，然后抛出中断异常。
+	c. 判断q == null，如果等待节点q为null，就创建等待节点，这个节点后面会被插入阻塞队列。
+	d. 判断queued，这里是将c中创建节点q加入队列头。使用Unsafe的CAS方法，对waiters进行赋值，waiters也是一个WaitNode节点，相当于队列头，或者理解为队列的头指针。通过WaitNode可以遍历整个阻塞队列。
+	e. 之后，判断timed，这是从get()传入的值，表示是否设置了超时时间。设置超时时间之后，调用get()的线程最多阻塞nanos，就会从阻塞状态醒过来。如果没有设置超时时间，就直接进入阻塞状态，等待被其他线程唤醒。

awaitDone()方法内部有一个无限循环，看似有很多判断，比较难理解，其实这个循环最多循环3次。
假设Thread A执行了get()获取计算任务执行结果，但是子任务还没有执行完，而且Thread A没有被中断，它会进行以下步骤。

+	step1：Thread A执行了awaitDone()，1，2两次判断都不成立，Thread A判断q=null，会创建一个WaitNode节点q，然后进入第二次循环。
+	step2：第二次循环，判断4不成立，此时将step1创建的节点q加入队列头。
+	step3：第三次循环，判断是否设置了超时时间，如果设置了超时时间，就阻塞特定时间，否则，一直阻塞，等待被其他线程唤醒。

3.	从awaitDone()返回，最后调用report(int s)，这个后面再介绍。

### 取消任务:cancel(boolean mayInterruptIfRunning)

通常调用cancel()的线程和执行子任务的线程不会是同一个。当FutureTask的cancel(boolean mayInterruptIfRunning)方法被调用时，如果子任务还没有执行，那么这个任务就不会执行了，如果子任务已经执行，且mayInterruptIfRunning=true，那么执行子任务的线程会被中断（注意：这里说的是线程被中断，不是任务被取消），下面看一下这个方法的实现：

```java
public boolean cancel(boolean mayInterruptIfRunning) {
    //1.判断state是否为NEW，如果不是NEW，说明任务已经结束或者被取消了，该方法会执行返回false
    //state=NEW时，判断mayInterruptIfRunning，如果mayInterruptIfRunning=true，说明要中断任务的执行，NEW->INTERRUPTING
    //如果mayInterruptIfRunning=false,不需要中断，状态改为CANCELLED
    if (!(state == NEW &&
            U.compareAndSwapInt(this, STATE, NEW,
                    mayInterruptIfRunning ? INTERRUPTING : CANCELLED)))
        return false;
    try {    // in case call to interrupt throws exception
        if (mayInterruptIfRunning) {
            try {
                //2.读取当前正在执行子任务的线程runner,调用t.interrupt()，中断线程执行
                Thread t = runner;
                if (t != null)
                    t.interrupt();
            } finally { // final state
                //3.修改状态为INTERRUPTED
                U.putOrderedInt(this, STATE, INTERRUPTED);
            }
        }
    } finally {
        finishCompletion();
    }
    return true;
}
```

cancel()分析：

+	判断state，保证state = NEW才能继续cancel()的后续操作。state=NEW且mayInterruptIfRunning=true，说明要中断任务的执行，此时，NEW->INTERRUPTING。然后读取当前执行任务的线程runner，调用t.interrupt()，中断线程执行，NEW->INTERRUPTING->INTERRUPTED，最后调用finishCompletion()。
+	如果NEW->INTERRUPTING，那么cancel()方法，只是修改了状态，NEW->CANCELLED，然后直接调用finishCompletion()。

所以cancel(true)方法，只是调用t.interrupt()，此时，如果t因为sleep()，wait()等方法进入阻塞状态，那么阻塞的地方会抛出InterruptedException；如果线程正常运行，需要结合Thread的interrupted()方法进行判断，才能结束，否则，cancel(true)不能结束正在执行的任务。

这也就可以解释前面我遇到的问题，有的情况下，使用 futuretask.cancel(true)方法并不能真正的结束子任务执行。

### 子线程返回结果前的最后一步:finishCompletion()

前面多次出现过这个方法，set(V v)(保存执行结果，设置状态为NORMAL)，setException(Throwable t)(保存结果，设置状态为EXCEPTIONAL)和cancel(boolean mayInterruptIfRunning)(设置状态为CANCELLED/INTERRUPTED)，该方法在state变成最终态之后，会被调用。

```java
private void finishCompletion() {
    // assert state > COMPLETING;
    for (WaitNode q; (q = waiters) != null;) {
        if (U.compareAndSwapObject(this, WAITERS, q, null)) {
            for (;;) {
                Thread t = q.thread;
                if (t != null) {
                    q.thread = null;
                    LockSupport.unpark(t);
                }
                WaitNode next = q.next;
                if (next == null)
                    break;
                q.next = null; // unlink to help gc
                q = next;
            }
            break;
        }
    }

    done();

    callable = null;        // to reduce footprint
}
```

finishCompletion()主要做了三件事情：

+	遍历waiters等待队列，调用LockSupport.unpark(t)唤醒等待返回结果的线程，释放资源。
+	调用done()，这个方法什么都没有做，不过子类可以实现这个方法，做一些额外的操作。
+	设置callable为null，callable是FutureTask封装的任务，任务执行完，释放资源。

这里可以解答上面的第二个问题了。FutureTask的get(long timeout, TimeUnit unit)方法，表示阻塞timeout时间后，获取子线程的执行结果，但是如果子任务执行结束了，但是超时时间还没有到，这个方法也会返回结果。因为任务执行完之后，会遍历阻塞队列，唤醒阻塞的线程。LockSupport.unpark(t)执行之后，阻塞的线程会从LockSupport.park(this)/LockSupport.parkNanos(this, parkNanos)醒来，然后会继续进入awaitDone(boolean timed, long nanos)的while循环，此时，state >= COMPLETING，然后从awaitDone()返回。此时，get()/get(long timeout, TimeUnit unit)会继续执行，return report(s)，上面介绍get()的时候没介绍的方法。看一下report(int s)：

```java
private V report(int s) throws ExecutionException {
    Object x = outcome;
    if (s == NORMAL)
        return (V)x;
    if (s >= CANCELLED)
        throw new CancellationException();
    throw new ExecutionException((Throwable)x);
}
```

### 其他方法

FutureTask的还有两个方法isCancelled()和isDone()，其实就是判断state，没有过多的步骤。

```java
public boolean isCancelled() {
    return state >= CANCELLED;
}

public boolean isDone() {
    return state != NEW;
}
```

# 总结

到此FutureTask分析完毕，其中感受最深的是Unsafe的用法，对于多线程共享的对象，采用volatile + Unsafe的方法，代替锁操作，进行同步；

其次，是LockSupport的park(Object blocker)和unpark(Thread thread)的使用

park(Object blocker)：线程进入阻塞状态，告诉线程调度，当前线程不可用，直到线程再次获取permit(允许)；如果在调用park(Object blocker)之前，线程已经获得了permit(比如说，已经调用了unpark(t))，那么该方法会返回。
unpark(Thread thread)：使得传入的线程再次获得permit.这里的permit可以理解为一个信号量。
LockSupport在这里的作用，类似于wait(),notify()/notifyAll()，关于二者的区别，可以看一下
[Java的LockSupport.park()实现分析](http://www.importnew.com/20428.html)。

# 来源
[可取消的异步任务——FutureTask用法及解析](https://www.jianshu.com/p/55221d045f39)




