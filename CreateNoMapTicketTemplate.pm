Name: CreateNoMapTicket

Description: Created dependedOn ticket in noMap state

===Create-Ticket: createnoMapticket
Subject: Map creation sub-workflow for {$Tickets{'TOP'}->Subject}
Depended-On-By: {$Tickets{'TOP'}->id}
Refers-To: {$Tickets{'TOP'}->id}
Queue: {$Tickets{'TOP'}->QueueObj->Name}
Status: noMap
Content: This ticket is automatically created when a project card ticket reaches the memoCompleted status. Please assign it to a member of the BOINK administrator group
ENDOFCONTENT

