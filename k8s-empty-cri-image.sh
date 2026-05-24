crictl img ls | grep none | awk '{print $3}' | xargs crictl rmi
