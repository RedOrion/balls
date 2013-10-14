package WS::Root;

use Moose;
use Mojo::IOLoop;

use namespace::autoclean;

extends "WS";

has 'rooms' => (
    is          => 'rw',
    isa         => 'HashRef[Int]',
    default     => sub { {} },
);

sub BUILD {
    my ($self) = @_;

    Mojo::IOLoop->singleton->recurring(1 => sub {
        foreach my $rm (keys %{$self->rooms}) {
            $self->rooms->{$rm}++;
        }
        $self->broadcast({
            type    => 'rooms',
            data    => $self->rooms,
        });
        $self->log->debug('Sending to all players');
    });
}

sub room {
    my ($self, $data) = @_;

    my $room_number = $data->{number};
    if (not defined $self->rooms->{$room_number}) {
        $self->rooms->{$room_number} = 0;
    }
}

__PACKAGE__->meta->make_immutable;
