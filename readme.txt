Azure Event Grid Alert Handler
Description
This PowerShell script, EventGridProcessor.ps1, is designed to handle Azure Event Grid events efficiently. By parsing Event Grid messages, the script identifies the type of Azure resource event (e.g., creation, deletion) and performs logging and notifications accordingly. It utilizes PowerShell's advanced scripting capabilities to extract event details, determine the event's nature, and generate adaptive card messages for Microsoft Teams notifications, providing a seamless monitoring and alerting solution for Azure resource management.

Prerequisites
Before running this script, ensure you have:

PowerShell 7.0 or higher installed.
Access to an Azure account with permissions to read Event Grid events.
The Azure PowerShell Az module installed.
A Microsoft Teams channel set up with a webhook URL for notifications.
Installation
No installation is required for the script itself, but you may need to set up PowerShell and the Azure PowerShell module on your machine:

Modules that necessary: Az, Az.Consumption, Microsoft.Graph.
Open PowerShell and navigate to the directory containing the EventGridProcessor.ps1 script.
Run the script using the following command: ./EventGridProcessor.ps1.
The script will automatically listen for Event Grid events and process them as configured.
Script Explanation
The script starts by declaring parameters that align with Event Grid's event schema.
It logs incoming events for diagnostics and extracts the data using PowerShell's object manipulation capabilities.
Depending on the type of Azure resource event (e.g., VM creation, SQL database deletion), it sets the appropriate activity type and details.
It then constructs an adaptive card JSON payload formatted specifically for Microsoft Teams, detailing the event's nature and specifics.
Finally, it posts the adaptive card to the specified Microsoft Teams channel webhook URL for notification.
Contributing
Feel free to fork this repository and submit pull requests to contribute to this project. If you find any issues or have suggestions for improvements, please open an issue in the GitHub repository.

License
This project is distributed under the MIT License. See the LICENSE file in the repository for more details.
