use strict;

my %states;

# Fill up our hash a bit
foreach ("projectAwarded", "noMap") {
  $states{$_} = 1;
};

if( exists $states{$self->TicketObj->Status()} ) {
   return 1;
}else{
  return 0;
}
