Purpose:
When you make a change to a step template in Octopus, the process 
of updating all of the usages of that template via the UI is 
painful. This script facilitates updating the step templates. It 
will update all if given no additional parameters, but it also 
will allow you to specify which templates, etc., to update.


Prerequisites:
--------------
- The module must be installed. Follow the instructions here:
	https://github.com/Dalmirog/OctoPosh/wiki/Installing-the-module


Run the script:
---------------
- Open a powershell window.
- Execute the command:

  Update-StepTemplatesOnDeploymentProcesses -AllActionTemplates 
  -OctopusURI "http://octopus.heuristics.net" -APIKey 
  "API-LQOUGPO3MQXD1TOJC62NVQ2R7SQ"

