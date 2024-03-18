# Parameter Name must match bindings
param($eventGridEvent, $TriggerMetadata)

# Logging data, informational only
# log eventGridEvent in one output stream
write-output "## eventGridEvent ##"
$eventGridEvent | out-string | Write-Output

# Get Data Type
write-output "## Get-Member ##"
$eventGridEvent | Get-Member | Out-string | Write-Output

# Get output as JSON
write-output "## eventGridEvent.json ##"
$eventGridEvent | convertto-json -Depth 14 | Write-Output

# Declarations
$eventGridEventJson = $eventGridEvent | ConvertTo-Json -Depth 14 | Out-String
$eventGridObject = $eventGridEventJson | ConvertFrom-Json
$eventGridObject.data.operationName | Write-Output

# Set the default error action
$errorActionDefault = $ErrorActionPreference

# Channel Webhook.  This URL comes from the Teams channel that will receive the messages.
$ChannelURL = "https://webhook.com"

# Get the subscription
try {
    $ErrorActionPreference = 'stop'
    $SubscriptionId = $eventGridEvent.data.subscriptionId
}
catch {
    $ErrorMessage = $_.Exception.message
    write-error ('Error getting Subscription ID ' + $ErrorMessage)
    Break
}
Finally {
    $ErrorActionPreference = $errorActionDefault
}

# Set the ActivityTitle (name of resource) and ActivityType (type of resource)
# Based on the filter set in Event Grid 

if ($eventGridObject.data.operationName -like "Microsoft.Compute/virtualMachines/write") {
    $ActivityType = "vmSql Server created"
    $subjectSplit = $eventGridEvent.subject -split '/'
    $typeName = $subjectSplit[8]
}
elseif ($eventGridObject.data.operationName -like "Microsoft.Resources/subscriptions/resourceGroups/write" ) {
    $ActivityType = "Resource Group created"
    $subjectSplit = $eventGridEvent.subject -split '/'
    $typeName = $subjectSplit[4]
}
elseif ($eventGridObject.data.operationName -like "Microsoft.Resources/subscriptions/resourceGroups/delete" ) {
    $ActivityType = "Resource Group has deleted"
    $subjectSplit = $eventGridEvent.subject -split '/'
    $typeName = $subjectSplit[4]
}
elseif ($eventGridObject.data.operationName -like "Microsoft.Sql/servers/databases/delete" ) {
    $ActivityType = "Sql Database has deleted"
    $subjectSplit = $eventGridEvent.subject -split '/'
    $typeName = $subjectSplit[10], $subjectSplit[8]
}
elseif ($eventGridObject.data.operationName -like "Microsoft.Sql/servers/databases/write" ) {
    $ActivityType = "Sql Database created/updated"
    $subjectSplit = $eventGridEvent.subject -split '/'
    $typeName = $subjectSplit[10], $subjectSplit[8]

}
elseif ($eventGridObject.data.operationName -like "Microsoft.Web/serverfarms/Write" ) {
    $ActivityType = "App Service Plan created/updated"
    $subjectSplit = $eventGridEvent.subject -split '/'
    $typeName = $subjectSplit[10], $subjectSplit[8]
}

elseif ($eventGridObject.data.operationName -like "Microsoft.Web/serverfarms/Delete" ) {
    $ActivityType = "App Service Plan Deleted"
    $subjectSplit = $eventGridEvent.subject -split '/'
    $typeName = $subjectSplit[10], $subjectSplit[8]
}

elseif ($eventGridObject.data.operationName -like "Microsoft.Web/sites/Write" ) {
    $ActivityType = "Wep App created/updated"
    $subjectSplit = $eventGridEvent.subject -split '/'
    $typeName = $subjectSplit[10], $subjectSplit[8]
}

elseif ($eventGridObject.data.operationName -like "Microsoft.Web/sites/Delete" ) {
    $ActivityType = "Wep App Deleted"
    $subjectSplit = $eventGridEvent.subject -split '/'
    $typeName = $subjectSplit[10], $subjectSplit[8]
}

else {
    write-error 'No activity type defined in script.  Verify Event Grid Filter matches IF statement'
write-output "## rg scope ##"
$eventGridEventJson = $eventGridEvent | ConvertTo-Json -Depth 14 | Out-String
$eventGridObject = $eventGridEventJson | ConvertFrom-Json
$eventGridObject.data.operationName | Write-Output
    Break
}

# Build the Adaptive Card message body
$Body = @{
    type = "message"
    attachments = @(
        @{
            contentType = "application/vnd.microsoft.card.adaptive"
            contentUrl = $null
            content = @{
                '$schema' = "http://adaptivecards.io/schemas/adaptive-card.json"
                type = "AdaptiveCard"
                version = "1.5"
                body = @(
                    @{
                        type = "TextBlock"
                        text = ' Azure ' + $ActivityType
#                      weight = "bolder"
#                        size = "Large"
                        
                    },
                    @{
                        type = "TextBlock"
                        text = 'Azure ' + $ActivityType + ' named ' + $typeName
#                        separator = $true
#                       weight = "default"
#                        size = "auto"
                        maxLines = "7"
                        wrap = "true"
                        
                    },
                    @{
                        type = "TextBlock"
                        text = 'An Azure ' + $ActivityType + ' was created in the subscription ' + $SubscriptionId
#                      weight = "default"
#                        size = "Small"
                        maxLines = "7"
                        wrap = "true"
                    },
                    @{
                        type = "TextBlock"
                        text = "An Azure $($ActivityType) by $($eventGridEvent.data.claims.name)"
#                        weight = "default"
#                        size = "Small"
                        maxLines = "7"
                        wrap = "true"

                        
                    }
                )
            }
        }
    )
} | ConvertTo-Json -Depth 10
# Log the JSON body
Write-Output "Sending the following body to Teams:"
Write-Output $Body
$headers = @{
#   'Authorization' = "Bearer $token"
  'Content-Type'        = 'application/json'
}
# Send the Adaptive Card to Teams
try {
#    Invoke-RestMethod -Method "Post" -Uri $ChannelURL -Body $Body -Headers @{ "Content-Type" = "application/json" } | Write-output}
   Invoke-WebRequest -Uri $ChannelURL -SessionVariable 'Session' -Method 'POST' -Headers $headers -Body $body -ContentType 'application/json; charset=utf-8' | Write-output
}
catch {
    $ErrorMessage = $_.Exception.message
    write-error ('Error with invoke-restmethod ' + $ErrorMessage)
    if ($_.Exception.Response) {
        $stream = $_.Exception.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($stream)
        $responseBody = $reader.ReadToEnd()
        write-error "Server response: $responseBody"
    }
    Break
}
