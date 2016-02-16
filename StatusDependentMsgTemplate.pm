Subject: Action need for ticket: {$Ticket->Subject}

Dear {$Ticket->OwnerObj->Name || $Ticket->OwnerObj->RealName},

The ticket

  "{$Ticket->Subject()}"
  URL: {RT->Config->Get('WebURL')}Ticket/Display.html?id={$Ticket->id}

has been moved to status

 "{$Ticket->Status()}"

 Please find below the description of the actions you should perform to move the ticket to its next state.

You can also look up instructions at {RT->Config->Get('WebURL')}Articles/Article/Display.html?id=4

-------------------------------------------------------------------------
    Status-dependent Information
 -------------------------------------------------------------------------

 {
  my $instructions_message = '';
  my $group = RT::Group->new($RT::SystemUser);
  my $secondarygroup = undef;
  my $nextstate = '';
  my $status = $Ticket->Status();

  if ($status eq "projectAwarded" ){
    $instructions_message = "Dir. Legal / NB (jij!) vraagt Accountview Code aan bij Finance MW\n";
    $group->LoadUserDefinedGroup('Finance');
    $nextstate = "codeRequested";

  } elsif ($status eq "codeRequested" ){
    $instructions_message = "Finance MW (jij!) levert Accountview Code aan Dir. Legal / NB\n";
    $group->LoadUserDefinedGroup('Dir_Legal/NB');
    $nextstate = "codeProvided";

  } elsif ($status eq "codeProvided" ){
    $instructions_message = "Dir. Legal / NB (jij!) maakt Memo en bijbehorende stukken (oa begroting) compleet\n";
    $group->LoadUserDefinedGroup('Finance');
    $nextstate = "memoCompleted";
    $secondarygroup = RT::Group->new($RT::SystemUser);
    $secondarygroup->LoadUserDefinedGroup('SystemAdministrators');

  } elsif ($status eq "memoCompleted" ){
    $instructions_message = "Dir. Legal / NB (jij!) geeft Finance opdracht om Achievo en Accountview te regelen\n";
    $group->LoadUserDefinedGroup('Finance');
    $nextstate = "accountReady";

  } elsif ($status eq "accountReady" ){
    $instructions_message = "Finance MW (jij!) leegt Projectkaart ter goedkeuring aan PM voor\n";
    $group->LoadUserDefinedGroup('ProjectManagers');
    $nextstate = "cardSent";

  } elsif ($status eq "cardSent" ){
    $instructions_message = "PM (jij!) slaagt Projectkaart en aanmaak verzoek in pdf op (op BOINK?)\n";
    $group = undef;
    $nextstate = "cardHandled";

  } elsif ($status eq "noMap" ){
    $instructions_message = "BOINK beheerder (jij!) krijgt de opdracht om projectmap aan te maken\n";
    $group->LoadUserDefinedGroup('ProjectManagers');
    $nextstate = "mapAvailable";

  } elsif ($status eq "mapAvailable" ){
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
    $instructions_message .= "De owner zal automatish veranderen naar de volgende user (naar de eerste in geval van meerdere users):\n\n";

    my $users = $group->UserMembersObj();

    while ( my $user = $users->Next ) {
      $instructions_message .= $user->Name . "\n";
    }

    $instructions_message .= "Als de owner niet de eerste van de lijst moet zijn, dan aub de juste owner handmatig zetten nadat de status is veranderd.\n";
  }

  if ( defined $secondarygroup){
    $instructions_message .= "Er is ook een nieuwe ticket aangemaakt voor de inrichting van de projectmap\n";
    $instructions_message .= "De owner is de volgende user (de eerste in geval van meerdere users):\n\n";

    my $users = $secondarygroup->UserMembersObj();

    while ( my $user = $users->Next ) {
      $instructions_message .= $user->Name . "\n";
    }
    $instructions_message .= "Als de owner niet de eerste van de lijst moet zijn, dan aub de juste owner handmatig zetten.\n";
  }
  #$group->MemberEmailAddressesAsString();
  $instructions_message;
}
 -------------------------------------------------------------------------
    Common Information
 -------------------------------------------------------------------------

 Have a nice day!!!
