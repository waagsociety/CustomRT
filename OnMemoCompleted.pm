@ScripConditions = (
   { Name           => 'On memoCompleted',
     Description   => 'When the ticket change status to memoCompleted',
     ExecModule  => 'StatusChange',
     Argument     => 'new: memoCompleted',
     ApplicableTransTypes => 'Status'
   },
 );
