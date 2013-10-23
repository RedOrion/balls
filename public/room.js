(function($){
    $.fn.extend({
        room: function(o) {
            var self    = this;

            self.playerId = null;
            self.players = {};
            var defaults = {};
            var options = $.extend(defaults, o);

            self.displayMessage = function (msg) {
                $(this).html(msg);
            };

            self.addPlayer = function(player) {
                self.players[player.id] = player;
            };

            self.getPlayer = function(id) {
                if (id) {
                    return self.players[id];
                }
                return self.players[self.playerId];
            };

            self.init = function() {
                //console.log('init');
            };

            function Player(options) {
                var player = this;

                player.id = options.id;
            }

            return self.each(function() {
                var o = options;

                self.displayMessage('Connecting...');

                // Connect to WebSocket
                var ws = new WebSocket(o.url);

                ws.onerror = function(e) {
                    self.displayMessage("Error: " + e);
                };

                ws.onopen = function() {
                    self.displayMessage('Connected. Loading...');

                    self.init();

                };

                ws.onmessage = function(e) {
                    var data = $.evalJSON(e.data);
                    var type = data.type;
                    var content = data.data;
                    //console.log('Message received');
//                    $('#debug').html(e.data);

                    if (type == 'new_client') {
                        //console.log('New player connected');
                        var player = new Player({
                            "id" : content.id
                        });
                        self.addPlayer(player);
                    }
                    else if (type == 'old_client') {
                        //console.log('Player disconnected');
                        delete self.players[content.id];
                    }
                    else if (type == 'rooms') {
                        $('#top').html("room data = ["+content[$('#room').val()]+"]");
                    }
                    else if (type == 'room_data') {
                        var c_ball_pit = content.ballpit;
                        var date = new Date();
                        init_t = date.getTime() - c_ball_pit.time;

                        var c_balls = c_ball_pit.balls;
                        var balls = new Array();
                        for (var i=0; i<c_balls.length; i++) {
                            var c_ball = c_balls[i];
                            balls[i] = new Ball({
                                start_x : c_ball.start_x,
                                start_y : c_ball.start_y,
                                start_t : c_ball.start_time,
                                end_x   : c_ball.end_x,
                                end_y   : c_ball.end_y,
                                end_t   : c_ball.end_time,
                                init_t  : init_t
                            });
                        }
                        var bouncer = new Bouncer({
                            balls   : balls,
                            width   : 1000,
                            height  : 1000
                        });
                        bouncer.render();
                    }
                };

                ws.onclose = function() {
                    $('#top').html('');
                    self.displayMessage('Disconnected. <a href="/">Reconnect</a>');
                };

                $('#room').keyup(function() {
        //            $('#debug').html('room change');
                    ws.send($.toJSON({"type" : "room", "data" : { "number" : $('#room').val() } } ));
                });

            });
        }
    });
})(jQuery);
