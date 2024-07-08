output "vm_password" {
    value = random_string.password.result
}

output "db_host" {
    value = azurerm_mysql_flexible_server.talentdb-server.fqdn
}