#include "utils/Logger.hpp"
#include <iostream>

Logger* Logger::s_instance = nullptr;

Logger::Logger() : m_minLevel(LogLevel::DEBUG) {
    m_logFile.open("app.log", std::ios::app);
}

Logger& Logger::getInstance() {
    if (!s_instance) {
        s_instance = new Logger();
    }
    return *s_instance;
}

void Logger::setMinLevel(LogLevel level) {
    m_minLevel = level;
}

void Logger::log(LogLevel level, const std::string& message) {
    if (level < m_minLevel) return;

    std::string levelStr;
    switch (level) {
    case LogLevel::DEBUG:
        levelStr = "[DEBUG]";
        break;
    case LogLevel::INFO:
        levelStr = "[INFO]";
        break;
    case LogLevel::WARNING:
        levelStr = "[WARNING]";
        break;
    case LogLevel::ERROR:
        levelStr = "[ERROR]";
        break;
    }

    std::string logMessage = levelStr + " " + message;
    std::cout << logMessage << std::endl;
    if (m_logFile.is_open()) {
        m_logFile << logMessage << std::endl;
    }
}

void Logger::debug(const std::string& message) {
    log(LogLevel::DEBUG, message);
}

void Logger::info(const std::string& message) {
    log(LogLevel::INFO, message);
}

void Logger::warning(const std::string& message) {
    log(LogLevel::WARNING, message);
}

void Logger::error(const std::string& message) {
    log(LogLevel::ERROR, message);
}
