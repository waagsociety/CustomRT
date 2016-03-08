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
    " -Voorstel/offerte;\n" .
    " -Begroting .\n";
    $group->LoadUserDefinedGroup('ProjectManagers');
    $nextstate = "projectSetUp";

  } elsif ($status eq "projectSetUp" ){
    $instructions_message = "Projectkaart wordt door desbetreffende PM geaccepteerd\n";
    $group->LoadUserDefinedGroup('ProjectManagers');
    $nextstate = "projectAccept";
    $secondarygroup = RT::Group->new($RT::SystemUser);
    $secondarygroup->LoadUserDefinedGroup('ProjectInrichtingBoink');

  } elsif ($status eq "projectAccept" ){
    $instructions_message = "Memo wordt in pdf opgeslagen in projectmap (op BOINK) door PM\n";
    $group = undef;
    $nextstate = "projectHandled";

  } elsif ($status eq "folderRequest" ){
    $instructions_message = "BOINK beheerder ontvangt opdracht om projectmap aan te maken en voert uit\n";
    $group->LoadUserDefinedGroup('ProjectManagers');
    $nextstate = "folderSetUp";

  } elsif ($status eq "folderSetUp" ){
    $instructions_message = "PM richt projectmap volgens afspraak verder in.\n";
    $group = undef;
    $nextstate = "folderHandled";

  } elsif ($status eq "changeRequest" ){
    $instructions_message = "Dir. Legal/NB beschrijft wijziging in Memo en zorgt dat Finance Achievo & Account- view inregelt.\n" .
    "(Dir. Legal/NB noteert eventueel op de projectkaart dat juridische afhandling nog onafgerond is).\n";
    $group->LoadUserDefinedGroup('ProjectManagers');
    $nextstate = "changeSetUp";

  } elsif ($status eq "changeSetUp" ){
    $instructions_message = "Projectkaart wordt (ovv. afhandling legal) door desbetreffende PM geaccepteerd.\n" .
    $group->LoadUserDefinedGroup('Dir_Legal/NB');
    $nextstate = "changeAccept";

  } elsif ($status eq "changeAccept" ){
    $instructions_message = "Dir. Legal/NB handelt i.s.m. PM eventuele overgebleven juridische verplichtingen / eventuele conditions for request af.\n" .
    "Eventueel leidt dit tot vernieuwde memo.\n";
    $group->LoadUserDefinedGroup('ProjectManagers');
    $nextstate = "changeLegal";

  } elsif ($status eq "changeLegal" ){
    $instructions_message = "Laatste Memo wordt in pdf opgeslagen in projectmap (op BOINK?) door PM.\n";
    $group = undef;
    $nextstate = "changeHandled";

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
    }


  #$group->MemberEmailAddressesAsString();
  $instructions_message;
}
 -------------------------------------------------------------------------
    Common Information
 -------------------------------------------------------------------------

 Have a nice day!!!
