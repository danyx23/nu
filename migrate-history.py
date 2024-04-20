# This migration script is used to convert the history.txt file to a history.sql file that can be imported into the sqlite3 database.
# It is done in python instead of nushell as on windows the history file can be locked while a nushell shell is active.

# Run this script with `python migrate-history.py <config_dir> <hostname>`

import sys
from pathlib import Path

def multiline_command_generator(fi):
    current_command = ""
    for line in fi:
        line = line.strip()
        if not line:
            continue

        line = line.replace("'", "''")
        line = line.replace(" && ", "; ")

        if line.startswith("<\\n>"):
            current_command += "\n" + line[4:]
        else:
            if current_command:
                yield current_command
            current_command = line

    if current_command:
        yield current_command

def main(config_dir: str, hostname):
    text_file = config_dir / "history.txt"
    sql_file = config_dir / "history.sql"
    commandnumber = 0
    with open(text_file, encoding="utf-8") as fi, open(sql_file, "w", encoding="utf-8") as fo:
        for command in multiline_command_generator(fi):
            # I abuse the start_timestamp as a sequence number so the order is preserved
            fo.write(f"INSERT INTO history (command_line, start_timestamp, session_id, hostname, cwd, duration_ms, exit_status) VALUES ('{command}', {commandnumber}, 0, '{hostname}', '/', 0, 0);\n")
            commandnumber += 1

    print(f"Created the sql file at {sql_file} - you can now run it with `open {sql_file.name} | sqlite3 history.sqlite3` in your {config_dir} directory.")


if __name__ == "__main__":
    if len(sys.argv) < 3:
        raise ValueError("Config directory is required as the first argument, hostname as the second.")

    config_dir = Path(sys.argv[1])

    if not config_dir.is_dir():
        raise ValueError(f"{config_dir} is not a valid directory.")

    main(config_dir, sys.argv[2])