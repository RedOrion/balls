#!/usr/bin/perl

use FindBin;
use lib 'lib';
use Mojolicious::Lite;
use Mojo::JSON;
use Mojo::ByteStream;
use Mojo::IOLoop;

use Client;

my $ioloop  = Mojo::IOLoop->singleton;
my $clients = {};
my $rooms   = {};

# One second room timer
# Once a room is created, it counts forever
$ioloop->recurring(1 => sub {
    foreach my $rm (keys %$rooms) {
        $rooms->{$rm}++;
    }
    _broadcast({
        msg => {
            type    => 'rooms',
            data    => $rooms,
        }
    });
    app->log->debug('Sending to all players');
});


# The websocket URL. This tells us a new client has made a connection
#
websocket '/' => sub {
    my ($self) = @_;

    my $tx  = $self->tx;
    my $cid = "$tx";
    
    Mojo::IOLoop->stream($tx->connection)->timeout(0);

    app->log->debug('Client connected');

    # Get some basic details of the client. For now just record the ID
    #
    my $client = Client->new({
        tx      => $tx,
        name    => 'foo',
        id      => $cid,
    });
    $clients->{$cid} = $client;

    app->log->debug('Notify other clients about a new client');

    _broadcast({
        msg => {
            type    => 'new_client',
            data    => $client->as_hash,
        }, 
        exclude => $client,
    });

    # On receiving a message from the client
    $self->on(message =>
        sub {
            my ($self, $json_msg) = @_;

            my $json = Mojo::JSON->new;
            app->log->debug("Message [$json_msg]");

            # Very basic checks. Just ignore errors.
            #
            my $message = $json->decode($json_msg);
            return unless $message || $json->error;

            my $type = $message->{type};
            return unless $type;

            if ($type eq 'room') {
                my $room_number = $message->{data}{number};
                if (not defined $rooms->{$room_number}) {
                    $rooms->{$room_number} = 0;
                }
            }
        }
    );

    $self->on( finish =>
        sub {
            my ($self) = @_;

            _broadcast({
                msg => {
                    type    => 'old_client',
                    data    => $client->as_hash,
                },
                exclude => $client,
            });
            delete $clients->{$cid};
            
            app->log->debug('Player disconnected');
        }
    );
};

# get the HTML
#
get '/' => 'index';


# Encode a data structure in JSON
#
sub _to_json {
    my ($perl_struct)  = @_;

    my $json = Mojo::JSON->new;
    $json = $json->encode($perl_struct);
    app->log->debug($json);
    return $json;
}

# Send a message to everyone, (but can 'exclude' oneself)
#
sub _broadcast {
    my ($args) = @_;

    my $exclude = $args->{exclude};
    my $json    = _to_json( $args->{msg} );

    CLIENT:
    foreach my $cid (keys %$clients) {
        my $client = $clients->{$cid};
        next CLIENT if $exclude and $exclude == $client;

        $client->tx->send($json);
    }
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

