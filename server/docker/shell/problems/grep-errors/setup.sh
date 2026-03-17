#!/bin/bash
# Setup: 5 service log files, user must find which ones contain ERROR and write the filenames to found.txt

mkdir -p /home/user/services

cat > /home/user/services/auth.log << 'EOF'
2024-01-20 08:00:01 INFO  Server started
2024-01-20 08:01:15 INFO  User login: alice
2024-01-20 08:05:42 ERROR Failed to connect to database: timeout
2024-01-20 08:06:01 INFO  Reconnect attempt 1
EOF

cat > /home/user/services/api.log << 'EOF'
2024-01-20 08:00:05 INFO  API listening on :3000
2024-01-20 08:02:11 INFO  GET /health 200
2024-01-20 08:03:44 INFO  POST /users 201
2024-01-20 08:04:55 INFO  GET /posts 200
EOF

cat > /home/user/services/worker.log << 'EOF'
2024-01-20 08:00:10 INFO  Worker started, queue=jobs
2024-01-20 08:01:00 INFO  Processing job 1001
2024-01-20 08:01:05 ERROR Job 1001 failed: out of memory
2024-01-20 08:01:06 INFO  Job 1001 retrying
2024-01-20 08:02:00 ERROR Job 1001 failed again: out of memory
EOF

cat > /home/user/services/cache.log << 'EOF'
2024-01-20 08:00:03 INFO  Redis connected
2024-01-20 08:01:00 INFO  Cache hit ratio: 94%
2024-01-20 08:02:00 INFO  Cache hit ratio: 96%
EOF

cat > /home/user/services/mailer.log << 'EOF'
2024-01-20 08:00:07 INFO  Mailer ready
2024-01-20 08:03:22 ERROR SMTP connection refused: mail.example.com:587
2024-01-20 08:03:23 INFO  Falling back to secondary SMTP
EOF

chown -R user:user /home/user/services