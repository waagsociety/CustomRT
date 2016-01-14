# Any configuration directives you include  here will override 
# RT's default configuration file, RT_Config.pm
#
# To include a directive here, just copy the equivalent statement
# from RT_Config.pm and change the value. We've included a single
# sample value below.
#
# This file is actually a perl module, so you can include valid
# perl code, as well.
#
# The converse is also true, if this file isn't valid perl, you're
# going to run into trouble. To check your SiteConfig file, use
# this command:
#
#   perl -c /path/to/your/etc/RT_SiteConfig.pm
#
# You must restart your webserver after making changes to this file.

Set( $rtname, 'rt.waag.org');
Set($Organization, "rt.waag.org");
Set($WebDomain, 'rt.waag.org');

Set(%Lifecycles,
        # 'projectStart' shows up as a lifecycle choice when you create a new
        # queue or modify an existing one
        projectStart => {
            # All the appropriate order statuses
            initial         => [ 'projectAwarded', 'noMap' ],
            active          => [ 'codeRequested', 'codeProvided', 'memoCompleted', 'accountReady', 'cardSent', 'mapAvailable' ],
            inactive        => [ 'cardHandled', 'mapReady', 'suspended', 'deleted' ],
            # Default order statuses for certain actions
            defaults => {
                on_create => 'projectAwarded',
            },
            # Status change restrictions
            transitions => {
                ''          => [qw(projectAwarded noMap)],
                projectAwarded     => [qw(codeRequested suspended deleted)],
                codeRequested  => [qw(codeProvided suspended deleted)],
                codeProvided    => [qw(memoCompleted suspended deleted)],
                memoCompleted   => [qw(accountReady suspended deleted)],
                accountReady    => [qw(cardSent suspended deleted)],
                cardSent    => [qw(cardHandled suspended deleted)],
                noMap    => [qw(mapAvailable suspended deleted)],
                mapAvailable    => [qw(mapReady suspended deleted)],
                suspended     => [qw(projectAwarded codeRequested codeProvided memoCompleted accountReady cardSent cardHandled mapAvailable mapReady)],
                deleted     => [qw(projectAwarded codeRequested codeProvided memoCompleted accountReady cardSent cardHandled mapAvailable mapReady)],
            },
            # Rights for different actions
            rights => {
                # These rights are in the default lifecycle
                '* -> deleted'  => 'DeleteTicket',
                '* -> suspended'  => 'SuspendTicket',
                'projectAwarded -> codeRequested' => 'RequestCode', 
                'codeRequested -> codeProvided' => 'ProvideCode', 
                'codeProvided -> memoCompleted' => 'CompleteMemo', 
                'memoCompleted -> accountReady' => 'CreateAccount', 
                'accountReady -> cardSent' => 'SendCard', 
                'cardSent -> cardHandled' => 'BlessCard', 
                'noMap -> mapAvailable' => 'MakeMap', 
                'mapAvailable -> mapReady' => 'OrganizeMap', 
            },
            # Actions for the web UI
            actions => [
                'projectAwarded -> codeRequested' => {
                    label  => 'AccountView Code has been requested',
                    update => 'Comment',
                },
                'codeRequested -> codeProvided' => {
                    label  => 'AccountView Code has been provided',
                    update => 'Comment',
                },
                'codeProvided -> memoCompleted' => {
                    label  => 'Memo has been completed',
                    update => 'Comment',
                },
                'memoCompleted -> accountReady' => {
                    label  => 'Account has been created',
                    update => 'Comment',
                },
                'accountReady -> cardSent' => { 
                    label  => 'Card has been sent',
                    update => 'Comment',
                },
                'noMap -> mapAvailable' => {
                    label  => ' Map has been made',
                    update => 'Comment',
                },
                'mapAvailable -> mapReady' => {
                    label  => 'Map has been organized',
                    update => 'Comment',
                },
                'cardSent -> cardHandled' => {
                    label  => 'Card has been approved',
                    update => 'Respond',
                },
            ],
        },
        # Status mapping different different lifecycles
        __maps__ => {
            'default -> projectStart' => {
                'new'      => 'projectAwarded',
                'open'     => 'codeRequested',
                'stalled'  => 'suspended',
                'resolved' => 'cardHandled',
                'rejected' => 'suspended',
                'deleted'  => 'deleted',
            },
            'projectStart -> default' => {
                'projectAwarded'    => 'new',
                'noMap'    => 'new',
                'codeRequested' => 'open',
                'cardHandled'  => 'resolved',
                'codeProvided'    => 'open',
                'memoCompleted'   => 'open',
                'accountReady'    => 'open',
                'mapAvailable'    => 'open',
                'mapReady'    => 'open',
                'cardSent'    => 'open',
                'suspended'   => 'rejected',
                'deleted'    => 'deleted',
            },
        },
    );

# You must install Plugins on your own, this is only an example
# of the correct syntax to use when activating them:
#     Plugin( "RT::Extension::SLA" );
#     Plugin( "RT::Authen::ExternalAuth" );

1;
