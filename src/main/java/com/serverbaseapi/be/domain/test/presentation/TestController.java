package com.serverbaseapi.be.domain.test.presentation;

import com.serverbaseapi.be.common.util.Logger;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class TestController {

    @GetMapping("/api/test")
    public String test() {
        Logger.d("주석 테스트");
        return "Hello Test Controller!";
    }
}