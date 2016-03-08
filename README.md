# CustomRT
Customisation for Request Tracker ticketing system

## Implementing a workflow in RT

This repository contains 2 new workflows with supporting scripts and templates. To implement them in RT, follow these instructions:

1. Modify *RT_SiteConfig.pm* in `/opt/rt4/etc/` (change according to your installation) adding the 2 new workflows (the workflow is implemented as a lifecycle of the tickets). Look at the file *RT_SiteConfig.pm* at the sections starting with `Set(%Lifecycles,`
2. Create 2 new queues with the new lifecycles, respectively `projectStart` and `projectModify`
3. For each queue, create new groups that represent the actors for that queue's lifecycle phases
4. For each queue assign queue-based rights to the groups, so that only certain groups are authorized to progress the ticket to certain states. Look at the workflow description in `Projectkaartwijziging_Updated.pdf` to see what group can make the transition to what state in what queue.
5. Assign real members to the groups. Please note that since RT cannot assign tickets to a group, in the case a group has more members, the scrips will pick one (the first) to automatically assign tickets by creation and state change. Make sure the first user of each group is a person that in case knows how to reassign a ticket. This is not true for Project Manager, since each ticket has a Custom Field where the designated PM can be specified.
6. Set up mail server for the new queue (http://requesttracker.wikia.com/wiki/ManualEmailConfig)
7. For the queue defined with the `projectStart` lifecycle, implement the creation of the secondary workflow:
  1. Load custom condition (/opt/rt4/sbin/rt-setup-database --action insert --datafile ./OnProjectSetUp.pm)
  2. Create Queue dependent custom template via the Web interface (see file *CreateFolderRequestTicketTemplate.pm*)
  3. Create Queue dependent scrip via the Web interface. See for the fields the file *CreateFolderRequestTicketScrip.pm*
8. For both queues, create  one more template on the queue: name: `StatusDependentMsgTemplate`, Description: `This template is specific to the states of the projectStart and projectModify queues and send messages whose content depends on the ticket status`, type: `Perl`, content: paste the content of *StatusDependentMsgTemplate.pm*
9. Create 4 more scrips on each queue:
  1. 	Description: `On Create Ticket Change Owner`, Condition: `On Create`, Action: `User Defined`, Template: `Blank`. When the action is `User Defined` you need to fill in the `User Defined conditions and results` section. Leave the `Custom Condition` empty, paste in `Custom action preparation code` the content of *ChangeOwnerOnCreatePrepCode.pm*, and in `Custom action commit code` the content of *ChangeOwnerOnCreateComCode.pm*
  2. 	Description: `On Status Change Change Owner`, Condition: `On Status Change`, Action: `User Defined`, Template: `Blank`. When the action is `User Defined` you need to fill in the `User Defined conditions and results` section. Leave the `Custom Condition` empty, paste in `Custom action preparation code` the content of *ChangeOwnerOnStatusChangePrepCode.pm*, and in `Custom action commit code` the content of *ChangeOwnerOnStatusChangeComCode.pm*
  3. 	Description: `On Owner Change Notify Owner`, Condition: `On Owner Change`, Action: `Notify Owner`, Template: `StatusDependentMsgTemplate`. Optionally if present disable the standard scrip `On Owner Change Notify Owner` to avoid two outgoing e-mail messages.
  4. 	Description: `On Same Owner Transaction Notify Owner`, Condition: `User Defined`, Action: `Notify Owner`, Template: `StatusDependentMsgTemplate`. When the condition is `User Defined` you need to fill in the `User Defined conditions and results` section. Paste in `Custom Condition` the content of *OnSameOwnerTransaction.pm*, leave `Custom action preparation code` and `Custom action commit code` empty.
10. Create the Custom Field to assign a PM to each ticket:
  1. Copy the file *ProjectManagers.pm* to the directory `/opt/rt4/lib/RT/CustomFieldValues/` (change according to your installation). Notice that in the file *RT_SiteConfig.pm* there is already a reference to the class defined in this scrip
  2. For each queue, define a Custom Field" `Admin->Custom Fields->Create`. Name: `DesignatedPM`, Description: `The PM that is assigned to a project proposal or project change`, Type: `Select one value`, Render Type: `Dropdown`, Field values source: `List Project Managers members` (if you do not see this field you have to restart apache), Applies to: `Tickets`, and make sure that it is enabled. Navigate to the `Applies to` tab and select both queues to apply it to.
  3. Make sure that the different groups have permission to `Modify custom field values` in `Group Rights`, `Rights for Staff` tab.


When creating a ticket, the creator or any other person modifying the ticket status can change the designated PM. When a designated PM is defined, they will be assigned to the ticket instead of the first member of the project manager group (this can be the same person, in any case the designated PM takes precedence).

Tickets change status based on the different phases of the workflow shown in `Projectkaartwijziging_Updated.pdf`. Each phase has a different owner that can operate upon it, and at each state change or upon ticket creation the scrips assign the ticket to a member of the group authorised for that particular phase.

In the `projectStart` queue, once a ticket on the main branch of the flow reaches the `projectSetUp` state, a new ticket is automatically created that is depended on by the main ticket. This forces the fact that unless the depended on ticket is resolved (`folderHandled` status), the main ticket CAN NOT transition to the final `projectHandled` status.

Email messages are contained in the file *StatusDependentMsgTemplate.pm*, in case they need to be changed the file should be reloaded in RT following the instructions above (and restarting the web server to be sure).

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

To debug set logging to debug level in *RT_Config.pm*:
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

You can also try to run directly the server without apache:

```
/opt/rt4/sbin/rt-server.fcgi
```
