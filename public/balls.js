(function($){
    $.fn.extend({
        balls: function(o) {
            var self    = this;

            self.playerId = null;
            self.players = {};
            var defaults = {};
            var options = $.extend(defaults, o);

            self.displayMessage = function (msg) {
                $(this).html(msg);
            };

            $('#room').change(function() {
                ws.send($.toJSON({"type" : "move", "direction" : "left"}));
            });

            self.addPlayer = function(player) {
                self.players[player.id] = player;
//                alert("Add player "+player.id);
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

                    //console.log('Message received');
                    $('#debug').html(e.data);

                    if (type == 'new_player') {
                        //console.log('New player connected');
                        var player = new Player({
                            "id" : data.id
                        });
                        self.addPlayer(player);
                    }
                    else if (type == 'old_player') {
                        //console.log('Player disconnected');
                        delete self.players[data.id];
                    }
                    else if (type == 'rooms') {
                        $('#top').html("room data = ["+data[$('#room').val()]+"]");
                    }
                };

                ws.onclose = function() {
                    $('#top').html('');
                    self.displayMessage('Disconnected. <a href="/">Reconnect</a>');
                };

                $('#room').keyup(function() {
                    $('#debug').html('room change');
                    ws.send($.toJSON({"type" : "room", "number" : $('#room').val() }));
                });

            });
        }
    });
})(jQuery);
