package com.kandypack.logistics.exception;

import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.context.request.WebRequest;

import java.sql.SQLException;
import java.time.LocalDateTime;

@RestControllerAdvice
public class GlobalExceptionHandler {

    private static SQLException findSqlException(Throwable t) {
        while (t != null) {
            if (t instanceof SQLException sql) return sql;
            t = t.getCause();
        }
        return null;
    }

    @ExceptionHandler(DataIntegrityViolationException.class)
    public ResponseEntity<ErrorResponse> handleDataIntegrityViolation(DataIntegrityViolationException ex, WebRequest request) {
        SQLException sql = findSqlException(ex);
        if (sql != null && "45000".equals(sql.getSQLState())) {
            ErrorResponse body = ErrorResponse.builder()
                    .timestamp(LocalDateTime.now())
                    .status(HttpStatus.BAD_REQUEST.value())
                    .message(sql.getMessage())
                    .details(request.getDescription(false))
                    .build();
            return new ResponseEntity<>(body, HttpStatus.BAD_REQUEST);
        }

        ErrorResponse body = ErrorResponse.builder()
                .timestamp(LocalDateTime.now())
                .status(HttpStatus.CONFLICT.value())
                .message("Data integrity violation: possibly a duplicate key or constraint violation.")
                .details(request.getDescription(false))
                .build();
        return new ResponseEntity<>(body, HttpStatus.CONFLICT);
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<ErrorResponse> handleGlobalException(Exception ex, WebRequest request) {
        SQLException sql = findSqlException(ex);
        if (sql != null && "45000".equals(sql.getSQLState())) {
            ErrorResponse body = ErrorResponse.builder()
                    .timestamp(LocalDateTime.now())
                    .status(HttpStatus.BAD_REQUEST.value())
                    .message(sql.getMessage())
                    .details(request.getDescription(false))
                    .build();
            return new ResponseEntity<>(body, HttpStatus.BAD_REQUEST);
        }

        ErrorResponse body = ErrorResponse.builder()
                .timestamp(LocalDateTime.now())
                .status(HttpStatus.INTERNAL_SERVER_ERROR.value())
                .message(ex.getMessage())
                .details(request.getDescription(false))
                .build();
        return new ResponseEntity<>(body, HttpStatus.INTERNAL_SERVER_ERROR);
    }
}