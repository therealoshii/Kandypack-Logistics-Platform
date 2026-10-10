
package com.kandypack.logistics.rail.exception;

import java.sql.SQLException;
import java.time.LocalDateTime;
import java.util.stream.Collectors;

import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.context.request.WebRequest;

import com.kandypack.logistics.exception.ErrorResponse;
import com.kandypack.logistics.exception.ResourceNotFoundException;

@RestControllerAdvice(basePackages = "com.kandypack.logistics.rail")
public class RailExceptionHandler {

    private ResponseEntity<ErrorResponse> error(
            HttpStatus status,
            String message,
            WebRequest request) {

        ErrorResponse body = ErrorResponse.builder()
                .timestamp(LocalDateTime.now())
                .status(status.value())
                .message(message)
                .details(request.getDescription(false))
                .build();

        return new ResponseEntity<>(body, status);
    }

    private static SQLException findSqlException(Throwable t) {
        while (t != null) {
            if (t instanceof SQLException sql) {
                return sql;
            }
            t = t.getCause();
        }
        return null;
    }

    @ExceptionHandler(ResourceNotFoundException.class)
    public ResponseEntity<ErrorResponse> handleNotFound(
            ResourceNotFoundException ex,
            WebRequest request) {

        return error(
                HttpStatus.NOT_FOUND,
                ex.getMessage(),
                request
        );
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ErrorResponse> handleValidation(
            MethodArgumentNotValidException ex,
            WebRequest request) {

        String message = ex.getBindingResult()
                .getFieldErrors()
                .stream()
                .map(e -> e.getField() + ": " +
                        (e.getDefaultMessage() == null
                                ? "Invalid value"
                                : e.getDefaultMessage()))
                .distinct()
                .collect(Collectors.joining("; "));

        if (message.isBlank()) {
            message = "Request validation failed.";
        }

        return error(
                HttpStatus.BAD_REQUEST,
                message,
                request
        );
    }

    @ExceptionHandler(DataIntegrityViolationException.class)
    public ResponseEntity<ErrorResponse> handleIntegrity(
            DataIntegrityViolationException ex,
            WebRequest request) {

        SQLException sql = findSqlException(ex);

        if (sql != null && "45000".equals(sql.getSQLState())) {
            return error(
                    HttpStatus.BAD_REQUEST,
                    sql.getMessage(),
                    request
            );
        }

        return error(
                HttpStatus.CONFLICT,
                "Data integrity violation: possibly a duplicate key or constraint violation.",
                request
        );
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<ErrorResponse> handleOther(
            Exception ex,
            WebRequest request) {

        SQLException sql = findSqlException(ex);

        if (sql != null && "45000".equals(sql.getSQLState())) {
            return error(
                    HttpStatus.BAD_REQUEST,
                    sql.getMessage(),
                    request
            );
        }

        return error(
                HttpStatus.INTERNAL_SERVER_ERROR,
                "An unexpected server error occurred.",
                request
        );
    }
}
