package Ball;

use Moose;
use namespace::autoclean;

has 'x' => (
    is      => 'rw',
    isa     => 'Float',
    default => 0,
);
has 'y' => (
    is      => 'rw',
    isa     => 'Float',
    default => 0,
);
has 'delta_x' => (
    is      => 'rw',
    isa     => 'Float',
    default => 0,
);
has 'delta_y' => (
    is      => 'rw',
    isa     => 'Float',
    default => 0,
);
has 'colour' => (
    is      => 'rw',
    isa     => 'Str',
    default => 'white',
);
has 'status' => (
    is      => 'rw',
    isa     => 'Str',
    default => 'ok',
);

__PACKAGE__->meta->make_immutable;
