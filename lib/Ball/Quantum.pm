package Ball;

# A representation of a ball, moving between two places, in time

use Moose;
use namespace::autoclean;


extends "Ball";

has 'start_time' => (
    is      => 'rw',
    isa     => 'Float',
    default => 0,
);
has 'end_time' => (
    is      => 'rw',
    isa     => 'Float',
    default => 0,
);
has 'start_x' => (
    is      => 'rw',
    isa     => 'Float',
    default => 0,
);
has 'start_y' => (
    is      => 'rw',
    isa     => 'Float',
    default => 0,
);
has 'end_x' => (
    is      => 'rw',
    isa     => 'Float',
    default => 0,
);
has 'end_y' => (
    is      => 'rw',
    isa     => 'Float',
    default => 0,
);

__PACKAGE__->meta->make_immutable;
