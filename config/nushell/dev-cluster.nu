def main [workers: int] {
  mut added = 0
  for _ in 0..$workers { 
    let result = (minikube node add --worker)
    $added += 1
  }
  print $"Success: added ($added) workers"
  kubectl get nodes -o wide
}


