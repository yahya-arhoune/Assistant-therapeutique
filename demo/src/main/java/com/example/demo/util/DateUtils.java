package com.example.demo.util;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

public class DateUtils {

    private static final DateTimeFormatter FORMATTER =
            DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");

    private DateUtils() {
        // Prevent instantiation
    }

    public static String format(LocalDateTime dateTime) {
        return dateTime.format(FORMATTER);
    }

    public static LocalDateTime now() {
        return LocalDateTime.now();
    }
}