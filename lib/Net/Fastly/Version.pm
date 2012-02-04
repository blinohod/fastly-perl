package Net::Fastly::Version;

use strict;
use base qw(Net::Fastly::Model);

Net::Fastly::Version->mk_accessors(qw(service_id number name active locked staging testing deployed comment));

=head1 NAME

Net::Fastly::Version - a representation of a version of a service

=head1 ACCESSORS

=head2 service_id

The id of the service this belongs to.

=head2 name

The name of this version.

=head2 active

Whether this version is active or not.

=head2 locked

Whether this version is locked or not.

=head2 staging

Whether this version is in staging or not.

=head2 testing

Whether this version is in testing or not.

=head2 deployed

Whether this version is deployed or not.

=head2 comment 

a free form comment field

=cut

sub _get_path {
    my $class   = shift;
    my $service = shift;
    my $number  = shift;
    return "/service/$service/version/$number";
}

sub _post_path {
    my $class = shift;
    my %opts  = @_;
    return "/service/".$opts{service_id}."/version";
}

sub _put_path {
    my $class = shift;
    my $obj   = shift;
    return $class->_get_path($obj->service_id, $obj->number);
}
 
=head1 METHODS

=cut

=head2 service

Get the service object for this version

=cut
sub service {
    my $self = shift;
    return $self->_fetcher->_get("Net::Fastly::Service", $self->service_id);
}

=head2 settings

Get the settings object for this version

=cut
sub settings {
    my $self = shift;
    return $self->_fetcher->get_settings($self->service_id, $self->number);
}

=head2 activate

Activate this version. This will cause it to be deployed.

=cut
sub activate {
    my $self = shift;
    die "You must be fully authed to activate a version" unless $self->_fetcher->fully_authed;
    my $hash = $self->_fetcher->client->_put($self->_put_path($self)."/activate");
    return defined $hash;
}

=head2 deactivate

Deactivate this version.

=cut
sub deactivate {
    my $self = shift;
    die "You must be fully authed to deactivate a version" unless $self->_fetcher->fully_authed;
    my $hash = $self->_fetcher->client->_put($self->_put_path($self)."/deactivate");
    return defined $hash;
}

=head2 clone

Clone this version - creates a new version which can then be modified and deployed.

=cut
sub clone {
    my $self = shift;
    die "You must be fully authed to clone a version" unless $self->_fetcher->fully_authed;
    my $hash = $self->_fetcher->client->_put($self->_put_path($self)."/clone");
    return Net::Fastly::Version->new($self->_fetcher, %$hash);
}

=head2 generated_vcl

Get the VCL object representing the VCL file generated by the system.

=cut
sub generated_vcl {
    my $self = shift;
    die "You must be fully authed to get the generated vcl for a version" unless $self->_fetcher->fully_authed;
    my $hash = $self->_fetcher->client->_get($self->_put_path($self)."/generated_vcl", @_);
    return undef unless defined $hash;
    return Net::Fastly::VCL->new($self->_fetcher,
        content    => $hash->{content},
        name       => $hash->{md5},
        version    => $hash->{version},
        service_id => $hash->{service_id},
    );
}

=head2 upload_vcl <name> <content>

Upload a raw VCL file to be used by the system.

=cut
sub upload_vcl {
    my $self    = shift;
    my $name    = shift;
    my $content = shift;
    my %params  = @_;
    die "You must be fully authed to upload vcl for a version" unless $self->_fetcher->fully_authed;
    my $hash = $self->_fetcher->client->_post($self->_put_path($self)."/vcl", name => $name, content => $content, %params);
    return undef unless defined $hash;
    return Net::Fastly::VCL->new($self->_fetcher, %$hash);
}

=head2 vcl

The uploaded vcl for this version

=cut

sub vcl {
     my $self = shift;
     my $name = shift;
     die "You must be fully authed to get the generated vcl for a version" unless $self->_fetcher->fully_authed;
     my $vcl = $self->_fetcher->get_vcl($self->service_id, $self->number, $name, @_);
     return $vcl;
}

=head2 validate

Validate the current setup.

=cut
sub validate {
    my $self = shift;
    die "You must be fully authed to validate a version" unless $self->_fetcher->fully_authed;
    my $hash = $self->_fetcher->client->_get($self->_put_path($self)."/validate");
    return defined $hash;
}

1;
