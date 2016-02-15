use strict;

my %states;

# Fill up our hash a bit
foreach ("codeRequested", "codeProvided", "memoCompleted",
"accountReady", "cardSent", "mapAvailable") {
  $states{$_} = 1;
};

if( exists $states{$self->TicketObj->Status()} ) {
   return 1;
}else{
  return 0;
}
