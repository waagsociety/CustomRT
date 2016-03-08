# Populate Project Manager list

package RT::CustomFieldValues::ProjectManagers;

use strict;
use warnings;

use base qw(RT::CustomFieldValues::External);

=head1 NAME

RT::CustomFieldValues::ProjectManagers - Provide RT's Project Managers members as a dynamic list of CF values

=head1 SYNOPSIS

To use as a source of CF values, add the following to your F<RT_SiteConfig.pm>
and restart RT.

    # In RT_SiteConfig.pm
    Set( @CustomFieldValuesSources, "RT::CustomFieldValues::ProjectManagers" );

Then visit the modify CF page in the RT admin configuration.

=head1 METHODS

Most methods are inherited from L<RT::CustomFieldValues::External>, except the
ones below.

=head2 SourceDescription

Returns a brief string describing this data source.

=cut

sub SourceDescription {
    return 'List Project Managers members';
}

=head2 ExternalValues

Returns an arrayref containing a hashref for each possible value in this data
source, where the value name is the project manager username.

=cut

sub ExternalValues {
    my $self = shift;

    my @res;
    my $i = 0;
    my $group = RT::Group->new($RT::SystemUser);
    $group->LoadUserDefinedGroup('ProjectManagers');
    my $users = $group->UserMembersObj();
    while ( my $user = $users->Next ) {
        push @res, {
            name        => $user->Name,
            description => $user->RealName,
            sortorder   => $i++,
        };
    }
    return \@res;
}

RT::Base->_ImportOverlays();

1;
