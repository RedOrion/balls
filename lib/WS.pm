package WS;

use Moose;
use Mojo::JSON;

use namespace::autoclean;

has 'log' => (
    is          => 'rw',
    required    => 1,
);

has 'clients' => (
    is          => 'rw',
    isa         => 'HashRef[Client]',
    default     => sub { {} },
);

# Send a message to everyone, (but can 'exclude' oneself)
#
sub broadcast {
    my ($self, $args) = @_;

    my $exclude = $args->{exclude};
    my $type    = $args->{type};
    my $data    = $args->{data};
    my $msg = {
        type    => $args->{type},
        data    => $args->{data},
    };
    my $json = Mojo::JSON->new->encode($msg);

    CLIENT:
    foreach my $cid (keys %{$self->clients}) {
        my $client = $self->clients->{$cid};
        next CLIENT if $exclude and $exclude == $client;

        $client->tx->send($json);
    }
}

sub add_client {
    my ($self, $connection, $client) = @_;

    $self->clients->{$client->id} = $client;

    $self->log->debug('Added a new client. Notify all other clients');

    $self->broadcast({
        type    => 'new_client',
        data    => $client->as_hash,
        exclude => $client,
    });

    # In the event of a message
    $connection->on(message => 
        sub {
            my ($this, $json_msg) = @_;

            my $json = Mojo::JSON->new;
            $self->log->debug("Message [$json_msg] received.");
            my $msg = $json->decode($json_msg);
            if ($json->error) {
                $self->log->debug("JSON Error [".$json->error."]");
                return;
            }
            return unless $msg;
            my $type = $msg->{type};
            if (not $type) {
                $self->log->debug("JSON Error [No type]");
                return;
            }
            if (not $self->can($type)) {
                $self->log->debug("No method for type [$type]");
                return;
            }
            $self->$type($msg->{data});
        }
    );

    # In the event of a finish
    $connection->on(finish =>
        sub {
            my ($this) = @_;

            $self->broadcast({
                type    => 'old_client',
                data    => $client->as_hash,
                exclude  => $client,
            });
            delete $self->clients->{$client->id};
            $self->log->debug("Client [".$client->id."] disconnected.");
        }
    );
}

__PACKAGE__->meta->make_immutable;
