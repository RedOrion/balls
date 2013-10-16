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
        <style type="text/css">
        <!--
        body {
            background-color: #ededed;
        }
        #canvas {
            background: #fff;
            border: 1px;
            solid : #cbcbcb;
        }
        -->
        </style>
        <script>
var context;

var start_x = 60;
var start_y = 60;
var start_t = 2000;

var end_x = 550;
var end_y = 450;
var end_t = 5000; // milliseconds 

var date = new Date();
var init_t;

function Bouncer() {
    var self = this;

    this.render=function() {
        context.clearRect(0, 0, 600, 600);
        context.beginPath();
        context.fillStyle="#000066";

        var date = new Date();
        var now_t = date.getTime() - init_t;
        if (now_t < start_t || now_t > end_t) {
            // Outside the period of the animation
        }
        else {
            var prop = (now_t - start_t) / (end_t - start_t);

            var x = Math.round(start_x + (end_x - start_x) * prop);
            var y = Math.round(start_y + (end_y - start_y) * prop);

            context.arc(x,y,20,0,Math.PI*2,true);
            context.closePath();
            context.fill();
        }
        requestAnimationFrame(self.render);
    }

};

function init() {
    context = canvas.getContext('2d');
    var bouncer = new Bouncer();
    init_t = date.getTime();

    bouncer.render();
}


        </script>
    </head>
    <body onLoad="init();">
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
        <canvas id="canvas" width="600" height="600"></canvas>
    </body>
</html>


