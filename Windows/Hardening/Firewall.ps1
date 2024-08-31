Install-Module -Name Firewall-Manager

# Save Firewall Rules
Export-FirewallRules -CSVFile “C:\Users\Administrator\Cache\DefaultRules.csv”

# Disable all
Disable-NetFirewallRule -Name (Get-NetFirewallRule | select -ExpandProperty Name)

# Default Settings
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True
Set-NetFirewallProfile -DefaultOutboundProfile Block

# New-NetFirewallProfile -DisplayName "bruh" -Direction Outbound -Protocol TCP -LocalPort ___ -Action Allow