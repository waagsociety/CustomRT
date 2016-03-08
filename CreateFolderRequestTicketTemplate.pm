Name: CreateFolderRequestTicket

Description: Create dependedOn ticket in folderRequest state

===Create-Ticket: createFolderRequestTicket
Subject: Map creation sub-workflow for {$Tickets{'TOP'}->Subject}
Depended-On-By: {$Tickets{'TOP'}->id}
Refers-To: {$Tickets{'TOP'}->id}
Queue: {$Tickets{'TOP'}->QueueObj->Name}
Status: folderRequest
CustomField-DesignatedPM: {$Tickets{'TOP'}->FirstCustomFieldValue('DesignatedPM')}
Content: This ticket is automatically created when a project card ticket reaches the projectSetUp status. It is also automatically assigned to a member of the BOINK administrator group.
ENDOFCONTENT
