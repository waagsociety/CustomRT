use strict;
my $group = RT::Group->new($RT::SystemUser);

my $status = $self->TicketObj->Status();

if ($status eq "codeRequested" ){
  $group->LoadUserDefinedGroup('Finance');

} elsif ($status eq "codeProvided" ){
  $group->LoadUserDefinedGroup('Dir_Legal/NB');

} elsif ($status eq "memoCompleted" ){
  $group->LoadUserDefinedGroup('Finance');

} elsif ($status eq "accountReady" ){
  $group->LoadUserDefinedGroup('Finance');

} elsif ($status eq "cardSent" ){
  $group->LoadUserDefinedGroup('ProjectManagers');

} elsif ($status eq "mapAvailable" ){
  $group->LoadUserDefinedGroup('ProjectManagers');

} else {
  $group = undef;
}

if (defined $group){

  my $users = $group->UserMembersObj();

  if ( my $user = $users->Next ) {
    my ($status, $msg) = $self->TicketObj->SetOwner($user->id(),"Set");
    unless ( $status ) {
      $RT::Logger->error("Couldn't change owner: $msg");
      return 0;
    }
  }
}
return 1;
