(function($){
    $.fn.extend({
        balls: function(o) {
            var balls    = this;

            var i;

            balls.playerId = null;
            balls.players = {};

            var defaults = {};

            var options = $.extend(defaults, o);

            balls.displayMessage = function (msg) {
                $(this).html(msg);
            };

            balls.addPlayer = function(player) {
                balls.players[player.id] = player;
                alert("Add player "+player.id);
            };

            balls.getPlayer = function(id) {
                if (id) {
                    return balls.players[id];
                }

                return balls.players[balls.playerId];
            };

            balls.init = function() {
                //console.log('init');
            };

            function Player(options) {
                var player = this;

                player.id = options.id;
            }

            return balls.each(function() {
                var o = options;

                balls.displayMessage('Connecting...');

                // Connect to WebSocket
                var ws = new WebSocket(o.url);

                ws.onerror = function(e) {
                    balls.displayMessage("Error: " + e);
                };

                ws.onopen = function() {
                    balls.displayMessage('Connected. Loading...');

                    balls.init();

                };

                ws.onmessage = function(e) {
                    var data = $.evalJSON(e.data);
                    var type = data.type;

                    //console.log('Message received');

                    if (type == 'new_player') {
                        //console.log('New player connected');
                        var player = new Player({
                            "id" : data.id
                        });
                        balls.addPlayer(player);
                    }
                    else if (type == 'old_player') {
                        //console.log('Player disconnected');
                        delete balls.players[data.id];
                    }
                };

                ws.onclose = function() {
                    $('#top').html('');
                    balls.displayMessage('Disconnected. <a href="/">Reconnect</a>');
                };
            });
        }
    });
})(jQuery);
