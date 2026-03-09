"""
Logging configuration for the data generator
"""

import logging
from .config import LOG_LEVEL


def setup_logging() -> None:
    """Initialize logging with configured level and format"""
    logging.basicConfig(
        level=LOG_LEVEL,
        format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
    )


def get_logger(name: str) -> logging.Logger:
    """Get a logger with the specified name"""
    return logging.getLogger(name)
