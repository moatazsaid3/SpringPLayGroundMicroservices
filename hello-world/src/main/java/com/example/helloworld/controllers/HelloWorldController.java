package com.example.helloworld.controllers;

import com.example.helloworld.services.HelloWorldService;
import lombok.RequiredArgsConstructor;
import lombok.extern.log4j.Log4j2;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/hello")
@Log4j2
@RequiredArgsConstructor
public class HelloWorldController {
    @Autowired
private  HelloWorldService helloWorldService;
@GetMapping("/sayHello")
    public String sayHello()
    {
     return helloWorldService.sayHello("shimaa");
    }
}
