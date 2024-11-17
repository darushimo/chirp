# Gunicorn configuration file
bind = "0.0.0.0:10000"
workers = 2
threads = 4
worker_class = "gthread"
worker_tmp_dir = "/dev/shm"
timeout = 120
