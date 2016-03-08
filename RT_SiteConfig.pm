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
            initial         => [ 'projectAwarded', 'folderRequest' ],
            active          => [ 'projectSetUp', 'projectAccept', 'folderSetUp' ],
            inactive        => [ 'projectHandled', 'folderHandled', 'suspended', 'deleted' ],
            # Default order statuses for certain actions
            defaults => {
                on_create => 'projectAwarded',
            },
            # Status change restrictions
            transitions => {
                ''          => [qw(projectAwarded folderRequest)],
                projectAwarded     => [qw(projectSetUp suspended deleted)],
                projectSetUp  => [qw(projectAccept suspended deleted)],
                projectAccept    => [qw(projectHandled suspended deleted)],
                folderRequest    => [qw(folderSetUp suspended deleted)],
                folderSetUp   => [qw(folderHandled suspended deleted)],
                suspended     => [qw(projectAwarded projectSetUp projectAccept projectHandled folderRequest folderSetUp folderHandled)],
                deleted     => [qw(projectAwarded projectSetUp projectAccept projectHandled folderRequest folderSetUp folderHandled)],
            },
            # Rights for different actions
            rights => {
                # These rights are in the default lifecycle
                '* -> deleted'  => 'DeleteTicket',
                '* -> suspended'  => 'SuspendTicket',
                'projectAwarded -> projectSetUp' => 'RequestCode',
                'projectSetUp -> projectAccept' => 'AcceptCard',
                'projectAccept -> projectHandled' => 'SaveMemo',
                'folderRequest -> folderSetUp' => 'CreateFolder',
                'folderSetUp -> folderHandled' => 'PrepareFolder',
            },
            # Actions for the web UI
            actions => [
                'projectAwarded -> projectSetUp' => {
                    label  => 'AccountView, Achievo and Memo are ready',
                    update => 'Comment',
                },
                'projectSetUp -> projectAccept' => {
                    label  => 'Project Card is accepted',
                    update => 'Comment',
                },
                'projectAccept -> projectHandled' => {
                    label  => 'Memo has been saved to BOINK folder',
                    update => 'Comment',
                },
                'folderRequest -> folderSetUp' => {
                    label  => 'Folder on BOINK has been created',
                    update => 'Comment',
                },
                'folderSetUp -> folderHandled' => {
                    label  => 'Folder on BOINK has been prepared',
                    update => 'Comment',
                },
            ],
        },
        # 'projectModify' shows up as a lifecycle choice when you create a new
        # queue or modify an existing one
        projectModify => {
            # All the appropriate order statuses
            initial         => [ 'changeRequest' ],
            active          => [ 'changeSetUp', 'changeAccept', 'changeLegal' ],
            inactive        => [ 'changeHandled', 'suspended', 'deleted' ],
            # Default order statuses for certain actions
            defaults => {
                on_create => 'changeRequest',
            },
            # Status change restrictions
            transitions => {
                ''          => [qw(changeRequest)],
                changeRequest     => [qw(changeSetUp suspended deleted)],
                changeSetUp  => [qw(changeAccept suspended deleted)],
                changeAccept    => [qw(changeLegal suspended deleted)],
                changeLegal   => [qw(changeHandled suspended deleted)],
                suspended     => [qw(changeRequest changeSetUp changeAccept changeLegal changeHandled)],
                deleted     => [qw(changeRequest changeSetUp changeAccept changeLegal changeHandled)],
            },
            # Rights for different actions
            rights => {
                # These rights are in the default lifecycle
                '* -> deleted'  => 'DeleteTicket',
                '* -> suspended'  => 'SuspendTicket',
                'changeRequest -> changeSetUp' => 'DescribeChange',
                'changeSetUp -> changeAccept' => 'AcceptModifiedCard',
                'changeAccept -> changeLegal' => 'HandleLegal',
                'changeLegal -> changeHandled' => 'SaveModifiedMemo',
            },
            # Actions for the web UI
            actions => [
                'changeRequest -> changeSetUp' => {
                    label  => 'Change has been described in Memo',
                    update => 'Comment',
                },
                'changeSetUp -> changeAccept' => {
                    label  => 'Project card has been accepted',
                    update => 'Comment',
                },
                'changeAccept -> changeLegal' => {
                    label  => 'Legal issues have been handled',
                    update => 'Comment',
                },
                'changeLegal -> changeHandled' => {
                    label  => 'Memo has been saved in BOINK',
                    update => 'Comment',
                },
            ],
        },
        # Status mapping different different lifecycles
        __maps__ => {
            'default -> projectStart' => {
                'new'      => 'projectAwarded',
                'open'     => 'projectSetUp',
                'stalled'  => 'suspended',
                'resolved' => 'projectHandled',
                'rejected' => 'suspended',
                'deleted'  => 'deleted',
            },
            'projectStart -> default' => {
                'projectAwarded'    => 'new',
                'folderRequest'    => 'new',
                'projectSetUp' => 'open',
                'projectHandled'  => 'resolved',
                'projectAccept'    => 'open',
                'folderSetUp'   => 'open',
                'folderHandled'    => 'resolved',
                'suspended'   => 'rejected',
                'deleted'    => 'deleted',
            },
            'default -> projectModify' => {
                'new'      => 'changeRequest',
                'open'     => 'changeSetUp',
                'stalled'  => 'suspended',
                'resolved' => 'changeHandled',
                'rejected' => 'suspended',
                'deleted'  => 'deleted',
            },
            'projectModify -> default' => {
                'changeRequest'    => 'new',
                'changeSetUp' => 'open',
                'changeHandled'  => 'resolved',
                'changeAccept'    => 'open',
                'changeLegal'   => 'open',
                'suspended'   => 'rejected',
                'deleted'    => 'deleted',
            },
        },
    );


Set( @CustomFieldValuesSources, "RT::CustomFieldValues::ProjectManagers" );

# You must install Plugins on your own, this is only an example
# of the correct syntax to use when activating them:
#     Plugin( "RT::Extension::SLA" );
#     Plugin( "RT::Authen::ExternalAuth" );

1;
