#   Spring的AOP根据参数名称获取参数的值
+ date: 2019-07-21 15:58:34
+ description: Spring的AOP根据参数名称获取参数的值
+ categories:
  - Java
+ tags:
  - Spring
---
#   来源
[Spring Aop根据参数名称获取参数的值（JoinPoint根据参数名获取参数的值）](https://blog.csdn.net/qq_30038111/article/details/94406589)

#   代码
```java
import org.apache.commons.lang3.ArrayUtils;
import org.apache.commons.lang3.StringUtils;
import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.Pointcut;
import org.aspectj.lang.reflect.MethodSignature;
import org.springframework.stereotype.Component;
import javax.annotation.Resource;

@Aspect
@Component
public class AuthAspect {

    /**
     * 1.controller包及子包下的所有类的所有方法使用aop
     * 2.RoomController下的list方法不使用aop
     */
    @Pointcut(value = "execution(* com.open.controller..*.*(..)) && !execution(* com.open.controller.RoomController.list(..))")
    public void sdkAuth() {
    }

    /**
     * 案例：通过aop控制公共参数的校验
     * 1.针对下面的接口，使用@RequestParam注解，不管是get/post请求，都是有效的
     * 2.HttpServletRequest#getParameter，调用接口时的参数为appId=xxx或者groupAppId=xxx，使用getParameter("appId");都可以获取到，但getParameter("groupAppId")只可以获取到groupAppId=xxx
     * 3.在通知中，是针对方法列表中的参数名，而非注解指定的参数名
     * public Object list(String accessToken, @RequestParam("appId") String groupAppId, String subGroupAppId) {}
     *
     * @param joinPoint
     * @return
     */
    @Around("sdkAuth()")
    public Object doAround(ProceedingJoinPoint joinPoint) {
        MethodSignature methodSignature = (MethodSignature) joinPoint.getSignature();
        String[] parameterNames = methodSignature.getParameterNames();

        // 获取accessToken的下表
        int accessTokenIndex = ArrayUtils.indexOf(parameterNames, "accessToken");
        // 获取groupAppId的下标
        int groupAppIdIndex = ArrayUtils.indexOf(parameterNames, "groupAppId");
        // 获取subGroupAppId的下标
        int subGroupAppIdIndex = ArrayUtils.indexOf(parameterNames, "subGroupAppId");
        if (accessTokenIndex == -1 || groupAppIdIndex == -1 || subGroupAppIdIndex == -1) {
            return "error";
        }
        /**
         * 方法参数的值，返回的数组按照方法定义的顺序，对于null值的，在debug时，不会显示null的数组下表，例如：
         * public Object list(String accessToken, @RequestParam("appId") String groupAppId, String subGroupAppId) {}
         * 传参：accessToken=xxx&subGroupAppId=xxx
         * Object[] args = joinPoint.getArgs();获取的值，在debug时
         *      args[0] = xxx
         *      args[2] = xxx
         * 对于args[1]，虽然debug时没有显示这个变量，但实际上它是存在的，值为null
         */
        Object[] args = joinPoint.getArgs();
        String accessToken = String.valueOf(args[accessTokenIndex]);
        String groupAppId = String.valueOf(args[groupAppIdIndex]);
        String subGroupAppId = String.valueOf(args[subGroupAppIdIndex]);

        if (StringUtils.equals(accessToken, "null") || StringUtils.equals(groupAppId, "null") || StringUtils.equals(subGroupAppId, "null")) {
            return "error";
        }

        try {
            return joinPoint.proceed();
        } catch (Throwable e) {
            return "success";
        }
    }
}
```
