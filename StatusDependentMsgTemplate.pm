Subject: Action need for ticket: {$Ticket->Subject}

Dear {$Ticket->OwnerObj->Name || $Ticket->OwnerObj->RealName},

The ticket

  "{$Ticket->Subject()}"

has been moved to status

 "{$Ticket->Status()}"

 Please find below the description of the actions you should perform to move the ticket to its next state.

You can also look up instructions at <somewaagwikiaddress>

-------------------------------------------------------------------------
    Status-dependent Information
 -------------------------------------------------------------------------

 {
  #This template is specific to the states of the ProjectProposal queue and send messages whose content depends on the ticket status
  my $instructions_message = '';
  my $group = RT::Group->new($RT::SystemUser);
  my $secondarygroup = undef;
  my $nextstate = '';

  if ($Ticket->Status() eq "projectAwarded" ){
    $instructions_message = "Dir. Legal / NB (jij!) vraagt Accountview Code aan bij Finance MW\n";
    $group->LoadUserDefinedGroup('Finance');
    $nextstate = "codeRequested";

  } elsif ($Ticket->Status() eq "codeRequested" ){
    $instructions_message = "Finance MW (jij!) levert Accountview Code aan Dir. Legal / NB\n";
    $group->LoadUserDefinedGroup('Dir_Legal/NB');
    $nextstate = "codeProvided";

  } elsif ($Ticket->Status() eq "codeProvided" ){
    $instructions_message = "Dir. Legal / NB (jij!) maakt Memo en bijbehorende stukken (oa begroting) compleet\n";
    $group->LoadUserDefinedGroup('Finance');
    $nextstate = "memoCompleted";
    $secondarygroup = RT::Group->new($RT::SystemUser);
    $secondarygroup->LoadUserDefinedGroup('SystemAdministrators');

  } elsif ($Ticket->Status() eq "memoCompleted" ){
    $instructions_message = "Dir. Legal / NB (jij!) geeft Finance opdracht om Achievo en Accountview te regelen\n";
    $group->LoadUserDefinedGroup('Finance');
    $nextstate = "accountReady";

  } elsif ($Ticket->Status() eq "accountReady" ){
    $instructions_message = "Finance MW (jij!) leegt Projectkaart ter goedkeuring aan PM voor\n";
    $group->LoadUserDefinedGroup('ProjectManagers');
    $nextstate = "cardSent";

  } elsif ($Ticket->Status() eq "cardSent" ){
    $instructions_message = "PM (jij!) slaagt Projectkaart en aanmaak verzoek in pdf op (op BOINK?)\n";
    $group = undef;
    $nextstate = "cardHandled";

  } elsif ($Ticket->Status() eq "noMap" ){
    $instructions_message = "Dir. Legal / NB (jij!) geeft BOINK beheerder opdracht om projectmap aan te maken\n";
    $group->LoadUserDefinedGroup('ProjectManagers');
    $nextstate = "mapAvailable";

  } elsif ($Ticket->Status() eq "mapAvailable" ){
    $instructions_message = "PM (jij!) richt projectmap volgens afspraak verder in\n";
    $group = undef;
    $nextstate = "mapReady";

  } else {
    $instructions_message = "Error!!";
    $group = undef;
    $nextstate = undef;

  }


  if (defined $nextstate){
    $instructions_message .= "\nAls dit klaar is, dan aub de tiket naar status \"" . $nextstate . "\" zetten\n";
  }

  if (defined $group){
    $instructions_message .= "en owner veranderen naar (een van) de volgende user(s):\n\n";

    my $users = $group->UserMembersObj();

    while ( my $user = $users->Next ) {
      $instructions_message .= $user->Name . "\n";
    }
  }

  if ( defined $secondarygroup){
    $instructions_message .= "Er is ook een nieuwe ticket aangemaakt voor de inrichting van de projectmap\n";
    $instructions_message .= "verander zijn owner aub naar (een van) de volgende user(s):\n\n";

    my $users = $secondarygroup->UserMembersObj();

    while ( my $user = $users->Next ) {
      $instructions_message .= $user->Name . "\n";
    }
  }
  #$group->MemberEmailAddressesAsString();
  $instructions_message;
}
 -------------------------------------------------------------------------
    Common Information
 -------------------------------------------------------------------------

 Have a nice day!!!
