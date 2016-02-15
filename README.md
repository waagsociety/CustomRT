# CustomRT
Customisation for Request Tracker ticketing system

## Implementing a workflow in RT

A new workflow is defined by:

1. Modify *RT_SiteConfig.pm* with new workflow (the workflow is implemented as a lifecycle of the tickets). Look at the file `RT_SiteConfig.pm` in the section `Set(%Lifecycles,`
2. Create a new queue with new lifecycle
3. Create new groups that represent the actors for the lifecycle’s phases
4. Assign queue-based rights to the groups, so that only certain groups are authorized to progress the ticket to certain states. Look at the workflow description in `Projectkaartwijziging.pdf` to see what group can make the transition to what state
5. Assign real members to the groups. Please note that since RT cannot assign tickets to a group, in the case a group has more members, the scrips will pick one (the first) to automatically assign tickets by creation and state change. Make sure the first user of each group is a person that in case knows how to reassign a ticket.
6. Set up mail server for the new queue (http://requesttracker.wikia.com/wiki/ManualEmailConfig)
7. Implement the creation of the secondary workflow:
  1. Load custom condition (/opt/rt4/sbin/rt-setup-database --action insert --datafile ./OnMemoCompleted.pm)
  2. Create Queue dependent custom template via the Web interface (see file `CreateNoMapTicketTemplate.pm`)
  3. Create Queue dependent scrip via the Web interface. See for the fields the file `CreateNoMapTicketScrip.pm`
8. Create  one more template on the queue: name: `StatusDependentMsgTemplate`, Description: `This template is specific to the states of the ProjectProposal queue and send messages whose content depends on the ticket status`, type: `Perl`, content: paste the content of `StatusDependentMsgTemplate.pm`
9. Create 3 more scrips on the queue:
  1. 	Description: `On Owner Change Notify Owner`, Condition: `On Owner Change`, Action: `Notify Owner`, Template: `StatusDependentMsgTemplate`. Disable the standard scrip `On Owner Change Notify Owner` to avoid two outgoing e-mail messages.
  2. 	Description: `On Status Change Change Owner`, Condition: `On Status Change`, Action: `User Defined`, Template: `Blank`. When the action is `User Defined` you need to fill in the `User Defined conditions and results` section. Leave the `Custom Condition` empty, paste in `Custom action preparation code` the content of `ChangeOwnerOnStatusChangePrepCode.pm`, and in `Custom action commit code` the content of `ChangeOwnerOnStatusChangeComCode.pm`
  3. 	Description: `	On Create Ticket Change Owner`, Condition: `On Create`, Action: `User Defined`, Template: `Blank`. When the action is `User Defined` you need to fill in the `User Defined conditions and results` section. Leave the `Custom Condition` empty, paste in `Custom action preparation code` the content of `ChangeOwnerOnCreatePrepCode.pm`, and in `Custom action commit code` the content of `ChangeOwnerOnCreateComCode.pm`

At the moment there are two tickets that changes status based on the different phases of the workflow shown in `Projectkaartwijziging.pdf`. Each phase has a different owner that can operate upon it, and at each state change or upon ticket creation the scrips assign the ticket to a member of the group authorised for that particular phase.

Once a ticket on the main branch of the flow reaches the `memoCompleted` state, a new ticket is automatically created that is depended on by the main ticket. This forces the fact that unless the depended on ticket is resolved (`mapReady` status), the main ticket CAN NOT transition to the final `cardHandled` status.

## Examples for custom implementations
Parallel workflow implemented with custom fields and child tickets:
http://requesttracker.wikia.com/wiki/WorkFlow

Start subtasks from bullet list:
http://requesttracker.wikia.com/wiki/DivideTicketIntoSubtasks\

User contributions:
http://requesttracker.wikia.com/wiki/Contributions

Checks on different conditions:
http://requesttracker.wikia.com/wiki/CustomConditionSnippets

## Debug info

To debug set logging to debug level in `RT_Config.pm`:
```
vi /opt/rt4/etc/RT_Config.pm

Set($LogToFile, "debug");
Set($LogDir, '/opt/rt4/var/log');
Set($LogToFileNamed, "rt.log");    #log to rt.log
```

Then:

```
tail -f /opt/rt4/var/log/rt.log
```

Restart the web server:

```
sudo service apache2 restart
```
