use strict;
my $group = RT::Group->new($RT::SystemUser);

my $status = $self->TicketObj->Status();

my $CFName = 'DesignatedPM';

my $QueueObj = $self->TicketObj->QueueObj;
my $CFObj = RT::CustomField->new( $QueueObj->CurrentUser );
$CFObj->LoadByNameAndQueue( Name => $CFName, Queue => $QueueObj->id );

my $pm = $self->TicketObj->FirstCustomFieldValue( $CFObj->id);

if ($status eq "projectSetUp" ){
  if (defined $pm){
    $group = undef;
  }else{
    $group->LoadUserDefinedGroup('ProjectManagers');
  }

} elsif ($status eq "projectAccept" ){
  if (defined $pm){
    $group = undef;
  }else{
    $group->LoadUserDefinedGroup('ProjectManagers');
  }

} elsif ($status eq "folderSetUp" ){
  if (defined $pm){
    $group = undef;
  }else{
    $group->LoadUserDefinedGroup('ProjectManagers');
  }

} elsif ($status eq "changeSetUp" ){
  if (defined $pm){
    $group = undef;
  }else{
    $group->LoadUserDefinedGroup('ProjectManagers');
  }

} elsif ($status eq "changeAccept" ){
  $group->LoadUserDefinedGroup('Dir_Legal/NB');

} elsif ($status eq "changeLegal" ){
  if (defined $pm){
    $group = undef;
  }else{
    $group->LoadUserDefinedGroup('ProjectManagers');
  }

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
} elsif (defined $pm){
  my $user = RT::User->new( $RT::SystemUser );

  $user->Load( $pm );

  my ($status, $msg) = $self->TicketObj->SetOwner($user->id(),"Set");
  unless ( $status ) {
    $RT::Logger->error("Couldn't change owner: $msg");
    return 0;
  }
}
return 1;
