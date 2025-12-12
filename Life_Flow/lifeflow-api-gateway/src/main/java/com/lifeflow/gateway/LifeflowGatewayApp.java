package com.lifeflow.gateway;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;

@SpringBootApplication
@EnableDiscoveryClient
public class LifeflowGatewayApp {

    public static void main(String[] args) {
        SpringApplication.run(LifeflowGatewayApp.class, args);
    }
}
