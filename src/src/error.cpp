#include "error.hpp"


std::string MalformedDataException::error() {
	return this->msg_;
}

std::string MalformedDataException::what() {
	return this->msg_;
}

std::string FileIOException::error() {
	return this->msg_;
}

std::string FileIOException::what() {
	return this->msg_;
}

std::string PatternNotFoundException::error() {
	return this->msg_;
}

std::string PatternNotFoundException::what() {
	return this->msg_;
}
