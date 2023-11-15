package com.example.helloworld.services;

import com.example.helloworld.infrastructure.annotation.LogInputOutput;
import lombok.extern.log4j.Log4j2;
import org.apache.logging.log4j.CloseableThreadContext;
import org.apache.logging.log4j.ThreadContext;
import org.springframework.stereotype.Service;

@Service
@Log4j2
public class HelloWorldService {

    @LogInputOutput
    public String sayHello(String name)
    {

        log.info("<<< inside sayHello >>> name {}",name);
        return " Hello Every One :) "+ this.sayHowAreYou();
    }
    @LogInputOutput
    public String sayHowAreYou()
    {
        log.info("<<< inside sayHowAreYou >>>");
        return " How Are You ? ";
    }
}
