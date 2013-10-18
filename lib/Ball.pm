package Ball;

use Moose;
use namespace::autoclean;

# Balls have unique IDs
has 'id' => (
    is          => 'rw',
    isa         => 'Int',
    required    => 1,
);
# Size of the ball
has 'radius' => (
    is          => 'rw',
    isa         => 'Int',
    default     => 20,
);
# Colour of the ball
has 'colour' => (
    is          => 'rw',
    isa         => 'Str',
    default     => 'white',
);
# Status of the ball (e.g. 'OK'
has 'status' => (
    is          => 'rw',
    isa         => 'Str',
    default     => 'ok',
);
# health of the ball in percentage 0 - 100
has 'health' => (
    is          => 'rw',
    isa         => 'Int',
    default     => 100,
);
__PACKAGE__->meta->make_immutable;
