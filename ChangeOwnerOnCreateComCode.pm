use strict;
my $group = RT::Group->new($RT::SystemUser);

my $status = $self->TicketObj->Status();

if ($status eq "projectAwarded" ){
  $group->LoadUserDefinedGroup('Dir_Legal/NB');

} elsif ($status eq "noMap" ){
  $group->LoadUserDefinedGroup('ProjectInrichtingBoink');

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
