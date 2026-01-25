"""
Statistics tracking for the data generator
"""

import threading
from datetime import datetime
from typing import Dict, Any


class Stats:
    """Thread-safe statistics tracking for data generation"""

    def __init__(self):
        self._lock = threading.Lock()
        self._start_time = datetime.now()
        self._total_records = 0
        self._tables: Dict[str, Dict[str, int]] = {}
        self._cycles = 0
        self._errors = 0

    @property
    def start_time(self) -> datetime:
        """Get the start time"""
        return self._start_time

    @property
    def total_records(self) -> int:
        """Get total records count"""
        with self._lock:
            return self._total_records

    @property
    def cycles(self) -> int:
        """Get completed cycles count"""
        with self._lock:
            return self._cycles

    @property
    def errors(self) -> int:
        """Get errors count"""
        with self._lock:
            return self._errors

    def add_records(self, table_name: str, count: int) -> None:
        """Record successful write to a table"""
        with self._lock:
            self._total_records += count
            if table_name not in self._tables:
                self._tables[table_name] = {"records": 0, "batches": 0}
            self._tables[table_name]["records"] += count
            self._tables[table_name]["batches"] += 1

    def increment_cycle(self) -> None:
        """Increment the cycle counter"""
        with self._lock:
            self._cycles += 1

    def increment_errors(self) -> None:
        """Increment the error counter"""
        with self._lock:
            self._errors += 1

    def get_uptime(self) -> float:
        """Get uptime in seconds"""
        return (datetime.now() - self._start_time).total_seconds()

    def get_table_stats(self) -> Dict[str, Dict[str, int]]:
        """Get a copy of table statistics"""
        with self._lock:
            return dict(self._tables)

    def to_dict(self) -> Dict[str, Any]:
        """Convert stats to dictionary"""
        uptime = self.get_uptime()
        with self._lock:
            return {
                "uptime_seconds": round(uptime, 2),
                "cycles_completed": self._cycles,
                "total_records": self._total_records,
                "records_per_second": round(
                    self._total_records / uptime if uptime > 0 else 0, 2
                ),
                "errors": self._errors,
                "tables": dict(self._tables),
            }
