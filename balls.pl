#!/usr/bin/perl

use FindBin;
use lib 'lib';
use Mojolicious::Lite;
use Mojo::JSON;
use Mojo::ByteStream;
use Mojo::IOLoop;

use Client;
use WS::Root;

my $ws_root = WS::Root->new({
    log     => app->log,
});

# The websocket URL. This tells us a new client has made a connection
#
websocket '/' => sub {
    my ($self) = @_;

    my $tx  = $self->tx;
    Mojo::IOLoop->stream($tx->connection)->timeout(0);
    my $client = Client->new({
        tx      => $tx,
        name    => 'foo',
        id      => "$tx",
    });
    $ws_root->add_client($self, $client);
};

# get the HTML
#
get '/' => 'index';

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

