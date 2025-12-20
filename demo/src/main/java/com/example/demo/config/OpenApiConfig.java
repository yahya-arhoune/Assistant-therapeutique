package com.example.demo.config;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Info;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class OpenApiConfig {

    @Bean
    public OpenAPI theraOpenAPI() {
        return new OpenAPI()
                .info(new Info()
                        .title("Therapeutic Assistant API")
                        .description("Backend API for the emotional tracking and therapeutic assistant application")
                        .version("1.0.0")
                );
    }
}