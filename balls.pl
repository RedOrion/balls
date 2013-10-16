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

var date = new Date();
var init_t;

function Ball(args) {
    this.start_x = args.start_x;
    this.start_y = args.start_y;
    this.start_t = args.start_t;
    this.end_x   = args.end_x;
    this.end_y   = args.end_y;
    this.end_t   = args.end_t;
    var self = this;

    this.render=function() {
        var date = new Date();
        var now_t = date.getTime() - init_t;
        if (now_t < self.start_t || now_t > self.end_t) {
            // Object not in scope
        }
        else {
            var prop = (now_t - self.start_t) / (self.end_t - self.start_t);
            var x = Math.round(self.start_x + (self.end_x - self.start_x) * prop);
            var y = Math.round(self.start_y + (self.end_y - self.start_y) * prop);
            context.arc(x,y,20,0,Math.PI*2,true);
            context.closePath();
            context.fill();
        }
    }
};


function Bouncer(args) {
    this.ball = args.ball;
    var self = this;

    this.render=function() {
        context.clearRect(0, 0, 600, 600);
        context.beginPath();
        context.fillStyle="#000066";

        self.ball.render();
        requestAnimationFrame(self.render);
    }

};

function init() {
    var canvas = document.getElementById("canvas");
    context = canvas.getContext('2d');

    var ball = new Ball({
        start_x : 60,
        start_y : 50,
        start_t : 2000,
        end_x   : 550,
        end_y   : 450,
        end_t   : 10000
    });

    var bouncer = new Bouncer({
        ball : ball    
    });
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


