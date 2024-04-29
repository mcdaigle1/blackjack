package com.personal.blackjack.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HelloController {

	@GetMapping("/")
	public String index() {
		String msg = "Greetings from Spring Boot!";
		return msg;
	}
}