package Room;

use Moose;
use namespace::autoclean;

# Rooms have a unique ID
has 'id' => (
    is          => 'rw',
    isa         => 'Int',
    required    => 1,
);
# Rooms have subscribers
has 'subscribers' => (
    is          => 'rw',
    isa         => 'ArrayRef[Client]',
    default     => sub { () },
);
# Room has a ballpit
has 'ball_pit' => (
    is          => 'rw',
    isa         => 'Ball::Pit',
    required    => 1,
);

# Update the state of the room to at least time now + $to_time
sub update_state {
    my ($self, $to_time) = @_;

}

# Unsubscribe a client from this room
#
sub un_subscribe_client {
    my ($self, $client) = @_;
   
    delete $self->subscribers->{$client->id};
}

# Subscribe a client to this room
#
sub subscribe_client {
    my ($self, $client) = @_;

    $self->subscribers->{$client->id} = $client;
}

__PACKAGE__->meta->make_immutable;
