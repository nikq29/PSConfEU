
# List the modules that will be embedded into Azure Function App deployment
$requiredModules = @{
   "Microsoft.Graph.Authentication" = "2.37.0"
   "Microsoft.Graph.Users"          = "2.37.0"
   "Microsoft.Graph.Groups"         = "2.37.0"
   "Az.Accounts"                    = "4.0.0"
}

$requiredModules | Out-Null