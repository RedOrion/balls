#!/usr/bin/perl

use FindBin;

use Mojolicious::Lite;
use Mojo::JSON;
use Mojo::ByteStream;
use Mojo::IOLoop;

#my $ioloop = Mojo::IOLoop->singleton;

my $players = {};
my $rooms   = {};
my $controller;


# One second room timer
# Once a room is created, it counts forever
Mojo::IOLoop->recurring(1 => sub {
    foreach my $rm (keys %$rooms) {
        $rooms->{$rm}++;
    }
    if ($controller) {
        _send_message_to_all($controller, {
            type    => 'rooms',
            %$rooms
        });
        app->log->debug('Sending to all players');
    }
});


# The websocket URL
#
websocket '/' => sub {
    my ($self) = @_;

    my $tx = $self->tx;
    Mojo::IOLoop->stream($tx->connection)->timeout(0);

    app->log->debug('Player connected');
    $controller = $self;

    my $cid = _id($self);
    $players->{$cid}{tx} = $tx;
    my $player = $players->{$cid};

    app->log->debug('Notify other players about a new player');
    _send_message_to_others($self, {
            type    => 'new_player',
            _player_info($self, $cid),
        }
    );

    $self->on(message =>
        sub {
            my ($self, $message) = @_;

            my $json = Mojo::JSON->new;
            app->log->debug("Message [$message]");

            # Very basic checks. Just ignore errors.
            #
            $message = $json->decode($message);
            return unless $message || $json->error;

            my $type = $message->{type};
            return unless $type;

            if ($type eq 'room') {
                my $room_number = $message->{number};
                if (not defined $rooms->{$room_number}) {
                    $rooms->{$room_number} = 0;
                }
            }
        }
    );

    $self->on( finish =>
        sub {
            _send_message_to_others($self, {
                type    => 'old_player',
                id      => $cid,
            });
            app->log->debug('Player disconnected');
            delete $players->{$cid};
        }
    );
};

# get the HTML
#
get '/' => 'index';



# Get a unique ID for this user
#
sub _id {
    my ($self) = @_;

    my $tx = $self->tx;
#    app->log->debug("got ID [$tx]");

    return "$tx";
}

# Get player info for a player
#
sub _player_info {
    my ($self, $cid) = @_;

    my $player = $players->{$cid};
    return unless $player;

    return (
        id    => $cid,
    );
}

# Get info for all players
#
sub _players {
    my ($self) = @_;

    #return [] unless keys %$players;

    return [map { { _player_info($_) } } keys %$players];
}

# Encode a data structure in JSON
#
sub _message_to_json {
    my %message = @_;

    my $json = Mojo::JSON->new;
    $json = $json->encode({%message});
    app->log->debug($json);
    return $json;
}

# Send a message
#
sub _send_message {
    my ($self, $msg) = @_;

    $self->send(_message_to_json(%$msg));
}

# Send a message to everyone except oneself
#
sub _send_message_to_others {
    my ($self, $msg) = @_;

    my $id = _id($self);

    my $message = _message_to_json(%$msg);

    foreach my $cid (keys %$players) {
        next if $cid eq $id;

        my $player = $players->{$cid};

        # If player is connected
        if ($player && $player->{tx}) {
            $player->{tx}->send($message);
        }

        # Cleanup disconnected player
        else {
            delete $players->{$cid};
        }
    }
}

# Send a message to everyone, including oneself
#
sub _send_message_to_all {
    my ($self, $msg) = @_;
    _send_message_to_others($self, $msg);
    _send_message($self, $msg);
}

print "Remember, you need to also run 'sudo perl mojo/examples/flash-policy-server.pl' as root for this to work...\n";

app->start;

__DATA__

@@ index.html.ep
% my $url = $self->req->url->to_abs->scheme($self->req->is_secure ? 'wss' : 'ws')->path('/');
<!doctype html><html>
    <head>
        <title>Balls Demo</title>
        <meta charset="utf-8" />
        <script type="text/javascript" src="/jquery.min.js"></script>
        <script type="text/javascript" src="/jquery.json.min.js"></script>
        <script type="text/javascript" src="/balls.js"></script>
        <script type="text/javascript">
            // Only load the flash fallback when needed
            if (!('WebSocket' in window)) {
                document.write([
                    '<scr'+'ipt type="text/javascript" src="/web-socket-js/swfobject.js"></scr'+'ipt>',
                    '<scr'+'ipt type="text/javascript" src="/web-socket-js/FABridge.js"></scr'+'ipt>',
                    '<scr'+'ipt type="text/javascript" src="/web-socket-js/web_socket.js"></scr'+'ipt>'
                ].join(''));
            }
        </script>
        <script type="text/javascript">
            if (WebSocket.__initialize) {
                // Set URL of your WebSocketMain.swf here:
                WebSocket.__swfLocation = '/web-socket-js/WebSocketMain.swf';
            }

            $(document).ready(function() {
                $('#content').balls({"url":"<%= $url %>"});
            });
        </script>
    </head>
    <body>
        <div class="container">
            <table border="0" height="100%" style="margin:auto">
                <tr>
                    <dt><input type="text" id="room" value="0"></td>
                    <td style="vertical-align:top"><div id="top"></div></td>
                    <td ><div id="rooms"></div></td>
                    <td style="vertical-align:middle">
                        <div id="content"></div>
                    </td>
                    <td><div id="debug"></div></td>
                </tr>
            </table>
        </div>
    </body>
</html>

