"""Logging utilities with multiple output levels."""

from enum import IntEnum
from datetime import datetime
from typing import TextIO
import sys


class LogLevel(IntEnum):
    """Log severity levels."""

    DEBUG = 0
    INFO = 1
    WARNING = 2
    ERROR = 3
    CRITICAL = 4


class Logger:
    """Simple logger with level filtering and formatting.

    Test LSP:
    - K on LogLevel should show enum docs
    - gd on LogLevel.WARNING should jump to enum
    """

    _instance: "Logger | None" = None

    def __init__(
        self,
        name: str = "app",
        level: LogLevel = LogLevel.INFO,
        output: TextIO | None = None,
    ) -> None:
        self.name = name
        self.level = level
        self.output = output or sys.stdout
        self._format = "[{timestamp}] [{level}] {name}: {message}"

    @classmethod
    def get_instance(cls) -> "Logger":
        """Get singleton logger instance."""
        if cls._instance is None:
            cls._instance = Logger()
        return cls._instance

    @classmethod
    def set_instance(cls, logger: "Logger") -> None:
        """Set the singleton logger instance."""
        cls._instance = logger

    def _format_message(self, level: LogLevel, message: str) -> str:
        """Format a log message."""
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        return self._format.format(
            timestamp=timestamp,
            level=level.name,
            name=self.name,
            message=message,
        )

    def _log(self, level: LogLevel, message: str) -> None:
        """Internal log method."""
        if level >= self.level:
            formatted = self._format_message(level, message)
            print(formatted, file=self.output)

    def debug(self, message: str) -> None:
        """Log debug message."""
        self._log(LogLevel.DEBUG, message)

    def info(self, message: str) -> None:
        """Log info message."""
        self._log(LogLevel.INFO, message)

    def warning(self, message: str) -> None:
        """Log warning message."""
        self._log(LogLevel.WARNING, message)

    def error(self, message: str) -> None:
        """Log error message."""
        self._log(LogLevel.ERROR, message)

    def critical(self, message: str) -> None:
        """Log critical message."""
        self._log(LogLevel.CRITICAL, message)

    def set_level(self, level: LogLevel) -> None:
        """Change the minimum log level."""
        self.level = level

    def set_format(self, format_string: str) -> None:
        """Set custom format string.

        Available placeholders: {timestamp}, {level}, {name}, {message}
        """
        self._format = format_string
