package com.lifeflow.common.dto;

import lombok.*;
import java.time.LocalDateTime;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ApiResponse<T> {

    private Integer statusCode;
    private String message;
    private T data;
    private LocalDateTime timestamp;
    private String path;

    public static <T> ApiResponse<T> success(String message, T data) {
        return ApiResponse.<T>builder()
                .statusCode(200)
                .message(message)
                .data(data)
                .timestamp(LocalDateTime.now())
                .build();
    }

    public static <T> ApiResponse<T> created(String message, T data) {
        return ApiResponse.<T>builder()
                .statusCode(201)
                .message(message)
                .data(data)
                .timestamp(LocalDateTime.now())
                .build();
    }

    public static <T> ApiResponse<T> error(String message, Integer statusCode) {
        return ApiResponse.<T>builder()
                .statusCode(statusCode)
                .message(message)
                .timestamp(LocalDateTime.now())
                .build();
    }
}
