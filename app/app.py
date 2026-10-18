"""QuickNotes - application fil rouge du module Infrastructure as Code.

Mini-API Flask qui stocke des notes dans PostgreSQL.
Toute la configuration passe par des variables d'environnement (principe 12-factor) :
c'est ce qui permet de deployer la MEME application en dev, test et prod.
"""
import os
import socket

import psycopg
from flask import Flask, jsonify, request

app = Flask(__name__)

APP_ENV = os.getenv("APP_ENV", "dev")
APP_VERSION = os.getenv("APP_VERSION", "1.0.0")


def db_conninfo() -> str:
    return (
        f"host={os.getenv('DB_HOST', 'localhost')} "
        f"port={os.getenv('DB_PORT', '5432')} "
        f"dbname={os.getenv('DB_NAME', 'quicknotes')} "
        f"user={os.getenv('DB_USER', 'quicknotes')} "
        f"password={os.getenv('DB_PASSWORD', '')} "
        "connect_timeout=3"
    )


def get_conn():
    return psycopg.connect(db_conninfo(), autocommit=True)


def init_db():
    with get_conn() as conn:
        conn.execute(
            """CREATE TABLE IF NOT EXISTS notes (
                   id SERIAL PRIMARY KEY,
                   content TEXT NOT NULL,
                   created_at TIMESTAMPTZ DEFAULT now()
               )"""
        )


@app.get("/")
def index():
    return (
        f"<h1>QuickNotes</h1>"
        f"<p>Environnement : <b>{APP_ENV}</b> - version {APP_VERSION}</p>"
        f"<p>Servi par : <code>{socket.gethostname()}</code></p>"
        f"<p>API : <code>GET/POST /api/notes</code> - sante : <code>/health</code></p>"
    )


@app.get("/health")
def health():
    """Endpoint de sante : utilise par Docker, Ansible, Kubernetes et le monitoring."""
    try:
        with get_conn() as conn:
            conn.execute("SELECT 1")
        return jsonify(status="ok", db="ok", env=APP_ENV, version=APP_VERSION), 200
    except Exception as exc:  # noqa: BLE001
        return jsonify(status="degraded", db="unreachable", error=str(exc)), 503


@app.get("/api/notes")
def list_notes():
    init_db()
    with get_conn() as conn:
        rows = conn.execute(
            "SELECT id, content, created_at FROM notes ORDER BY id DESC LIMIT 50"
        ).fetchall()
    return jsonify([{"id": r[0], "content": r[1], "created_at": r[2].isoformat()} for r in rows])


@app.post("/api/notes")
def add_note():
    init_db()
    payload = request.get_json(silent=True) or {}
    content = (payload.get("content") or "").strip()
    if not content:
        return jsonify(error="champ 'content' obligatoire"), 400
    with get_conn() as conn:
        row = conn.execute(
            "INSERT INTO notes (content) VALUES (%s) RETURNING id", (content,)
        ).fetchone()
    return jsonify(id=row[0], content=content), 201


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=int(os.getenv("APP_PORT", "8000")))
