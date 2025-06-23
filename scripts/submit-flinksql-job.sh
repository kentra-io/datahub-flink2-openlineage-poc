#!/bin/bash

# --- Session Creation ---
echo "Creating a new Flink SQL session..."
SESSION_HANDLE=$(curl -s -X POST \
     -H "Content-Type: application/json" \
     -d '{"sessionName": "my_flink_sql_job_session"}' \
     http://localhost:8083/v1/sessions | jq -r '.sessionHandle')

# Verify the session handle
if [ -z "$SESSION_HANDLE" ]; then
  echo "Error: Failed to create session or retrieve session handle."
  exit 1
fi
echo "Session Handle: ${SESSION_HANDLE}"

# --- Function to submit SQL statements from a file ---
submit_sql_from_file() {
  local filename="$1"
  local script_dir
  script_dir="$(cd "$(dirname "$0")" && pwd)"
  local filepath="${script_dir}/flinksql/${filename}"

  if [ ! -f "$filepath" ]; then
    echo "Error: SQL file not found: ${filepath}"
    exit 1
  fi

  echo "Submitting statement from ${filename}..."
  SQL_STATEMENT=$(cat "$filepath")
  echo "SQL Statement: ${SQL_STATEMENT}"

  JSON_PAYLOAD=$(jq -n --arg stmt "$SQL_STATEMENT" '{statement: $stmt}')

  curl -X POST \
       -H "Content-Type: application/json" \
       -d "$JSON_PAYLOAD" \
       http://localhost:8083/v1/sessions/${SESSION_HANDLE}/statements
  echo ""
}

# --- Submit queries from files ---
submit_sql_from_file "1-set-pipeline-name.sql"
submit_sql_from_file "2-create-source-table.sql"
submit_sql_from_file "3-create-sink-table.sql"
submit_sql_from_file "4-create-job.sql"

echo "All statements submitted."

# You might want to add a cleanup step here to close the session if it's no longer needed.
# For example:
# echo "Closing session..."
# curl -X DELETE http://localhost:8083/v1/sessions/${SESSION_HANDLE}