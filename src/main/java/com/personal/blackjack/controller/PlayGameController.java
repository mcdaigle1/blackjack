package com.personal.blackjack.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class PlayGameController {

	@GetMapping("/play_game")
	public String index() {
		return "Playing Game";
	}
}