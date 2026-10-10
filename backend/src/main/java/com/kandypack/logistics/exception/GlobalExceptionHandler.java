
package com.kandypack.logistics.exception;

import java.sql.SQLException;
import java.time.LocalDateTime;
import java.util.stream.Collectors;

import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.MissingServletRequestParameterException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.context.request.WebRequest;
import org.springframework.web.method.annotation.MethodArgumentTypeMismatchException;

@RestControllerAdvice
public class GlobalExceptionHandler {

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

    // Find SQL exceptions wrapped inside Spring/JDBC exceptions.
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

    // 2. Invalid request body fields -> HTTP 400
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

    // 3. Invalid business arguments -> HTTP 400
    @ExceptionHandler(IllegalArgumentException.class)
    public ResponseEntity<ErrorResponse> handleIllegalArgument(
            IllegalArgumentException ex,
            WebRequest request) {

        String message = ex.getMessage() != null
                ? ex.getMessage()
                : "Invalid request argument.";

        return buildErrorResponse(
                HttpStatus.BAD_REQUEST,
                message,
                request
        );
    }

    // 4. Missing required query parameter -> HTTP 400
    @ExceptionHandler(MissingServletRequestParameterException.class)
    public ResponseEntity<ErrorResponse> handleMissingParameter(
            MissingServletRequestParameterException ex,
            WebRequest request) {

        return buildErrorResponse(
                HttpStatus.BAD_REQUEST,
                "Missing required request parameter: "
                        + ex.getParameterName(),
                request
        );
    }

    // 5. Wrong type for a query/path parameter -> HTTP 400
    @ExceptionHandler(MethodArgumentTypeMismatchException.class)
    public ResponseEntity<ErrorResponse> handleParameterTypeMismatch(
            MethodArgumentTypeMismatchException ex,
            WebRequest request) {

        return buildErrorResponse(
                HttpStatus.BAD_REQUEST,
                "Invalid value for request parameter: " + ex.getName(),
                request
        );
    }

    // 6. Database integrity violations and MySQL business-rule errors
    @ExceptionHandler(DataIntegrityViolationException.class)
    public ResponseEntity<ErrorResponse> handleDataIntegrityViolation(
            DataIntegrityViolationException ex,
            WebRequest request) {

        SQLException sql = findSqlException(ex);

        // MySQL trigger/procedure SIGNAL SQLSTATE '45000'
        if (sql != null && "45000".equals(sql.getSQLState())) {
            return buildErrorResponse(
                    HttpStatus.BAD_REQUEST,
                    sql.getMessage(),
                    request
            );
        }

        // Genuine constraint or duplicate-key violation
        return buildErrorResponse(
                HttpStatus.CONFLICT,
                "Data integrity violation: possibly a duplicate key or constraint violation.",
                request
        );
    }

    // 7. Unexpected errors, including wrapped SQL business-rule errors
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
