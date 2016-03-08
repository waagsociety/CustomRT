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
    $instructions_message = "Dir. Legal/NB vraagt Accountview Code aan bij Finance en richt gezamenlijk Achievo en Accountview in.\n" .
    "Dan draagt hij Memo over bestaande uit:\n" .
    " -Acc. View Budget screenshot;\n" .
    " -Achievo screenshot;\n" .
    " -Beschikking/contract;\n" .
    " -Voorstel/o erte;\n" .
    " -Begroting .\n";
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

  } elsif ($status eq "memoCompleted" ){
    $instructions_message = "Dir. Legal / NB (jij!) geeft Finance opdracht om Achievo en Accountview te regelen\n";
    $group->LoadUserDefinedGroup('Finance');
    $nextstate = "accountReady";
    $secondarygroup = RT::Group->new($RT::SystemUser);
    $secondarygroup->LoadUserDefinedGroup('ProjectInrichtingBoink');

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


  if ($status eq "memoCompleted"){
    if (defined $nextstate){
      $instructions_message .= "\nAls dit klaar is, dan aub de tiket naar status \"" . $nextstate . "\" zetten\n";
    }

    $instructions_message .= "De owner zal de volgende user (of de eerste in geval van meerdere users) zijn (waarschijndelijk dat ben jij):\n\n";

    my $users = $group->UserMembersObj();

    while ( my $user = $users->Next ) {
      $instructions_message .= $user->Name . "\n";
    }

    $instructions_message .= "\nAls de owner niet de eerste van de lijst moet zijn, dan aub de juste owner handmatig zetten nadat de status is veranderd.\n";

    $instructions_message .= "\nAls jij de volgende owner bent, dan aub ook de volgende doen:\n\n";

    $instructions_message .= "Finance MW (jij!) leegt Projectkaart ter goedkeuring aan PM voor\n";
    $group->LoadUserDefinedGroup('ProjectManagers');
    $nextstate = "cardSent";

    $instructions_message .= "\nAls dit klaar is, dan aub de tiket naar status \"" . $nextstate . "\" zetten\n";

    $instructions_message .= "De owner zal automatish veranderen naar de volgende user (naar de eerste in geval van meerdere users):\n\n";

    $users = $group->UserMembersObj();

    while ( my $user = $users->Next ) {
      $instructions_message .= $user->Name . "\n";
    }

    $instructions_message .= "\nAls de owner niet de eerste van de lijst moet zijn, dan aub de juste owner handmatig zetten nadat de status is veranderd.\n";

    if ( defined $secondarygroup){
      $instructions_message .= "\nEr is ook een nieuwe ticket aangemaakt voor de inrichting van de projectmap:\n\n";

      $instructions_message .= RT::Config->Get('WebURL') . "/Search/Results.html?Query=DependedOnBy%20%3D%20" . $Ticket->id . "\n";

      #my $DepOnBy = $Ticket->DependedOnBy;
      #my $links = RT::Links->new($RT::SystemUser);
      #$links->LimitReferredToBy($Ticket->id);
      #while( my $l = $links->Next ) {
      #  $instructions_message .= $l->id;
      #}

      $instructions_message .= "\nDe owner is de volgende user (de eerste in geval van meerdere users):\n\n";

      my $users = $secondarygroup->UserMembersObj();

      while ( my $user = $users->Next ) {
        $instructions_message .= $user->Name . "\n";
      }
      $instructions_message .= "\nAls de owner niet de eerste van de lijst moet zijn, dan aub de juste owner handmatig zetten.\n";
    }
  }else{

    if (defined $nextstate){
      $instructions_message .= "\nAls dit klaar is, dan aub de tiket naar status \"" . $nextstate . "\" zetten\n";
    }

    if (defined $group){
      $instructions_message .= "De owner zal automatish veranderen naar de volgende user (naar de eerste in geval van meerdere users):\n\n";

      my $users = $group->UserMembersObj();

      while ( my $user = $users->Next ) {
        $instructions_message .= $user->Name . "\n";
      }

      $instructions_message .= "\nAls de owner niet de eerste van de lijst moet zijn, dan aub de juste owner handmatig zetten nadat de status is veranderd.\n";
    }
  }

  #$group->MemberEmailAddressesAsString();
  $instructions_message;
}
 -------------------------------------------------------------------------
    Common Information
 -------------------------------------------------------------------------

 Have a nice day!!!
