#   Springboot的自定义参数验证

---

针对表单提交时，我们需要对参数进行校验，然而验证的种类不能符合我们的需求，需要自定义参数验证。

自定义参数验证依赖注解实现，所有我们需要自定义一个自己的注解

##  手机号的验证注解
```java
import javax.validation.Constraint;
import javax.validation.Payload;
import java.lang.annotation.Documented;
import java.lang.annotation.Retention;
import java.lang.annotation.Target;

import static java.lang.annotation.ElementType.*;
import static java.lang.annotation.RetentionPolicy.RUNTIME;

@Target({ METHOD, FIELD, ANNOTATION_TYPE, CONSTRUCTOR, PARAMETER })
@Retention(RUNTIME)
@Documented
@Constraint(validatedBy = PhoneValidator.class)
public @interface Phone {

    boolean required() default true;
    // 这个地方修改错误提示字符，其他地方不要修改
    String message() default "手机号码格式错误";

    Class<?>[] groups() default { };

    Class<? extends Payload>[] payload() default { };

}
```

##  接着实现参数验证的类

```java
import org.apache.commons.lang3.StringUtils;

import javax.validation.ConstraintValidator;
import javax.validation.ConstraintValidatorContext;
import java.util.regex.Pattern;

/**
 * 手机号验证的实现类
 * @author molong
 * @date 2018/1/26
 */
public class PhoneValidator implements ConstraintValidator<Phone, String> {

    private boolean required = false;
    // 定义的手机号验证正则表达式
    private Pattern pattern = Pattern.compile("1(([38]\\d)|(5[^4&&\\d])|(4[579])|(7[0135678]))\\d{8}");

    @Override
    public void initialize(Phone constraintAnnotation) {
        required = constraintAnnotation.required();
    }

    @Override
    public boolean isValid(String s, ConstraintValidatorContext
                             constraintValidatorContext) {

        if(required) {
            return pattern.matcher(s).matches();
        }else {
            if(StringUtils.isEmpty(s)) {
                return false;
            }else{
                return pattern.matcher(s).matches();
            }
        }
    }
}
```

##  在实体类上添加

```java
public class Login {

    @NotNull
    @Phone
    private String mobile;

    @NotNull
    @Length(min=12)
    private String password;

    // ... set/get省略
}
```
