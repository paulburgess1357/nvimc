#pragma once
#include <string>
#include <fstream>

enum class LogLevel {
    DEBUG,
    INFO,
    WARNING,
    ERROR
};

class Logger {
private:
    static Logger* s_instance;
    std::ofstream m_logFile;
    LogLevel m_minLevel;

    Logger();

public:
    static Logger& getInstance();
    void setMinLevel(LogLevel level);
    void log(LogLevel level, const std::string& message);
    void debug(const std::string& message);
    void info(const std::string& message);
    void warning(const std::string& message);
    void error(const std::string& message);
};
