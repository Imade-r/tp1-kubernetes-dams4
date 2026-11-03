package com.example.b;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.client.RestTemplate;

@RestController
public class BController {

    @Value("${SERVICE_C_URL}")
    private String serviceCUrl;

    private final RestTemplate rest = new RestTemplate();

    @GetMapping("/")
    public String callC() {
        return "B -> " + rest.getForObject(serviceCUrl, String.class);
    }

    @GetMapping("/health")
    public ResponseEntity<String> health() {
        return ResponseEntity.ok("ok");
    }
}
