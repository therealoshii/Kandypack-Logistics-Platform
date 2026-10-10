
package com.kandypack.logistics.exception;

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

@RestControllerAdvice
public class GlobalExceptionHandler {

    // Build a consistent error response.
    private ResponseEntity<ErrorResponse> buildErrorResponse(
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

    // Find SQL exceptions inside wrapped exceptions.
    private static SQLException findSqlException(Throwable t) {
        while (t != null) {
            if (t instanceof SQLException sql) {
                return sql;
            }
            t = t.getCause();
        }
        return null;
    }

    // 1. Resource not found -> HTTP 404
    @ExceptionHandler(ResourceNotFoundException.class)
    public ResponseEntity<ErrorResponse> handleResourceNotFound(
            ResourceNotFoundException ex,
            WebRequest request) {

        return buildErrorResponse(
                HttpStatus.NOT_FOUND,
                ex.getMessage(),
                request
        );
    }

    // 2. Invalid request fields -> HTTP 400
    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ErrorResponse> handleValidationException(
            MethodArgumentNotValidException ex,
            WebRequest request) {

        String message = ex.getBindingResult()
                .getFieldErrors()
                .stream()
                .map(error ->
                        error.getField() + ": " +
                        (error.getDefaultMessage() != null
                                ? error.getDefaultMessage()
                                : "Invalid value"))
                .distinct()
                .collect(Collectors.joining("; "));

        if (message.isBlank()) {
            message = "Request validation failed.";
        }

        return buildErrorResponse(
                HttpStatus.BAD_REQUEST,
                message,
                request
        );
    }

    // 3. Database integrity errors
    @ExceptionHandler(DataIntegrityViolationException.class)
    public ResponseEntity<ErrorResponse> handleDataIntegrityViolation(
            DataIntegrityViolationException ex,
            WebRequest request) {

        SQLException sql = findSqlException(ex);

        // Business-rule errors raised by MySQL triggers/procedures
        if (sql != null && "45000".equals(sql.getSQLState())) {
            return buildErrorResponse(
                    HttpStatus.BAD_REQUEST,
                    sql.getMessage(),
                    request
            );
        }

        // Actual duplicate-key or constraint violations
        return buildErrorResponse(
                HttpStatus.CONFLICT,
                "Data integrity violation: possibly a duplicate key or constraint violation.",
                request
        );
    }

    // 4. Unexpected exceptions
    @ExceptionHandler(Exception.class)
    public ResponseEntity<ErrorResponse> handleGlobalException(
            Exception ex,
            WebRequest request) {

        SQLException sql = findSqlException(ex);

        if (sql != null && "45000".equals(sql.getSQLState())) {
            return buildErrorResponse(
                    HttpStatus.BAD_REQUEST,
                    sql.getMessage(),
                    request
            );
        }

        return buildErrorResponse(
                HttpStatus.INTERNAL_SERVER_ERROR,
                "An unexpected server error occurred.",
                request
        );
    }
}
