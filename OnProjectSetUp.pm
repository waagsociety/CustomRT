@ScripConditions = (
   { Name           => 'On projectSetUp',
     Description   => 'When the ticket change status to projectSetUp',
     ExecModule  => 'StatusChange',
     Argument     => 'new: projectSetUp',
     ApplicableTransTypes => 'Status'
   },
 );
