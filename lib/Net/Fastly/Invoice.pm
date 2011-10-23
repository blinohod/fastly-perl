package Net::Fastly::Invoice;

use strict;
use base qw(Net::Fastly::Model);

Net::Fastly::Invoice->mk_accessors(qw(service_id service_name start_time end_time total regions));

=head1 NAME

Net::Fastly::Invoice - - a representation of a Fastly monthly invoice

=head1 ACCESSORS

=head2 service_id

The id of the service this invoice is for

=head2 service_name

The id of the service this invoice is for

=head2 start_time

The earliest date and time this invoice covers

=head2 end_time

The latest date and time this invoice covers

=head2 total

The total for this invoice in US dollars

=head2 regions

A hash reference with all the different regions and their subtotals

=cut

sub _get_path {
    my $class = shift;
    my %opts  = @_;
    
    my $url  = "/billing";
    if ($opts{service}) {
        $url .= "/service/".$opts{service};
    }
    if ($opts{year} && $opts{month}) {
        $url .= "/year/".$opts{year}."/month/".$opts{mon};
    }
    return $url;
}

sub _list_path   { shift->_get_path(@_) }
sub _post_path   { die "You can't POST to an invoice"   }
sub _put_path    { die "You can't PUT to an invoice"    }
sub _delete_path { die "You can't DELETE to an invoice" }

sub save   { die "You can't save an invoice" }
sub delete { die "You can't save an invoice" }

package Net::Fastly;

sub list_invoices {
    my $self  = shift;
    my $year  = shift;
    my $month = shift;
    my %opts  = ();
    if ($year && $month) {
        $opts{year}  = $year;
        $opts{month} = $month;
    }
    return $self->_list("Net::Fastly::Invoice", %opts);
}

1;