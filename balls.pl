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
        <script type="text/javascript" src="/room.js"></script>

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
(function() {
    var lastTime = 0;
    var vendors = ['ms', 'moz', 'webkit', 'o'];
    for(var x = 0; x < vendors.length && !window.requestAnimationFrame; ++x) {
        window.requestAnimationFrame = window[vendors[x]+'RequestAnimationFrame'];
        window.cancelRequestAnimationFrame = window[vendors[x]+
          'CancelRequestAnimationFrame'];
    }

    if (!window.requestAnimationFrame)
        window.requestAnimationFrame = function(callback, element) {
            var currTime = new Date().getTime();
            var timeToCall = Math.max(0, 16 - (currTime - lastTime));
            var id = window.setTimeout(function() { callback(currTime + timeToCall); }, 
              timeToCall);
            lastTime = currTime + timeToCall;
            return id;
        };

    if (!window.cancelAnimationFrame)
        window.cancelAnimationFrame = function(id) {
            clearTimeout(id);
        };
}())

$(document).ready(function() {
    $('#content').room({"url" : "<%= $url %>"});
    var canvas = document.getElementById("canvas");
    context = canvas.getContext('2d');
    imageObj = new Image();
    imageObj.onLoad = function() {
//        context.drawImage(imageObj, 50,50);
    };
    imageObj.src = 'http://178.79.150.173:3000/sp_ship.png';
    bgImage = new Image();
    bgImage.src = 'http://178.79.150.173:3000/starfield.png';
    bgImage.onLoad = function() {};
});



var context;
var imageObj;
var bgImage;
var date = new Date();
var init_t = -1;

function Ball(args) {
    this.start_x = args.start_x;
    this.start_y = args.start_y;
    this.start_t = args.start_t;
    this.end_x   = args.end_x;
    this.end_y   = args.end_y;
    this.end_t   = args.end_t;
    this.init_t  = args.init_t;
    var self = this;

    this.render=function() {
        var date = new Date();
        var now_t = date.getTime() - self.init_t;
        if (now_t < self.start_t || now_t > self.end_t) {
            // Object not in scope
        }
        else {
            var prop = (now_t - self.start_t) / (self.end_t - self.start_t);
            var x = Math.round(self.start_x + (self.end_x - self.start_x) * prop);
            var y = Math.round(self.start_y + (self.end_y - self.start_y) * prop);
            context.drawImage(imageObj, x, y);
        }
    }
};


function Bouncer(args) {
    this.balls  = args.balls;
    this.width  = args.width;
    this.height = args.height;
    var self = this;

    this.render=function() {
        //var date = new Date();
        //var now_t = date.getTime() - init_t;

        context.clearRect(0, 0, self.width, self.height);
        context.drawImage(bgImage,0,0);

        context.beginPath();
        context.fillStyle="#000066";

        for (var i=0; i<self.balls.length; i++) {
            self.balls[i].render();
        }
        requestAnimationFrame(self.render);
    }

};



        </script>
    </head>
    <body>
        <canvas id="canvas" width="1000" height="1000"></canvas>
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


