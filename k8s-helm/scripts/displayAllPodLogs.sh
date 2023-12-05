#!/bin/bash -e

if ! command -v "kubectl" &> /dev/null; then
    echo "kubectl does not exist. Please install it first https://kubernetes.io/docs/tasks/tools/"
    exit 1
fi

echo "Displaying logs from all pods ..."
echo "--------------------------------------------------------------------"

for pod in $(kubectl get pods -l app.kubernetes.io/instance=nu-quickstart --template='{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}'); do
    echo "Logs for Pod: $pod"
    kubectl logs "$pod"
    echo "--------------------------------------------------------------------"
done

echo "End of pod logs"
