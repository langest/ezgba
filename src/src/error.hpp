#ifndef EZGBA_ERROR_HPP
#define EZGBA_ERROR_HPP

#include <stdexcept>
#include <string>

class MalformedDataException : public std::runtime_error {
public:
	explicit MalformedDataException(const std::string &message) : runtime_error(message), msg_(message) { }
	virtual ~MalformedDataException() throw() { }
	std::string error();
	std::string what();
protected:
	std::string msg_;
};


class FileIOException : public std::runtime_error {
public:
	explicit FileIOException(const std::string & message) : runtime_error(message), msg_(message) {}
	virtual ~FileIOException() throw() {}
	std::string error();
	std::string what();

protected:
	std::string msg_;
};


class PatternNotFoundException : std::runtime_error {
public:
	explicit PatternNotFoundException(const std::string & message) : runtime_error(message), msg_(message) {}
	virtual ~PatternNotFoundException() throw() {}
	std::string error();
	std::string what();

protected:
	std::string msg_;
};


#endif //EZGBA_ERROR_HPP
