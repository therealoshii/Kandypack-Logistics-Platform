package com.kandypack.logistics.rail.exception;

import java.sql.SQLException;
import java.time.LocalDateTime;

import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.context.request.WebRequest;

import com.kandypack.logistics.exception.ErrorResponse;

@RestControllerAdvice(basePackages = "com.kandypack.logistics.rail")
public class RailExceptionHandler {

    private static SQLException findSqlException(Throwable t) {
        while (t != null) {
            if (t instanceof SQLException sql) return sql;
            t = t.getCause();
        }
        return null;
    }

    @ExceptionHandler({DataIntegrityViolationException.class, Exception.class})
    public ResponseEntity<ErrorResponse> handleRailException(Exception ex, WebRequest request) {
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
                .status(HttpStatus.BAD_REQUEST.value())
                .message(ex.getMessage())
                .details(request.getDescription(false))
                .build();
        return new ResponseEntity<>(body, HttpStatus.BAD_REQUEST);
    }
}