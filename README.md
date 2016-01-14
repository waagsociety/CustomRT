# CustomRT
Customisation for Request Tracker ticketing system

## Implementing a workflow in RT

A new workflow is defined by:

1. Modify *RT_SiteConfig.pm* with new workflow (the workflow is implemented as a lifecycle of the tickets). Look at the file `RT_SiteConfig.pm` in the section `Set(%Lifecycles,`
2. Create a new queue with new lifecycle
3. Create new groups that represent the actors for the lifecycle’s phases
4. Assign queue-based rights to the groups, so that only certain groups are authorized to progress the ticket to certain states. Look at the workflow description in `Projectkaartwijziging.pdf` to see what group can make the transition to what state
5. Assign real members to the groups
6. Set up mail server for the new queue (http://requesttracker.wikia.com/wiki/ManualEmailConfig)
7. Implement the creation of the secondary workflow:
  1. Load custom condition (/opt/rt4/sbin/rt-setup-database --action insert --datafile ./OnMemoCompleted.pm)
  2. Create Queue dependent custom template (see file `CreateNoMapTicketTemplate.pm`)
  3. Create Queue dependent scrip. See for the fields the file `CreateNoMapTicketScrip.pm`
