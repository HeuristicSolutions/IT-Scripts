$apiKey = "413cd1df0b7ae4345a84cda9b73c1994"
$apiUrl = "https://www.site24x7.com/api/"

$getHeaders = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$getHeaders.Add("Accept", "application/json; version=2.0")
$getHeaders.Add("Authorization", "Zoho-authtoken " + $apiKey)

$postHeaders = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$postHeaders.Add("Accept", "application/json; version=2.0")
$postHeaders.Add("Authorization", "Zoho-authtoken " + $apiKey)
$postHeaders.Add("Content-Type", "application/json;charset=UTF-8")



function ListAllFor {
	Param ([String]$Name)
	$resource = $apiUrl + $Name

	$responseObj = Invoke-RestMethod -Method Get -Uri $resource -Headers $getHeaders
	$responseObj.data
}

function ListAllMonitors {
	ListAllFor "monitors"
}

function ListAllLocations {
	ListAllFor "location_profiles"
}

function ListAllUserGroups {
	ListAllFor "user_groups"
}

function ListAllUsers {
	ListAllFor "users"
}

function ListAllThresholdProfiles {
	ListAllFor "threshold_profiles"
}

function ListAllNotificationProfiles {
	ListAllFor "notification_profiles"
}

function GetMonitor {
	Param ([String]$MonitorId)
	$resource = $apiUrl + "monitors/" + $MonitorId

	$responseObj = Invoke-RestMethod -Method Get -Uri $resource -Headers $getHeaders
	$responseObj.data
}

function CreateTestUserGroup {

	$resource = $apiUrl + "user_groups"

	$data = @{
        display_name = "Test Group";
        users = @("121775000000025009");
	} | ConvertTo-Json

	$responseObj = Invoke-RestMethod -Method Post -Uri $resource -Headers $postHeaders -Body $data
	$responseObj.data

}

function CreateTestUrlMonitor {

	$resource = $apiUrl + "monitors"
	
	$data = @{
        display_name = "Test Monitor";
        type = "URL";
        website = "http://www.heuristics.net/";
        check_frequency = 5;
        http_method = "G";
        timeout = 30;
		location_profile_id = "121775000004849001";
		notification_profile_id = "121775000004849007";
		threshold_profile_id = "121775000004888011";
		user_group_ids = @("121775000000025003");
	} | ConvertTo-Json
	
	$responseObj = Invoke-RestMethod -Body $data -Method Post -Uri $resource -Headers $postHeaders
	$responseObj.data

}

function CreateTestWebApplicationMonitor {

	$resource = $apiUrl + "monitors"
	
	$data = @{
        display_name = "Test Monitor";
        type = "URL-SEQ";
        check_frequency = 5;
        timeout = 30;
		location_profile_id = "121775000004849001";
		notification_profile_id = "121775000004849007";
		threshold_profile_id = "121775000004888011";
		user_group_ids = @("121775000000025003");
	} | ConvertTo-Json
	
	$responseObj = Invoke-RestMethod -Body $data -Method Post -Uri $resource -Headers $postHeaders
	$responseObj.data

}
CreateTestWebApplicationMonitor

#ListAllMonitors
#GetMonitor "121775000001235021"
#CreateTestUrlMonitor
