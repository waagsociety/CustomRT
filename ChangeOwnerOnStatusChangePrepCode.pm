use strict;

my %states;

# Fill up our hash a bit
foreach ("projectSetUp", "projectAccept", "folderSetUp", "changeSetUp", "changeAccept", "changeLegal") {
  $states{$_} = 1;
};

if( exists $states{$self->TicketObj->Status()} ) {
   return 1;
}else{
  return 0;
}
