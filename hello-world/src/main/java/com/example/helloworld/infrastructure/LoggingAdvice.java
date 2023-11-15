package com.example.helloworld.infrastructure;

import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.extern.log4j.Log4j2;
import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.Pointcut;
import org.springframework.stereotype.Component;

@Aspect
@Component
@Log4j2
public class LoggingAdvice {

    @Pointcut("within(@com.example.helloworld.infrastructure.annotation.LogInputOutput *)")
    public void classSignature() {
    }

    @Pointcut("execution(@com.example.helloworld.infrastructure.annotation.LogInputOutput * * (..))")
    public void methodSignature() {
    }
   /* @Pointcut(value="execution(* com.example.helloworld.*.*.*(..))")
    public  void myPointcut(){

    }*/
    @Around("classSignature() || methodSignature()")
    public Object applicationLogger(ProceedingJoinPoint pjp) throws Throwable{
        ObjectMapper mapper=new ObjectMapper();
        String methodName=pjp.getSignature().getName();
        String className=pjp.getTarget().getClass().toString();
        Object[] array=pjp.getArgs();
        /*log.info("method invoked "  +
                "arguments : "+ mapper.writeValueAsString(array));*/
        Object object= pjp.proceed();
       /* log.info(
                "Response : "+ mapper.writeValueAsString(object));*/
        return object;
    }
}

