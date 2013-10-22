package Room;

use Moose;
use namespace::autoclean;

# Rooms have a unique ID
has 'id' => (
    is          => 'rw',
    isa         => 'Str',
    required    => 1,
);
# Rooms have subscribers
has 'subscribers' => (
    is          => 'rw',
    isa         => 'Maybe[HashRef[Client]]',
    default     => sub { {} },
);
# Room has a ballpit
has 'ball_pit' => (
    is          => 'rw',
    isa         => 'Ball::Pit',
    required    => 1,
);

# Update the state of the room for a further $duration period
sub update_state {
    my ($self, $duration) = @_;

    $self->ball_pit->update($duration);
}

# Unsubscribe a client from this room
#
sub un_subscribe_client {
    my ($self, $client) = @_;
   
    if (defined $self->subscribers) {
        delete $self->subscribers->{$client->id};
    }
}

# Subscribe a client to this room
#
sub subscribe_client {
    my ($self, $client) = @_;

    $self->subscribers->{$client->id} = $client;
}

# Determine if the room has a particular client
#
sub has_client {
    my ($self, $client) = @_;
    
    if (not defined $self->subscribers) {
        return;
    }
    if (not defined $self->subscribers->{$client->id}) {
        return;
    }
    return 1;
}
# Do something for all subscribers
#
sub for_all_subscribers {
    my ($self, $sub) = @_;
   
    foreach my $client_id ( keys %{$self->subscribers} ) {
        my $client = $self->subscribers->{$client_id};
        $sub->($client);
    }
}

# Output the state of the room in a hash
#
sub to_hash {
    my ($self) = @_;

    my $hash = {
        room    => $self->id,
        ballpit => $self->ball_pit->to_hash,
    };
    return $hash;
}

__PACKAGE__->meta->make_immutable;
