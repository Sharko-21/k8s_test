from fastapi import FastAPI
import socket
import os
from datetime import datetime

app = FastAPI()

@app.get("/")
def read_root():
    return {
        "time": datetime.utcnow().isoformat(),
	"release": os.getenv("RELEASE", "unknown"),
        "pod_name": socket.gethostname(),
        "node_name": os.getenv("NODE_NAME", "unknown"),
        "deployment": os.getenv("DEPLOYMENT_NAME", "unknown"),
        "service": os.getenv("SERVICE_NAME", "unknown"),
        "cluster": os.getenv("CLUSTER_NAME", "unknown")
    }
