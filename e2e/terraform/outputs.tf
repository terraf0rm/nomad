output "servers" {
  value = aws_instance.server.*.public_ip
}

output "linux_clients" {
  value = aws_instance.client_linux.*.public_ip
}

output "windows_clients" {
  value = aws_instance.client_windows.*.public_ip
}

output "message" {
  value = <<EOM
Your cluster has been provisioned! - To prepare your environment, run the
following:

```
export NOMAD_ADDR=http://${aws_instance.server[0].public_ip}:4646
export CONSUL_HTTP_ADDR=http://${aws_instance.server[0].public_ip}:8500
export NOMAD_E2E=1
```

Then you can run e2e tests with:

```
go test -v ./e2e
```

ssh into nodes with:
```
# server
ssh -i keys/${local.random_name}.pem ubuntu@${aws_instance.server[0].public_ip}

# clients
%{for ip in aws_instance.client_linux.*.public_ip~}
ssh -i keys/${local.random_name}.pem ubuntu@${ip}
%{endfor~}
```
EOM

}
