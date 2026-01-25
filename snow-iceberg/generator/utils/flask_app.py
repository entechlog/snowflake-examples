"""
Flask application for health checks and statistics endpoints
"""

from datetime import datetime
from flask import Flask, jsonify

from .config import (
    AWS_REGION,
    S3_BASE_PATH,
    S3_PATH_FORMAT,
    S3_WAREHOUSE_PATH,
    GLUE_DATABASE,
    SCHEMA_FILE,
)
from .stats import Stats


def create_flask_app(stats: Stats, generator=None) -> Flask:
    """
    Create and configure Flask application with health and stats endpoints.

    Args:
        stats: Stats instance for tracking generation statistics.
        generator: Optional SchemaBasedGenerator instance for schema endpoint.

    Returns:
        Configured Flask application.
    """
    app = Flask(__name__)

    @app.route("/health")
    def health():
        """Health check endpoint"""
        uptime = stats.get_uptime()
        return jsonify(
            {
                "status": "healthy",
                "uptime_seconds": round(uptime, 2),
                "cycles_completed": stats.cycles,
                "total_records": stats.total_records,
                "errors": stats.errors,
                "timestamp": datetime.now().isoformat(),
            }
        )

    @app.route("/stats")
    def get_stats():
        """Detailed statistics endpoint"""
        stats_dict = stats.to_dict()
        stats_dict["config"] = {
            "aws_region": AWS_REGION,
            "s3_base_path": S3_BASE_PATH,
            "s3_path_format": S3_PATH_FORMAT,
            "s3_warehouse_path": S3_WAREHOUSE_PATH,
            "glue_database": GLUE_DATABASE,
            "schema_file": SCHEMA_FILE,
            "generation_interval": generator.get_generation_interval() if generator else None,
        }
        stats_dict["timestamp"] = datetime.now().isoformat()
        return jsonify(stats_dict)

    @app.route("/schema")
    def get_schema():
        """Return the loaded schema configuration"""
        if generator is None:
            return jsonify({"error": "Generator not initialized"}), 500

        return jsonify(
            {
                "tables": list(generator.get_table_names()),
                "table_details": {
                    name: {
                        "description": generator.tables[name].get("description", ""),
                        "batch_size": generator.tables[name].get(
                            "batch_size",
                            generator.config.get("default_batch_size", 100),
                        ),
                        "fields_count": len(generator.tables[name].get("fields", [])),
                    }
                    for name in generator.get_table_names()
                },
                "config": generator.config,
            }
        )

    return app
