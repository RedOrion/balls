package Ball::Quantum;

# A representation of a ball, moving between two places, in time

use Moose;
use namespace::autoclean;


extends "Ball";

# Start time in milliseconds
has 'start_time' => (
    is      => 'rw',
    isa     => 'Float',
    default => 0,
);
# end time in milliseconds
has 'end_time' => (
    is      => 'rw',
    isa     => 'Float',
    default => 0,
);
# start X co-ordinate (in pixel space)
has 'start_x' => (
    is      => 'rw',
    isa     => 'Float',
    default => 0,
);
# start Y co-ordinate
has 'start_y' => (
    is      => 'rw',
    isa     => 'Float',
    default => 0,
);
# end X co-ordinate
has 'end_x' => (
    is      => 'rw',
    isa     => 'Float',
    default => 0,
);
# end Y co-ordinate
has 'end_y' => (
    is      => 'rw',
    isa     => 'Float',
    default => 0,
);

__PACKAGE__->meta->make_immutable;
