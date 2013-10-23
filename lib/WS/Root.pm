package WS::Root;

use Moose;
use Mojo::IOLoop;
use Data::Dumper;
use Room;
use Ball::Pit;

use namespace::autoclean;

extends "WS";

has 'rooms' => (
    is          => 'rw',
    isa         => 'HashRef[Room]',
    default     => sub { {} },
);

sub BUILD {
    my ($self) = @_;

    # every second, update the room states (compute the future state of the balls)
    #
    Mojo::IOLoop->singleton->recurring(2 => sub {
        foreach my $room_id (keys %{$self->rooms}) {
            # Update the state of the room to at least now + 5 seconds
            #
            my $room = $self->rooms->{$room_id};
            $self->log->debug("ROOM - $room_id [$room]");
            $room->update_state(2000);

            # Send the room status to each of the subscribed clients
            #
            my $json = $self->prepare_json({
                type    => 'room_data',
                data    => $room->to_hash,
            });
            $room->for_all_subscribers( sub {
                my $client = shift;
                $client->send($json);
            });
        }
        # TODO: If there are no subscribers, close the room down?
        #
        #
        #
        #
    });
}


# A Data Message 'room' asking for a client to register in a room
#
sub room {
    my ($self, $client, $data) = @_;

    my $room_number = $data->{number};
    my $room = $self->rooms->{$room_number};
    if (not defined $room) {
        # Create a 'room' containing a ballpit with balls
        #
        my $ball_pit = Ball::Pit->new;
        $room = Room->new({
            id          => $room_number,
            ball_pit    => $ball_pit,
        });
        $self->rooms->{$room_number} = $room;
    }
    # If the client is not yet registered with the room
    # 
    if (not $room->has_client($client)) {
        # unsubscribe the client from all (other) rooms
        $self->unsub_client($client);

        # Subscribe the client to this room
        $room->subscribe_client($client);
    }
}

# Remove a client from all currently subscribed rooms
#
sub unsub_client {
    my ($self, $client) = @_;

    # Remove the client from all subscribed rooms
    my $rooms = $self->rooms;
    foreach my $room_id (keys %$rooms ) {
        $rooms->{$room_id}->un_subscribe_client($client);
    }
}

# When the client is done, unsubscribe from all rooms
# 
after 'finish' => sub {
    my ($self, $client) = @_;

    $self->unsub_client($client);   
};


__PACKAGE__->meta->make_immutable;
